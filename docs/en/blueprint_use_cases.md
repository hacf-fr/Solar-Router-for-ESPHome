# Blueprint use cases — Priority to EV

Truth table demonstrating the prioritization logic implemented by
[`blueprints/priority_to_ev.yaml`](blueprint_priority_to_ev.md).

Conventions:

- **Surplus** = `max(0, −grid_power) + max(0, diverted_power)`, in W.
- Defaults: `EV_Charging_Minimum_Surplus = 1400 W`,
  `surplus_duration_trigger = 60 s`, `EV_SoC_Target = 80 %`.
- "Stable ≥ N s?" — has the surplus already been on the same side of
  the threshold for at least `surplus_duration_trigger` seconds?
- HA's `numeric_state` triggers use **strict** inequalities (`above:`
  = `>`, `below:` = `<`). At the exact threshold, nothing fires.

| # | EV plugged | SoC   | Surplus (W)      | Router before | Stable ≥ N s? | Action        | Reason |
|:--|:-----------|:------|:-----------------|:--------------|:--------------|:--------------|:-------|
| 1 | No         | —     | +2000            | On            | —             | keep On       | EV absent — router owns the surplus |
| 2 | No         | —     | −500 (importing) | On            | —             | keep On       | routine, no surplus |
| 3 | Yes        | 40 %  | 500 (< 1400)     | On            | yes           | keep On       | insufficient surplus for the EV |
| 4 | Yes        | 40 %  | 2000 (> 1400)    | On            | **no** (30 s) | keep On       | debounce still running |
| 5 | Yes        | 40 %  | 2000 (> 1400)    | On            | yes           | **turn Off**  | give priority to EV |
| 6 | Yes (charging) | 45 % | 200 (< 1400)  | Off           | yes           | **turn On**   | cloud — restore router |
| 7 | Yes (charging) | 45 % | 200 (< 1400)  | Off           | **no** (10 s) | keep Off      | brief cloud — ride it out |
| 8 | Yes (charging) | 80 % | 3000          | Off           | —             | **turn On**   | SoC target reached (release EV priority) |
| 9 | Yes        | 90 %  | 3000             | On            | —             | keep On       | SoC already ≥ target — never hand surplus to full EV |
| 10 | Just unplugged | 60 % | 3000          | Off           | —             | **turn On**   | EV gone — router resumes |
| 11 | Yes        | 40 %  | exactly 1400     | On            | yes           | keep On       | `above:` is strict — no trigger |
| 12 | Yes (charging) | 40 % | exactly 1400  | Off           | yes           | keep Off      | `below:` is strict — no restore |
| 13 | Yes        | 40 %  | oscillating around 1400 | On     | never stable  | keep On       | debounce prevents flapping |
| 14 | Yes        | 40 %  | 2000 already stable | Off (stale after HA restart) | `homeassistant.started` fires | **turn Off** | resync after restart |

## Notes

- Row 3 vs row 4/5: the debounce (`surplus_duration_trigger`) is the
  only difference. Anything shorter than that is treated as noise.
- Rows 6 and 8: both restore the router, but for different reasons —
  cloud vs. car full. The action is the same (`switch.turn_on`).
- Row 9: `ev_soc_target` is checked before the surplus threshold. Once
  the car is full, no amount of surplus will hand it priority again.
- Rows 11–12: illustrate the strict-inequality corner. Users who want
  hysteresis around the threshold should set two thresholds or leave
  `surplus_duration_trigger` at a sensible value.
- Row 14: `automation_reloaded` and `homeassistant.started` re-run the
  action logic once, so the state matches reality after a restart.

## SoC input left empty

When `ev_soc` is not provided, rows 8 and 9 are impossible to
detect from Home Assistant, so the EV is expected to stop drawing on
its own when full. In that case the router will *not* automatically be
restored the moment the car is full — it will wait for either an
unplug event or the surplus to drop below threshold (which will
naturally happen when the EV stops drawing and the surplus is redirected
past the threshold again).

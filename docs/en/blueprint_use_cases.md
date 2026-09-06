# Blueprint use cases — Priority to EV

Truth table demonstrating the arbitration logic implemented by
[`blueprints/priority_to_ev.yaml`](blueprint_priority_to_ev.md).

Conventions:

- `surplus = max(0, -grid_power) + max(0, diverted_power)` (in W).
- Defaults: `EV_Charging_Minimum_Surplus = 1400 W`,
  `cloud_import_threshold = 200 W`,
  `release_export_threshold = 200 W`,
  `surplus_duration_trigger = 60 s`,
  `EV_SoC_Target = 80 %`.
- **All level-based triggers** (Handoff / Cloud / Release) use HA
  template triggers with `for:` — they fire when the condition
  transitions false → true and stays true for
  `surplus_duration_trigger` seconds.

| #  | Router before | ev_conn         | SoC   | grid_power (W)   | diverted (W) | Trigger that fires             | Action        | Reason                                        |
|:---|:--------------|:----------------|:------|-----------------:|-------------:|:-------------------------------|:--------------|:----------------------------------------------|
| 1  | ON            | no              | —     | −2000            | 1800         | none — Handoff blocked, no EV  | keep ON       | EV absent — router owns the surplus           |
| 2  | ON            | yes             | 40 %  | −1800            | 200          | Handoff (surplus 2000 > 1400)  | **turn OFF**  | give priority to EV                           |
| 3  | ON            | yes             | 40 %  | −500             | 100          | none — surplus 600 < 1400      | keep ON       | insufficient surplus                          |
| 4  | OFF           | yes (charging)  | 45 %  | ≈ 0              | 0            | none — grid stable in ±200     | **keep OFF**  | steady state — v1 flip-flop bug fixed         |
| 5  | OFF           | yes (charging)  | 45 %  | **+400**         | 0            | Cloud (grid > 200 for 60 s)    | **turn ON**   | cloud arrived — restore router                |
| 6  | OFF           | yes (charging)  | 45 %  | +100 briefly     | 0            | none — below cloud threshold   | keep OFF      | benign fluctuation                            |
| 7  | OFF           | yes (tapering)  | 80 %  | ≈ 0              | 0            | none — handoff frozen, not restored | keep OFF | SoC crossed target but EV still drawing — wait for real export |
| 7b | OFF           | yes (finished)  | 82 %  | **−1500**        | 0            | Release (−grid > 200 for 60 s) | **turn ON**   | tapering done — grid export detected          |
| 8  | OFF           | yes (SoC unknown)| —    | **−1500**        | 0            | Release (−grid > 200 for 60 s) | **turn ON**   | EV done / paused — grid export detected       |
| 9  | OFF           | just unplugged  | 60 %  | −1500            | 0            | ev_unplugged (state)           | **turn ON**   | EV gone                                       |
| 10 | ON            | yes             | 100 % | −3000            | 2500         | none — SoC ≥ target            | keep ON       | never hand surplus to full EV                 |
| 11 | ON            | yes             | 40 %  | +100 (transient) | 500          | none — Handoff blocked         | keep ON       | surplus 500 < 1400                            |
| 12 | OFF           | yes             | 40 %  | oscillates ±100  | 0            | none — never stable outside ±200 | keep OFF    | debounce absorbs jitter                       |
| 13 | OFF (post-reboot) | yes         | 45 %  | ≈ 0              | 0            | `homeassistant.start` runs action; no restore condition holds | **no-op** | v1 restart bug fixed         |
| 14 | any           | yes             | any   | `unavailable`    | any          | none — `has_value` gates block | keep as-is    | sensor dropout is not a signal                |
| 15 | ON            | yes (plugged now) | 40 %| −1600 (stable for hours) | 400 | Handoff after 60 s             | **turn OFF**  | plug-in respects debounce — v1 bug fixed      |

## Notes

- **Row 4** is the regression check: with router OFF and the EV
  drawing normally, `grid_power ≈ 0` and `diverted = 0`, so the naive
  "surplus < threshold" check would fire (v1 bug) and yank priority
  away. The grid-side signal correctly does nothing.
- **Row 5 vs row 6**: any import that stays above
  `cloud_import_threshold` for the full debounce is treated as a
  cloud. Brief dips below the threshold reset the debounce timer.
- **Rows 7 and 7b**: crossing `ev_soc_target` freezes new handoffs but
  does **not** restore the router by itself. The car typically keeps
  charging past that value at reduced power ("tapering") — turning
  the router on immediately would fight the EV for that tail-end
  energy. Instead, the blueprint waits for `-grid_power >
  release_export_threshold` (Release trigger) to confirm the car has
  actually stopped drawing, then restores the router.
- **Row 8** exercises the same Release path when no SoC sensor is
  configured: the blueprint detects that the EV has stopped drawing
  (the surplus starts flowing to the grid) and restores the router.
- **Row 10**: `soc_below_target` is a mandatory condition of Handoff,
  so an already-full car never gets priority.
- **Row 13**: an HA restart re-runs the action once. The restore
  branch requires an *actual* restore reason to hold *right now* —
  a stable handoff (grid ≈ 0, still charging) is not a restore
  reason, so nothing happens.
- **Row 14**: every level-based trigger begins with `has_value(...)`.
  If `grid_power` or `diverted_power` is `unavailable`, none of the
  level triggers can fire. Only the state-based trigger
  (`ev_unplugged`) can still act.
- **Row 15**: plugging the EV in while surplus is already high does
  not turn the router off *instantly*. The Handoff template goes
  from false (ev not connected) to true, and the `for:` timer waits
  60 s before firing.

## SoC input left empty

Without a SoC sensor, row 10 (handoff guard on a full car) is no
longer effective — but the restore side is unaffected: row 8
(Release trigger) already handled everything even when SoC was
known. When the EV stops drawing on its own, the surplus starts
flowing to the grid; as soon as export exceeds
`release_export_threshold` for the debounce window, the router is
restored. The blueprint still works correctly without an SoC sensor;
only the handoff guard against a full car is lost (a car brought in
already full will briefly get priority before the Release trigger
fires 60 s later).

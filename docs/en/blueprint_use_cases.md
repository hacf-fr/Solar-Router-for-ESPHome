# Solar Router EV Priority - Use Cases

**Focus:** Interaction between Solar Router and EV Charger when EV has priority.

**Assumptions:**

- Solar Router diverts surplus to a load (e.g., water heater)
- EV Charger requires ~1400 W minimum to start charging
- When both need power, EV has priority
- "No surplus" = Solar Router at 0 % diversion is normal (router stays ON)
- **Production sensor is available** and represents total solar generation
- **EV SOC sensor is available**; `ev_full_soc` = 100 % (default)

The blueprint is **stateless w.r.t. reason**: it cannot tell "cloud hid
the sun" apart from "the EV is still charging". Both look the same to
the automation — only the current values of `diverted_power`,
`grid_power`, `ev_connected`, `ev_soc`, and the router switch matter.

## Truth table

| #   | Situation                              | EV Plugged | SOC   | Production | Grid    | Div.  | Surplus | Solar Router | Action    | Reason                                                              |
| --- | -------------------------------------- | ---------- | ----: | ---------: | ------: | ----: | ------: | ------------ | --------- | ------------------------------------------------------------------- |
| **Baseline: EV not plugged** ||||||||||
| 1   | EV not plugged                         | No         |   N/A |        Any |     Any |   Any |     Any | OFF          | Turn ON   | Cond. 3 — normal operation                                          |
| 2   | EV not plugged                         | No         |   N/A |        Any |     Any |   Any |     Any | ON           | Unchanged | Cond. 3 — already on                                                |
| **EV plugged — not enough for EV** ||||||||||
| 3   | EV plugged, sun too small              | Yes        |  40 % |      600 W |   −10 W | 600 W |   610 W | ON           | Unchanged | Surplus < 1400 W, Cond. 1 not met                                   |
| **EV plugged — needs charging** ||||||||||
| 4   | EV plugged, enough surplus             | Yes        |  40 % |     1400 W |   −10 W |   0 W |    10 W | ON           | Unchanged | Surplus 10 W < 1400 W, Cond. 1 not met (production alone is not surplus) |
| 4b  | EV plugged, enough surplus             | Yes        |  40 % |     3000 W |     0 W |1500 W |  1500 W | ON           | Turn OFF  | Cond. 1 — surplus 1500 W > 1400 W                                   |
| **EV actively charging** ||||||||||
| 6   | EV plugged, EV drawing max             | Yes        |  50 % |     3400 W |   −10 W |   0 W |    10 W | OFF          | Unchanged | Cond. 2 needs surplus > 200 W                                       |
| 7   | Cloud reduces production while OFF     | Yes        |  60 % |      600 W |  −400 W |   0 W |   400 W | OFF          | Turn ON   | Cond. 2 — surplus 400 W > 200 W. Router recaptures the exported W.  |
| **EV full — reactivation logic (SOC = 100 %)** ||||||||||
| 8   | High production, high export           | Yes        | 100 % |     3400 W | −1200 W |   0 W |  1200 W | OFF          | Turn ON   | Cond. 2 — surplus > 200 W                                           |
| 9   | High production, low export            | Yes        | 100 % |     3400 W |   −10 W |   0 W |    10 W | OFF          | Unchanged | Surplus 10 W < 200 W (EV is still drawing what's left)              |
| 10  | Low production                         | Yes        | 100 % |     1000 W |   −50 W |   0 W |    50 W | OFF          | Unchanged | Surplus 50 W < 200 W, Cond. 2 not met                               |
| **Anti-flicker: EV at 100 %, router ON** ||||||||||
| 11  | High surplus                           | Yes        | 100 % |     3400 W | −1200 W |2200 W |  3400 W | ON           | Unchanged | SOC guard blocks Cond. 1 — never stop diverting once EV is full     |
| 12  | Low surplus                            | Yes        | 100 % |      600 W |  −100 W |   0 W |   100 W | ON           | Unchanged | SOC guard blocks Cond. 1 (surplus is below threshold anyway)        |
| **Boundary cases** ||||||||||
| 13  | Surplus exactly 1400 W                 | Yes        |  40 % |     3200 W |     0 W |1400 W |  1400 W | ON           | Unchanged | `above:` is strict inequality — needs > 1400 W                      |
| 14  | Surplus exactly 200 W (router OFF)     | Yes        | 100 % |     3400 W |  −200 W |   0 W |   200 W | OFF          | Unchanged | `above:` is strict inequality — needs > 200 W                       |

## Notes on the corrections vs the earlier draft

- The old table had **row 5 and row 7** with identical inputs but
  different actions ("Turn ON" vs "Unchanged"). Since the blueprint has
  no way to tell "cloud" apart from "EV still charging", the outcome is
  the same in both cases and only one row is needed. It is now row 7.
- **Row 10** previously showed "Turn ON" at 50 W surplus, but Condition 2
  requires *strictly* > `ev_full_threshold` (200 W). The action is
  actually "Unchanged".
- **Row 11** now shows a consistent set of numbers (Div = 2200 W,
  Grid = −1200 W ⇒ Surplus = 3400 W) and the reason is spelled out —
  the SOC guard is what blocks Condition 1, not any implicit
  "anti-flicker" logic in earlier rows.
- **Rows 13 and 14** clarify the `above:` semantics — the numeric-state
  trigger fires on strict "greater than", so an exactly-at-threshold
  reading never fires.

## Related

- [Blueprint reference](blueprint_priority_to_ev.md) — full behavior,
  worked example, and edge cases.

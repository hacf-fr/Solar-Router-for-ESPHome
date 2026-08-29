# Solar Router EV Priority - Use Cases

**Focus:** Interaction between Solar Router and EV Charger when EV has priority

**Assumptions:**
- Solar Router diverts surplus to load (e.g., water heater)
- EV Charger requires minimum ~1400W to start charging
- When both need power, EV has priority
- "No surplus" = Solar Router at 0% diversion is normal (router stays ON)
- **Production sensor IS available** and represents total solar generation

| #                                  | Situation                             | EV Plugged | EV % | Production | Grid   | Surplus | Solar Router | Action    | Reason                                  |
| ---------------------------------- | ------------------------------------- | ---------- | ---- | ---------- | ------ | ------- | ------------ | --------- | --------------------------------------- |
| **Baseline: EV Not Plugged**       |                                       |            |      |            |        |         |              |           |                                         |
| 1                                  | EV not plugged                        | No         | N/A  | Any        | Any    | Any     | OFF          | Turn ON   | Normal operation                        |
| 2                                  | EV not plugged                        | No         | N/A  | Any        | Any    | Any     | ON           | Unchanged | Normal operation                        |
| **EV Plugged - Not Enough for EV** |                                       |            |      |            |        |         |              |           |                                         |
| 3                                  | EV plugged, sun too small             | Yes        | 40%  | 600W       | -10W   | 610W    | ON           | Unchanged | Production < 1400W, can't charge EV     |
| **EV Plugged - Needs Charging**    |                                       |            |      |            |        |         |              |           |                                         |
| 4                                  | EV plugged, enough surplus            | Yes        | 40%  | 1400W      | -10W   | 1410W   | ON           | Turn OFF  | Production > 1400W, let EV charge       |
| 5                                  | EV plugged, cloud hides sun           | Yes        | 60%  | 600W       | -400W  | 400W    | OFF          | Turn ON   | Production < 1400W, EV not charging     |
| **EV Actively Charging**           |                                       |            |      |            |        |         |              |           |                                         |
| 6                                  | EV plugged, EV charging               | Yes        | 50%  | 3400W      | -10W   | 10W     | OFF          | Unchanged | EV has priority                         |
| 7                                  | EV charging, cloud reduces            | Yes        | 60%  | 600W       | -400W  | 400W    | OFF          | Unchanged | EV still charging                       |
| **EV Full - Reactivation Logic**   |                                       |            |      |            |        |         |              |           |                                         |
| 8                                  | EV full, high production, high export | Yes        | 100% | 3400W      | -1200W | 1200W   | OFF          | Turn ON   | (P>1400 AND E>200) = use surplus        |
| 9                                  | EV full, high production, low export  | Yes        | 100% | 3400W      | -10W   | 10W     | OFF          | Unchanged | (P>1400 AND E<200) = EV still drawing   |
| 10                                 | EV full, low production               | Yes        | 100% | 1000W      | -50W   | 50W     | OFF          | Turn ON   | (P<1400) = not enough for EV anyway     |
| **Anti-Flickering: EV at 100%**    |                                       |            |      |            |        |         |              |           |                                         |
| 11                                 | EV at 100%, router ON, high surplus   | Yes        | 100% | 3400W      | -1200W | 3400W   | ON           | Unchanged | Prevent flickering - never stop at full |
| 12                                 | EV at 100%, router ON, low surplus    | Yes        | 100% | 600W       | -100W  | 700W    | ON           | Unchanged | Prevent flickering - never stop at full |
| **Edge Cases**                     |                                       |            |      |            |        |         |              |           |                                         |
| 13                                 | Surplus exactly =1400W                | Yes        | 40%  | 1400W      | 0W     | 1400W   | ON           | Turn OFF  | At minimum EV threshold                 |
| 14                                 | Export exactly =200W                  | Yes        | 100% | 3400W      | -200W  | 200W    | OFF          | Turn ON   | At reactivation threshold               |

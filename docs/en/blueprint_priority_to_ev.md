# Blueprint Priority_To_EV

This blueprint activates and deactivates the Solar Router so that an
EV requiring charge gets priority whenever the household has enough
solar surplus to run the EV charger.

## Behavior

The decision is driven by the total available solar surplus, computed as
the sum of the power currently being **diverted** by the router and the
power currently being **exported** to the grid:

```
available_surplus = diverted_power + exported_power
                  = diverted_power - grid_power     (grid_power < 0 when exporting)
```

The blueprint follows this algorithm:

```
// EV is disconnected
IF NOT ev_connected
THEN activate the solar router

// EV is connected, EV is not yet full, and enough surplus is available
// to run the EV charger
IF ev_connected
   AND ev_soc < ev_full_soc                              // anti-flicker guard
   AND available_surplus > ev_charging_threshold         // e.g. 1400 W
       FOR delay_before_deactivation seconds
THEN deactivate the solar router
     (so the diverted portion is released and joins the exported portion,
      giving the EV access to the full surplus)

// EV battery is fully charged - the EV no longer draws power, so
// surplus reappears in the grid export
IF ev_connected
   AND the solar router is deactivated
   AND available_surplus > ev_full_threshold             // e.g. 200 W
       FOR delay_before_activation seconds
THEN activate the solar router.
```

Checking the *sum* (diverted + exported) rather than just the exported
power matters when the router is not yet saturated: even at 30% diversion
with a near-zero grid balance, the routed power alone may already be
enough to feed the EV. This condition would be missed by an export-only
threshold.

## Sign convention

This blueprint assumes the Solar Router firmware default (`power_sign: "1"`),
where `solar_router.real_power` is **positive when energy is imported** from
the grid and **negative when exported**. The two power thresholds
(`ev_charging_threshold`, `ev_full_threshold`) are expressed as **positive**
watts (the minimum required surplus magnitude), and `ev_full_soc` is a
percentage.

## A day in the life

Walk through a typical sunny day to see how the blueprint reacts.

**Setup used for the example**

- Diversion load (water heater): 3 kW resistance
- EV charger: dynamic — draws roughly whatever surplus is available, up to ~3.3 kW (16 A single-phase)
- Base house consumption: ~200 W (fridge, standby, etc.)
- Blueprint defaults:
    - `ev_charging_threshold` = 1400 W
    - `ev_full_threshold` = 200 W
    - `delay_before_deactivation` = 60 s
    - `delay_before_activation` = 60 s
    - `ev_full_soc` = 100 %

**Column legend**

- **Prod.** — solar production
- **Div.** — power currently diverted by the router (`solar_router.power_divertion`)
- **EV** — power drawn by the EV charger
- **Grid** — grid exchange (`solar_router.real_power`, positive = import, negative = export)
- **Surp.** — `Div. − Grid`, the value the blueprint tests against its thresholds
- **SOC** — EV battery state of charge (`ev_soc`)
- **Router** — state of `solar_router.activate` before / after this moment

All power values in watts.

| Time  | What happens                            | Prod. | Div. | EV   | Grid  | Surp. | SOC | Router | Blueprint |
|-------|-----------------------------------------|------:|-----:|-----:|------:|------:|----:|:------:|-----------|
| 06:00 | Night, EV unplugged                     |     0 |    0 |    — |  +200 |  −200 |  — | ON     | idle (Cond. 3 already latched) |
| 07:00 | User plugs the EV in                    |    50 |    0 |    0 |  +150 |  −150 | 40% | ON     | plug trigger armed with `delay_before_deactivation` |
| 09:00 | Sun ramps up, water heater warming      |  1000 |  800 |    0 |     0 |   800 | 40% | ON     | surplus < 1400 W, EV waits |
| 10:29 | Just under the threshold                |  1500 | 1300 |    0 |     0 |  1300 | 40% | ON     | nothing |
| 10:30 | Surplus crosses `ev_charging_threshold` |  2000 | 1800 |    0 |     0 |  1800 | 40% | ON     | 60 s timer arms |
| 10:31 | Timer elapsed → **Condition 1**         |  2000 | 1800 |    0 |     0 |  1800 | 40% | ON→**OFF** | router turned off (SOC < 100 %) |
| 10:31 | EV starts drawing                       |  2000 |    0 | 1800 |     0 |     0 | 40% | OFF    | surplus fell to 0, no further trigger |
| 13:00 | Peak sun, EV drawing max                |  3500 |    0 | 3300 |     0 |     0 | 80% | OFF    | steady state |
| 15:00 | EV battery reaches full, stops drawing  |  3000 |    0 |    0 | −2800 |  2800 | 100%| OFF    | surplus jumps, 60 s timer arms |
| 15:01 | Timer elapsed → **Condition 2**         |  3000 |    0 |    0 | −2800 |  2800 | 100%| OFF→**ON** | router turned back on |
| 15:01 | Router recaptures the surplus           |  3000 | 2800 |    0 |     0 |  2800 | 100%| ON     | Cond. 1 blocked by SOC guard — see note |
| 17:30 | Sun dropping                            |  1200 | 1000 |    0 |     0 |  1000 | 100%| ON     | surplus < 1400 W anyway, water heater keeps priority |
| 20:00 | No sun                                  |     0 |    0 |    0 |  +200 |  −200 | 100%| ON     | idle |
| 20:30 | User unplugs the EV                     |     0 |    0 |    — |  +200 |  −200 |  — | ON     | Cond. 3 fires, router already on (no-op) |

### The two decision moments in detail

**10:30 → deactivate the router (Condition 1).** The router is diverting
1800 W to the water heater and the grid is balanced at zero — no export.
An "export-only" rule would ignore this situation entirely. But the sum
`Div. − Grid = 1800 − 0 = 1800 W` is above `ev_charging_threshold`
(1400 W), the SOC is 40 % (below `ev_full_soc`), and it stays there for
the 60 s delay. So Condition 1 fires and the router is turned off. The
water heater releases the 1800 W, which the EV picks up (grid stays
near zero, no wasted export).

**15:00 → reactivate the router (Condition 2).** The EV finished
charging and stops drawing. With the router still off, the full solar
surplus now flows back to the grid: `Grid = −2800 W`. The sum
`0 − (−2800) = 2800 W` is above `ev_full_threshold` (200 W). After 60 s,
Condition 2 fires and the router resumes diversion.

### Why doesn't Condition 1 fire again at 15:01?

Right after Condition 2 turns the router back on, we're at:
`Div. = 2800 W, Grid = 0 W, Surp. = 2800 W` — again well above 1400 W,
which normally would send us straight into another deactivation.

That doesn't happen because the SOC is now 100 % (≥ `ev_full_soc`), so
Condition 1's anti-flicker guard blocks the transition. The router
stays on and the water heater keeps consuming the surplus until either
the EV is unplugged or its SOC drops below `ev_full_soc` again (e.g.
after driving).

### Known behavior

- **Overnight lockout.** If the router is OFF at sunset with the EV
  still plugged in, nothing brings it back on until the next day's
  surplus climbs above `ev_full_threshold` and stays there for
  `delay_before_activation`. Consider adding a manual override or a
  time-based re-arm if that matters for your setup.
- **Sensor drop-outs.** If either `diverted_power` or `grid_power`
  becomes `unavailable` / `unknown`, the surplus is treated as 0 W
  until both come back. That means no state change is triggered —
  which is the safe default, but it also means the router is left in
  whatever state it was in when the sensor went away.
- **Plug / unplug debounce.** State transitions on `ev_connected` are
  debounced with `delay_before_deactivation` and
  `delay_before_activation` respectively. A brief connector wiggle
  won't slam the router off then back on.
- **SOC sensor unavailable.** If `ev_soc` reports `unavailable`, the
  guard evaluates as "not full" — the blueprint continues to give EV
  priority. If you don't have an SOC sensor at all, raise
  `ev_full_soc` to 101 % to disable the guard.
- **Cloud drops production below EV draw.** The EV keeps charging
  (from diminished solar + a bit of grid import), the router stays
  off, and the blueprint stays idle — surplus is now negative, so
  neither Condition 1 nor Condition 2 can fire. The EV pulls from the
  grid until sun returns or you intervene.
- **Automation reloaded / Home Assistant restarted.** The
  `automation_reloaded` event runs the `choose` block once with the
  current state, ensuring Condition 3 (EV unplugged → router ON) is
  re-applied if it was pending.

## Installation

To install this blueprint, refer to the [Home Assistant documentation](https://www.home-assistant.io/docs/automation/using_blueprints/).

The URL to use is: [https://raw.githubusercontent.com/hacf-fr/Solar-Router-for-ESPHome/refs/heads/main/blueprints/priority_to_ev.yaml](https://raw.githubusercontent.com/hacf-fr/Solar-Router-for-ESPHome/refs/heads/main/blueprints/priority_to_ev.yaml)

!!! note
    `ev_connected` is a binary sensor. If your EV charger exposes a
    string status ("EV Connected", "Charging", ...) you'll need a
    template binary sensor.

    Example for MyEnergi Zappi:

    ```yaml
    template:
        - binary_sensor:
            - name: "EV Connected Status"
              unique_id: ev_connected_status
              state: "{{ is_state('sensor.myenergi_zappi_plug_status', 'EV Connected') }}"
              device_class: plug
    ```

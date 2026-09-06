# Home Assistant blueprint — Priority to EV

## 1 – What it does

When an EV is plugged into a smart charger (MyEnergi Zappi, OpenEVSE,
Wallbox Quasar, …) that already does its own surplus-following logic,
you generally want the **car** to win the surplus, not the Solar
Router's water heater. This blueprint arbitrates between the two:

- When the surplus is *large enough for long enough*, it turns the
  Solar Router **off** so the surplus is released to the grid, where
  the EV charger picks it up.
- When the EV is full, unplugged, or a passing cloud makes the surplus
  too small for the car, it turns the Solar Router back **on** so the
  water heater catches whatever remains.

The router firmware itself does **not** talk to the EV charger — the
blueprint only toggles the router's `Activate Solar Routing` switch.
Everything else stays in the charger's own hands.

## 2 – Surplus definition

```
surplus = max(0, -grid_power) + max(0, diverted_power)
```

- `grid_power` is signed: **positive when importing**, **negative when
  exporting**. That's the sign convention shipped by default in the
  Solar Router firmware (`power_sign: "1"`).
- `diverted_power` is the router's own `Power divertion` sensor —
  always positive, zero when the router is off.

The `max(0, …)` clamps prevent an import (positive `grid_power`) or a
transient negative diversion reading from pulling the surplus down
artificially.

## 3 – Behavior

```text
IF ev_connected AND ev_soc < ev_soc_target
   AND surplus > EV_Charging_Minimum_Surplus  for > surplus_duration_trigger
   AND solar_router is ON
THEN turn solar_router OFF   (hand priority to the EV)

IF solar_router is OFF
   AND ( ev_not_connected
         OR ev_soc >= ev_soc_target
         OR surplus < EV_Charging_Minimum_Surplus  for > surplus_duration_trigger )
THEN turn solar_router ON    (restore normal routing)
```

- `above:` and `below:` on the `numeric_state` trigger are **strict**
  inequalities — right at the threshold, nothing fires. That's what
  keeps the automation from flapping on a marginal surplus.
- The `for:` clause debounces both directions.
- If `ev_soc` is left empty, the SoC-based guard is skipped: the EV is
  expected to stop drawing on its own when full.

## 4 – Inputs

| Input | Purpose |
| --- | --- |
| `ev_connected` | Binary sensor, ON when the EV is plugged in |
| `ev_soc` | *(optional)* SoC sensor, % |
| `ev_soc_target` | Cut-off SoC in % (default **80**) |
| `grid_power` | Signed grid power in W (default sign: + import, − export) |
| `diverted_power` | Solar Router's `Power divertion` sensor |
| `solar_router` | The `Activate Solar Routing` switch to toggle |
| `ev_charging_minimum_surplus` | Threshold in W (default 1400) |
| `surplus_duration_trigger` | Debounce in s (default 60) |

## 5 – Requirement: keep `Real Power` alive while the router is OFF

Before this version, turning the `Activate Solar Routing` switch OFF
also stopped the meter polling and forced `Real Power` to `NaN` — the
blueprint would then be blind exactly when it most needs eyes. The
firmware shipped with this blueprint keeps the native power meters
polling continuously and no longer publishes `NaN` on shutdown, so the
blueprint's cloud-detection clause works whether the router is on or
off. No user action is required if you flash the matching firmware
version.

## 6 – A day in the life

| Time | Situation | Surplus | Router | Action |
| :--- | :--- | ---: | :--- | :--- |
| 06:00 | Night ending, no PV | −300 W | ON idle | — |
| 09:00 | PV ramps, EV plugged, SoC 40 % | +1600 W | ON diverting | — (debounce running) |
| 09:01 | Surplus stable > 1400 W for 60 s | +1650 W | **OFF** | hand priority to EV |
| 09:02 | EV drawing, surplus small | +200 W | OFF | — (below debounce) |
| 10:30 | Big cloud, surplus < 1400 for 60 s | +100 W | **ON** | cloud — restore router |
| 11:00 | Sun back, surplus > 1400 for 60 s | +2500 W | **OFF** | EV again |
| 15:00 | SoC hits target (80 %) | +2200 W | **ON** | car full — release |
| 20:00 | EV unplugged | −200 W | ON | — |

## 7 – Wiring an EV plug sensor (MyEnergi Zappi example)

If your charger only exposes a text status, wrap it in a template
binary sensor:

```yaml
template:
  - binary_sensor:
      - name: EV plugged in
        device_class: plug
        state: >-
          {{ states('sensor.myenergi_zappi_plug_status')
             in ['EV Connected', 'Waiting for EV', 'Charging', 'Boosting', 'Complete'] }}
```

## 8 – Installation

Import the blueprint into Home Assistant:

- Settings → Automations & Scenes → Blueprints → *Import Blueprint*
- Paste the raw URL of `blueprints/priority_to_ev.yaml` in this
  repository.

Create an automation from the imported blueprint and fill in the six
required inputs.

## 9 – Edge cases

- **Brief cloud (< `surplus_duration_trigger` s)** — the router stays
  off; the debounce absorbs it.
- **HA restart mid-charge** — the automation re-evaluates on
  `homeassistant.started` and converges to the correct state on the
  next surplus tick.
- **User manually turns the router off** while no EV is plugged — the
  blueprint does not fight the user; it only turns the router back ON
  if one of its own conditions calls for it.
- **Surplus exactly at threshold** — neither `above:` nor `below:`
  fires (strict inequality). No action.

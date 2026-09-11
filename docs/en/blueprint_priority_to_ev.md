# Home Assistant blueprint — Priority to EV

## What it does

When an EV is plugged into a smart charger (MyEnergi Zappi, OpenEVSE,
Wallbox Quasar, …) that already does its own surplus-following logic,
you generally want the **car** to win the surplus, not the Solar
Router's water heater. This blueprint arbitrates between the two:

- When the surplus is *large enough for long enough*, it turns the
  Solar Router **off** so the surplus is released to the grid, where
  the EV charger picks it up.
- When the EV is unplugged, a cloud cuts PV production and the house
  starts importing from the grid, or the EV stops taking the surplus
  (car full, paused, or tapering finished), it turns the Solar Router
  back **on** so the water heater catches whatever remains.

The router firmware itself does **not** talk to the EV charger — the
blueprint only toggles the router's `Activate Solar Routing` switch.
Everything else stays in the charger's own hands.

## Signals

### Handoff (router ON → OFF)

```
surplus = max(0, -grid_power) + max(0, diverted_power)
```

- `grid_power` is signed: **positive when importing**, **negative when
  exporting**. That's the sign convention shipped by default in the
  Solar Router firmware (`power_sign: "1"`).
- `diverted_power` is the router's own `Power divertion` sensor —
  always positive, zero when the router is off.

The router is turned OFF when `surplus > EV_Charging_Minimum_Surplus`
holds continuously for `surplus_duration_trigger` seconds, provided
the EV is plugged in and (if a SoC sensor is set) still below target.

### Restore (router OFF → ON)

Once the router is OFF and the EV is drawing on solar, the surplus
formula collapses to ~0: `diverted_power = 0` because the router is
off, and `grid_power ≈ 0` because the EV consumes what PV produces.
The blueprint would then be unable to tell a cloud from ordinary
charging. Instead, it watches `grid_power` directly:

- **`grid_power > cloud_import_threshold` for N s** → we are importing
  → PV can no longer cover the EV → **cloud arrived**.
- **`-grid_power > release_export_threshold` for N s** → we are
  exporting → the EV isn't taking the surplus → **EV done, paused or
  capped**.

Plus one immediate signal that doesn't need debouncing:

- EV unplugged (`ev_connected` transitions to `off`)

The SoC target is deliberately **not** an immediate restore signal.
Most cars keep charging past a user-set target at reduced power, and
turning the router back ON at that instant would fight the EV for the
tail-end energy. The blueprint waits for `-grid_power >
release_export_threshold` — i.e. the car has actually stopped drawing
— to restore the router. The SoC target still gates new handoffs
(see [Behavior](#behavior)).

## Behavior

```text
HANDOFF (router ON → OFF), when this stays true for surplus_duration_trigger s:
  ev_connected == on
  AND solar_router == on
  AND ( ev_soc_entity is empty OR ev_soc < ev_soc_target )
  AND surplus > EV_Charging_Minimum_Surplus

RESTORE (router OFF → ON), on any of:
  ev_connected transitions to off                                        [immediate]
  grid_power > cloud_import_threshold        for surplus_duration_trigger s   [cloud]
  -grid_power > release_export_threshold     for surplus_duration_trigger s   [EV done]
```

The two level-based triggers use HA template triggers with `for:`, so
a brief spike either way is absorbed and never toggles the router.
Crossing `ev_soc_target` freezes the handoff (no fresh router-OFF) but
does not by itself restore the router — the export threshold handles
that once the car actually stops drawing.

## Inputs

| Input | Purpose | Default |
| --- | --- | ---: |
| `ev_connected` | Binary sensor, ON when the EV is plugged in | required |
| `ev_soc` | *(optional)* SoC sensor, % | empty |
| `ev_soc_target` | Above this SoC no new handoff — restore still waits for real export | **80** |
| `grid_power` | Signed grid power in W (+ import, − export) | required |
| `diverted_power` | Solar Router's `Power divertion` sensor | required |
| `solar_router` | The `Activate Solar Routing` switch to toggle | required |
| `ev_charging_minimum_surplus` | Surplus threshold for handoff in W | 1400 |
| `cloud_import_threshold` | Import threshold for cloud detection in W | 200 |
| `release_export_threshold` | Export threshold for "EV done" detection in W | 200 |
| `surplus_duration_trigger` | Debounce for all three level triggers in s | 60 |

## Requirement: keep `Real Power` alive while the router is OFF

Before this version, turning the `Activate Solar Routing` switch OFF
also stopped the meter polling and forced `Real Power` to `NaN`. The
blueprint would then be blind exactly when it most needs eyes — with
Option-3 signals, that would mean not being able to detect either the
cloud OR the EV-done cases. The firmware shipped with this blueprint
keeps the native power meters polling continuously and no longer
publishes `NaN` on shutdown. No user action is required if you flash
the matching firmware version.

## A day in the life

Handoff threshold 1400 W, cloud & release thresholds 200 W each,
debounce 60 s.

![EV priority — typical day](images/priority_to_ev_day_en.png)

*Top strip: numbered events (see caption below the figure). Middle
panel: PV production (yellow), household baseline + water heater + EV
stacked; the blue outline is the total consumption. Bottom panel:
signed grid exchange (import above zero, export below) and the
dashed blueprint surplus curve plotted on the export side.*

| Time | Situation | grid_power | diverted | Router | Action |
| :--- | :--- | ---: | ---: | :--- | :--- |
| 06:00 | Night ending, no PV | +300 (import) | 0 | ON idle | — |
| 09:00 | PV ramps, EV plugged, SoC 40 % | −1600 | 200 | ON diverting | — (debounce running) |
| 09:01 | Handoff template stable > 60 s | −1650 | 200 | **OFF** | give priority to EV |
| 09:02 | EV drawing, PV matched | ≈ 0 | 0 | OFF | — (grid stable, no restore) |
| 10:30 | Big cloud, EV keeps drawing from grid | **+800** | 0 | **ON** | cloud detected — router restored |
| 11:00 | Sun back, surplus > 1400 for 60 s | −2500 | (rising) | **OFF** | EV again |
| 15:00 | SoC hits target (80 %), car keeps tapering | ≈ 0 | 0 | OFF | — (handoff frozen, but EV still draws) |
| 15:30 | EV self-stops on full, export stable > 60 s | **−1500** | 0 | **ON** | export release — router restored |
| 20:00 | EV unplugged | −200 | 100 | ON | — |

## Wiring an EV plug sensor (MyEnergi Zappi example)

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

## Installation

Import the blueprint into Home Assistant:

- Settings → Automations & Scenes → Blueprints → *Import Blueprint*
- Paste the raw URL of `blueprints/priority_to_ev.yaml` in this
  repository.

Create an automation from the imported blueprint and fill in the
inputs.

## Edge cases

- **Brief cloud (< `surplus_duration_trigger` s)** — the router stays
  off; the debounce absorbs it.
- **HA restart mid-charge** — the automation re-evaluates on
  `homeassistant.start`, but the restore branch only fires if a real
  restore reason holds (unplug / cloud / EV done). A restart during a
  stable handoff is a no-op.
- **Sensor `unavailable`** — every level trigger uses `has_value()`
  guards; if `grid_power` or `diverted_power` drops out, no restore
  is triggered.
- **User manually turns the router ON while EV is plugged and surplus
  is high** — the next handoff cycle (60 s) will turn it back off. If
  you want to disable the automation temporarily, disable the
  automation itself in HA.
- **Charger with a small export margin** (some chargers leave 100 W
  going to the grid even at max) — set `release_export_threshold`
  above that margin (e.g. 200–300 W) to avoid a false "EV done"
  detection.
- **Household load spikes** (dishwasher starts) — a large kitchen
  appliance can push `grid_power` briefly positive; the 60 s debounce
  absorbs a normal cycle, but a sustained heavy load *will* trigger
  the cloud branch. Raise `cloud_import_threshold` if this is a
  frequent nuisance.

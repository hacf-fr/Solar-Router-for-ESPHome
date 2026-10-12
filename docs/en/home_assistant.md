# Home Assistant integration

## Description

**Solar-Router-for-ESPHome** devices appear in Home Assistant through the native [ESPHome integration](https://www.home-assistant.io/integrations/esphome/). Once adopted, HA exposes switches, numbers, sensors, and lights that you use to monitor and control the router.

This page is the central entry point for Home Assistant topics. Detailed pages:

| Topic | Page |
| --- | --- |
| Reduce database growth | [Recorder configuration](recorder_configuration.md) |
| Extra diagnostic sensors | [Debug sensors](debug_sensors.md) |
| Which packages are loaded | [Module versions](module_version.md) |
| Give surplus priority to an EV charger | [Blueprint — Priority to EV](blueprint_priority_to_ev.md) |
| Power from HA sensors | [Home Assistant power meter](power_meter_home_assistant.md) |
| Temperature safety from HA | [Home Assistant temperature limiter](temperature_limiter_home_assistant.md) |

## Adoption

1. Flash an empty ESPHome device and adopt it in Home Assistant (see [Installation](installation.md)).
2. Add Solar Router packages to the device YAML and upload via OTA.
3. Entities appear under the device page. Names are prefixed with your device name (examples below use `solarrouter`).

!!! tip "Hide noisy entities"
    By default, regulator opening and LED entities are hidden (`hide_regulators` / `hide_leds`). Set them to `'False'` in the engine `vars` if you want them in HA. See [Engine overview](engine.md).

## Main entities

Entity IDs depend on your device name. The **Name** column is what ESPHome publishes.

### Control

| Name | Typical entity | Role |
| --- | --- | --- |
| Activate Solar Routing | `switch.solarrouter_activate_solar_routing` | Enables automatic regulation and power-meter polling |
| Router Level | `number.solarrouter_router_level` | Main 0–100 % routing level (prefer this over regulator opening) |
| Target grid exchange | `number.solarrouter_target_grid_exchange` | Target grid power in W (0 = no exchange; &lt;0 keep exporting; &gt;0 allow slight import) |
| Up Reactivity | `number.solarrouter_up_reactivity` | How fast the level rises when surplus increases |
| Down Reactivity | `number.solarrouter_down_reactivity` | How fast the level falls when surplus decreases |
| Regulator Opening | `number.solarrouter_regulator_opening` | Physical regulator opening (often hidden) |

### Monitoring

| Name | Typical entity | Role |
| --- | --- | --- |
| Real Power | `sensor.solarrouter_real_power` | Grid exchange (W). Positive = import, negative = export |
| Consumption | `sensor.solarrouter_consumption` | House consumption when provided by the power meter |
| Power divertion | `sensor.solarrouter_power_divertion` | Instantaneous diverted power (with energy counter) |
| Total energy diverted | `sensor.solarrouter_total_energy_diverted` | Cumulative diverted energy (theoretical counter) |

### Safety (if temperature limiter is installed)

| Name | Typical entity | Role |
| --- | --- | --- |
| Safety limit reached | `binary_sensor.solarrouter_safety_limit_reached` | Diversion inhibited when ON |
| Stop temperature / Restart temperature | `number.*` | Thresholds with hysteresis |
| safety_temperature | `sensor.*` | Measured temperature used for the limit |

### Engine-specific

| Engine | Extra entities |
| --- | --- |
| [1 × switch](engine_1switch.md) | Start/Stop power level and tempos |
| [1 × dimmer + bypass](engine_1dimmer_1bypass.md) | Bypass Relay, Bypass tempo |
| [Multi-channel](engine_1dimmer_2switches.md) | Relay countdowns, Bypass tempo, per-relay divertion |

### Scheduler (optional)

See [Scheduler Forced Run](scheduler_forced_run.md): Activate scheduler, begin/end hour and minute, router level, checking end threshold.

## Suggested Lovelace dashboard

A minimal card set for daily use:

```yaml
type: vertical-stack
cards:
  - type: entities
    title: Solar Router
    entities:
      - entity: switch.solarrouter_activate_solar_routing
      - entity: number.solarrouter_router_level
      - entity: number.solarrouter_target_grid_exchange
      - entity: number.solarrouter_up_reactivity
      - entity: number.solarrouter_down_reactivity
  - type: history-graph
    title: Grid exchange
    hours_to_show: 24
    entities:
      - entity: sensor.solarrouter_real_power
      - entity: sensor.solarrouter_power_divertion
  - type: gauge
    entity: number.solarrouter_router_level
    name: Router level
    min: 0
    max: 100
    severity:
      green: 0
      yellow: 50
      red: 90
```

Replace `solarrouter` with your device name prefix. Add safety and scheduler entities if those packages are loaded.

## Automations and blueprints

- Use the **Activate Solar Routing** switch from any HA automation to pause or resume diversion (e.g. when a heat pump or EV charger needs the surplus).
- Ready-made blueprint: [Priority to EV](blueprint_priority_to_ev.md) — turns the router off so an EV charger can take the surplus, then restores it.

## Best practices

1. **Exclude high-frequency sensors** from the recorder (`real_power`, energy counters) — see [Recorder configuration](recorder_configuration.md).
2. Prefer **Router Level** for manual control; do not fight the automatic regulation slider while Activate is ON.
3. Keep [module version](module_version.md) diagnostic entities enabled if you may need support.
4. For regulation that must survive HA downtime, prefer a **native** power meter over the [HA power meter](power_meter_home_assistant.md).

## Related

- [Troubleshooting](troubleshooting.md)
- [Installation](installation.md)

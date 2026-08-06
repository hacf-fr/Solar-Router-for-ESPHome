# Dimmer board safety (RobotDyn AC Dimmer 40 A "with current sensor")

This package adds local safety for the **RobotDyn AC Dimmer 40 A "with current sensor"** (premium variant: heatsink NTC + 5 V fan + built-in CT current sensor).

It provides three layers:

1. **Local heatsink temperature limiter** — works without WiFi or Home Assistant:
   - heatsink >= `heatsink_stop_temperature` → `safety_limit = True` (engine drops to 0 %)
   - heatsink <= `heatsink_restart_temperature` → `safety_limit = False`
   - temperature sensor failure (NaN) → `safety_limit = True` (fail-safe)

2. **Overcurrent cutout** — load current >= `overcurrent_current` → `safety_limit = True`
   - cleared once current falls back under `overcurrent_restart_current`

3. **Health alarms** (informational, no power cut):
   - *Triac Stuck ON*: current flowing while the regulator is closed (shorted triac)
   - *Boiler Not Powered*: regulator open but no current (dead triac / gate)
   - *Current Sensor Failure*: CT output not readable

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  safety:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    file: solar_router/dimmer_safety.yaml
    vars:
      dimmer_temp_pin: GPIO34
      dimmer_current_pin: GPIO35
      red_led_pin: GPIO21
```

!!! note "Only ONE safety limiter package"
    This package owns the shared `safety_limit` global (same as the temperature
    limiter packages). Include only one safety limiter package in a configuration.

## Variables

| Variable | Default | Description |
|---|---|---|
| `dimmer_temp_pin` | `GPIO34` | Heatsink NTC input (ESP32 ADC1, input-only pin 32–39) |
| `dimmer_current_pin` | `GPIO35` | CT current sensor input (ESP32 ADC1) |
| `red_led_pin` | `GPIO21` | Safety LED output |
| `heatsink_stop_temperature` | `80` | Cutout temperature (°C) |
| `heatsink_restart_temperature` | `60` | Restart temperature (°C) |
| `overcurrent_current` | `12.0` | Overcurrent threshold (A RMS) |
| `overcurrent_restart_current` | `8.0` | Overcurrent restart threshold (A RMS) |
| `current_calibration_factor` | `1.0` | CT calibration (A per V on the CUR pin), tune on the bench |

The NTC calibration (`ntc_reference_*`, `ntc_b_coefficient`, `ntc_configuration`) can be adjusted to match the board's divider — see the bench procedure.

!!! warning "Analog inputs"
    `dimmer_temp_pin` and `dimmer_current_pin` must be ESP32 ADC1 pins (input-only pins 32–39).

# Engine 1 x dimmer

## Description

This package implements the engine of the solar router which determines when and how much energy has to be diverted to the load.

**Engine 1 x dimmer** reads the power meter on every update to get the actual energy exchanged with the grid. If energy produced exceeds energy consumed and the surplus exceeds the configured exchange target, the engine calculates the **percentage of regulator opening** and adjusts it dynamically to reach the target.

Engine automatic regulation can be activated or deactivated with the activation switch.

## Router Level vs Regulator Opening

The solar router uses two distinct but related level controls:

- **Router Level**: This is the main system-wide control (0-100%) that represents the overall routing state. It controls the LED indicators and energy counter logic. When automatic regulation is enabled, this level is dynamically adjusted based on power measurements.

- **Regulator Opening**: This represents the actual opening level (0-100%) of the physical regulator. By default, it mirrors the router level since there is only one regulator. While it can be controlled independently, changes to regulator_opening alone won't affect the router_level or trigger LED state changes.

The regulator opening entity is hidden from Home Assistant by default. To expose it, set `hide_regulators: 'False'` in your vars.

Note: It's recommended to adjust the `router_level` rather than `regulator_opening` directly, as this ensures proper system feedback through LEDs and energy monitoring.

## Configuration

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/engine_1dimmer.yaml
        vars:
          green_led_pin: GPIO32
          green_led_inverted: 'False'
          yellow_led_pin: GPIO14
          yellow_led_inverted: 'False'
          hide_regulators: 'True'
          hide_leds: 'True'
```

When this package is used it is required to define `green_led_pin` and `yellow_led_pin` in the `vars` section as shown in the example above.

### Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `green_led_pin` | yes | — | GPIO pin for the green status LED |
| `yellow_led_pin` | yes | — | GPIO pin for the yellow network/error LED |
| `green_led_inverted` | no | `'False'` | Set to `'True'` if the green LED is active low |
| `yellow_led_inverted` | no | `'False'` | Set to `'True'` if the yellow LED is active low |
| `hide_regulators` | no | `'True'` | Set to `'False'` to expose regulator sensors in Home Assistant |
| `hide_leds` | no | `'True'` | Set to `'False'` to expose LED state sensors in Home Assistant |

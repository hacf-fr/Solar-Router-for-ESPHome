# Engine 1 x dimmer + 1 x bypass

## Description

This package implements the engine of the solar router which determines when and how much energy has to be diverted to the load, with a bypass function for maximum efficiency.

When the regulator is used intensively for an extended period, it tends to overheat. This engine avoids this issue by activating a bypass relay and switching off the regulator when the regulator has been fully open (100 %) for a configurable number of consecutive regulation cycles. To prevent flickering the bypass relay is only activated after this threshold is reached.

**Engine 1 x dimmer + 1 x bypass** reads the power meter on every update to get the actual energy exchanged with the grid. If energy produced exceeds energy consumed and the surplus exceeds the configured exchange target, the engine calculates the **percentage of regulator opening** and adjusts it dynamically to reach the target. When the regulator stays at 100 % for the configured number of cycles, the bypass relay is activated for maximum efficiency.

Engine automatic regulation can be activated or deactivated with the activation switch.

## How to wire the bypass relay

- Live on the Bypass Relay Common (COM) and on the Relay to the Live Input of the Regulator
- Normally Closed (NC) floating
- Normally Open (NO) of the Relay to the Load Output of the Regulator (or directly to the Load)

!!! Danger "Follow the wiring instructions"
    Do not plug the Regulator Live Input to the Normally Closed (NC) of the relay ! Your load would be de-energized while switching the relay, potentially creating arcs inside the relay.
    More info in this [discussion](https://github.com/hacf-fr/Solar-Router-for-ESPHome/pull/51#issuecomment-2625724543).

## Router Level vs Regulator Opening

The solar router uses three distinct but related level controls:

- **Router Level**: This is the main system-wide control (0-100%) that represents the overall routing state. It controls the LED indicators and energy counter logic. When automatic regulation is enabled, this level is dynamically adjusted based on power measurements.

- **Regulator Opening**: This represents the actual opening level (0-100%) of the physical regulator. By default, it mirrors the router level since there is only one regulator. While it can be controlled independently, changes to regulator_opening alone won't affect the router_level or trigger LED state changes.

- **Bypass Relay**: This represents the actual state (ON/OFF) of the physical bypass relay. When regulation is enabled, this relay automatically turns on after the duration `Bypass tempo` defined in Home Assistant. When regulation is disabled, you can manually trigger this relay to fully energize your load; LEDs and Energy Counter (if enabled) will not be triggered. You can also set the *Router Level* to 100: this enables the relay, fully energizes your load, and triggers LEDs and Energy Counter.

## Configuration

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/engine_1dimmer_1bypass.yaml
        vars:
          green_led_pin: GPIO1
          green_led_inverted: 'False'
          yellow_led_pin: GPIO2
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

!!! tip "Adjusting Bypass Tempo"
    The `Bypass Tempo` determines how many consecutive regulations at 100% are needed before activating the bypass relay. A lower value will make the bypass more reactive but might cause more frequent switching (flickering). If your power meter is updated 1 time per second, `Bypass Tempo` can be approximated as the time in seconds with the regulator at 100% before the bypass relay is activated; otherwise it corresponds to the number of times your power meter is updated.
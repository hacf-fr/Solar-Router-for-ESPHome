# Engine 1 x dimmer + 2 x switches

This package implements the engine of the solar router which determines when and how much energy has to be diverted to three loads using three channels, or a single load with three channels like a water heater with three heating resistors.

The engine uses two relays to control different loads, with an additional regulator for fine-grained power control. The loads are activated sequentially as more power becomes available:

1. First channel: Relay 1 (On/Off control)
2. Second channel: Relay 2 (On/Off control)
3. Third channel: Dimmer regulator (Variable power control)

When power needs increase:

- First, the regulator on channel 3 gradually increases power
- When regulator reaches 33.33%, relay 1 activates
- When regulator reaches 66.66%, relay 2 activates

**Engine 1 x dimmer + 2 x switches** calls every second the power meter to get the actual energy exchanged with the grid. If energy produced is greater than energy consumed and exceeds the defined exchange target, the engine will determine the appropriate combination of relays and regulator opening to reach the target.

Engine's automatic regulation can be activated or deactivated with the activation switch.

## How to wire the relay (Channel 1 & 2)

- Line on the Relay Common (COM)
- Normally Open (NO) of the Relay from the input Load directly to the Load

## How to wire the dimmer regulator (Channel 3)

- Just like any other dimmer from the input Load directly to the Load, and without any connection to other relay or channel 1 & 2.

## Wiring schema example

![Wiring schema example for water heater](images/3ResistorsWaterHeaterExample.svg)

## Configuration

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  engine:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/engine_1dimmer_2switches.yaml
        vars:
          green_led_pin: GPIO1
          green_led_inverted: 'False'
          yellow_led_pin: GPIO2
          yellow_led_inverted: 'False'
          hide_regulators: 'True'
          hide_leds: 'True'
```
When this package is used it is required to define `green_led_pin` and `yellow_led_pin` in `vars` section as show in the upper example.

* `xxx_led_inverted` can define is led is active on high or low signal and is optional.
* `hide_regulators` allow to hide or show regulators sensors from HA and is optionnal.
* `hide_leds` allow to hide or show leds values from HA and is optionnal.

!!! note "Power Distribution"
    The engine divides the total available power into three equal portions (33.33% each). This allows for smooth transitions between different power levels and efficient distribution of excess solar power across multiple loads. 

!!! tip "Bypass tempo adjustement"
    The Bypass Tempo determines how many consecutive regulations at 33.33% or 66.66% are needed before activating the _bypass_ relay. A lower value will make the bypass more reactive but might cause more frequent switching (flickering). Because there's roughly 1 regulation per second, Bypass Tempo can be approximated as the time in second with the regulator at 33.33% or 66.66% before which relay are activated.


![HA](images/countdown_engine_1dimmer_2switch.png){ align=left }
!!! note ""
    **Sensors**
    
    * ***Countdown for relay no. X*** 
        For each relay, the current countdown is displayed.
        Initially the countdown is equal to the tempo bypass value, then with each energy regulation where the controller is at 100% the countdown is reduced, finally when the countdown is equal to zero the relay is activated.
    * ***Regulator opening*** 
        Hidden by default (see `hide_regulators`), displays the regulator level (TRIAC or SSR).


This package requires the use of the Regulator Relay package AND a regulator package (TRIAC or SSR). Do not forget to also include them.

You can find below the example of configuration for relays:

```yaml linenums="1"
packages:
  relay1_regulator:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/regulator_mecanical_relay.yaml
        vars:
          relay_regulator_gate_pin: GPIO17
          relay_unique_id: "1"
  relay2_regulator:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/regulator_mecanical_relay.yaml
        vars:
          relay_regulator_gate_pin: GPIO18
          relay_unique_id: "2"
```

!!! note "Relay Ids"
    Relay unique ids can't be change to use this engine.
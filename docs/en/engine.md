# Solar router engines

## Description

An engine implements the decision logic of the solar router: it reads power measurements from the power meter and drives the regulators to divert surplus solar energy to local loads instead of exporting it to the grid.

The engine is the heart of the solar router. It owns the `activate` switch, the `router_level` (0–100 %), and the `energy_regulation` script. When automatic regulation is enabled, it continuously adjusts the router level based on real-time power measurements to keep grid exchange close to the configured target.

### Available engines

| Engine | Use case |
| --- | --- |
| [`engine_1dimmer`](engine_1dimmer.md) | Single load with progressive (TRIAC/SSR) control. The simplest and most common choice. |
| [`engine_1switch`](engine_1switch.md) | Single ON/OFF relay load (e.g. pump, resistor without dimming). Switches based on configurable start/stop power thresholds and temporisations. |
| [`engine_1dimmer_1bypass`](engine_1dimmer_1bypass.md) | Dimmer + bypass relay. Activates the bypass relay when the dimmer stays at 100 % for an extended period to reduce regulator heat. |
| [`engine_1dimmer_2switches`](engine_1dimmer_2switches.md) | Dimmer + 2 ON/OFF relays. Distributes power across three channels sequentially (e.g. three-resistor water heater). |
| [`engine_1dimmer_2switches_1bypass`](engine_1dimmer_2switches_1bypass.md) | Dimmer + 2 ON/OFF relays + bypass relay on the third channel. Maximum efficiency for multi-resistor loads. |

!!! note "Engine naming"
    The engine name reflects how energy diversion is performed:  
    **Example** : `engine_1dimmer_1bypass` manages 1 dimmer for progressive regulation associated with a bypass relay.


### User feedback LEDs

The yellow LED reflects the network connection:

- ***OFF*** : solar router is not connected to power supply.
- ***ON*** : solar router is connected to the network.
- ***blink*** : solar router is not connected to the network and is trying to reconnect.
- ***fast blink*** : An error occurs during the reading of energy exchanged with the grid.

The green LED reflects the current regulation state:

- ***OFF*** : automatic regulation is deactivated.
- ***ON*** : automatic regulation is active and is not diverting energy to the load.
- ***blink*** : solar router is currently sending energy to the load.

LED configuration is done in the engine configuration.

### Hide or show sensors

An optional `hide_regulators` variable allows changing regulator sensor visibility in HA (hidden by default).

An optional `hide_leds` variable allows changing LED value visibility in HA (hidden by default).

This configuration is done in the engine configuration.
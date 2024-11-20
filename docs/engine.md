
# Variable Engine

This package is implementing the engine of the solar router which determines when and how many energy has to be diverted to the load.

**Variable engine** calls every second the power meter to get the actual energy exchanged with the grid. If energy produce is greater than energy consummed and exceed the define echange target, the engine will determine the **percentage of the regulator "opening"** and adjusts it dynamically to reach the target.

Engine's automatic regulation can be activated or deactivated with the activation switch.

## User feedback LEDS

The yellow LED is reflecting the network connection:

- ***OFF*** : solar router is not connected to power supply.
- ***ON*** : solar router is connected to the network.
- ***blink*** : solar router is not connected to the network and is trying to reconnect.
- ***fast blink*** : An error occurs during the reading of energy exchanged with the grid.


The green LED is reflecting the actual configuration of regulation:

- ***OFF*** : automatic regulation is deactivated.
- ***ON*** : automatic regulation is active and is not diverting energy to the load.
- ***blink*** : solar router is currently sending energy to the load.

## Configuration

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  engine:
    url: http://github.com/XavierBerger/ESPHome-Solar-Router/
    file: solar_router/engine.yaml
    vars:
      green_led_pin: GPIO19
      yellow_led_pin: GPIO18
```

When this package is used it is required to define `green_led_pin` and `green_led_pin` in `vars` section as show in the upper example.

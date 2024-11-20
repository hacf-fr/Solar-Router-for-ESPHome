
# ON/OFF Engine

This package is implementing the engine of the solar router which determines energy can be diverted to a local load or not.

**ON/OFF engine** calls every second the power meter to get the actual power consumed. If energy sent to the grid is greater than the divertion start level (in W) during start tempo (in s), the relay is closed to use the energy locally. When the energy sent to the grid reach the level (in W) defined to stop the divertion during stop tempo (in s), the relay is openned and local consomption is stopped.

ON/OFF engine's automatic regulation can be activated or deactivated with the activation switch.

The following schema is representing the consumption with this engine activated:

![engine_on_off](images/engine_on_off.png)

**Legend:**

 * Green: Energy consummed coming from solar pannel (self consumption)
 * Yellow: Energy sent to the grid
 * Red: Energy consummed coming from the grid

**How does it work?**

* **①** The yellow part of the graph is showing the start level. When the energy send to the grid reach the start level, energy is diverted locally.
* **②** The yellow part of the graph is showing the stop level. In this example 0W.

!!! Danger "Carefully set the start and stop levels"
    The start level has to be greater than the power of the load plugged to the solar router. If not, as soon as the energy will be diverted to the load, the stop level will be reached and you will see the router switching between ON and OFF (based on temporisation you defined).

!!! tips "finely adjust start and stop tempo"
    The start and stop tempo determine the responsiveness of the regulation. These delays must be finely adjusted to avoid oscillations. For example, if you have an electric stove, pay attention to the heating delays.

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
    file: solar_router/engine_on_off.yaml
    vars:
      green_led_pin: GPIO19
      yellow_led_pin: GPIO18
```

When this package is used it is required to define `green_led_pin` and `green_led_pin` in `vars` section as show in the upper example.


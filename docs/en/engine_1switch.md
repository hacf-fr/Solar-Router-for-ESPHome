
# Engine 1 x switch

This package is implementing the engine of the solar router which determines energy can be diverted to a local load or not.

**Engine 1 x switch** calls the power meter everytime it's updated to get the actual power consumed. If energy sent to the grid is greater than the divertion start level (in W) during start tempo (in s), the relay is closed to use the energy locally. When the energy sent to the grid reach the level (in W) defined to stop the divertion during stop tempo (in s), the relay is openned and local consomption is stopped.

Engine 1 x switch's automatic regulation can be activated or deactivated with the activation switch.

The following schema is representing the consumption with this engine activated:

![Engine 1 x switch](images/engine_1switch.png)

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

## Configuration

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/engine_1switch.yaml
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


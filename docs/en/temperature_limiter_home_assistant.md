# Temperature limiter Home Assistant

This package is designed to monitor a temperature coming from a sensor in Home Assistant and determines if a temperature threshold as been reached or not.

When safety limit is reached, it is possible to turn on a LED. LED configuration has to be added in `vars` section of `packages` as explained bellow.

!!! danger "WARNING: Conduct some tests before letting the system regulate alone"
    This temperature limit monitoring and safety limit may have some bug. It is strongly advised to validate the behaviour of your system carefully before letting the system working by its own.

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/temperature_limiter_home_assistant.yaml
        vars:
          temperature_sensor: "input_number.test_temperature"
          red_led_pin: GPIO4
```

This package needs to know which sensor to use to obtain the temperature to be monitored. This sensor must be defined as `temperature_sensor` into `vars` section of your configuration, as in the example above.

Additionnal optional parameters can be set into `vars` section such as `red_led_inverted` defining if the LED is active on high or low level of pin (which is set default set to `False`).

!!! warning "Data availability and refresh rate"
    This temperature limiter rely on Home Assistant to gather the temperature. It also depends on the rate of sensor update. If a sensor is updated too slowly, the regulation may not work as expected.

# Temperature limiter DS 18B20

This package is designed to monitor a temperature coming from a DS18B20 sensor connected on ESP32 and determines if a temperature threshold as been reached or not.

When safety limit is reached, it is possible to turn on a LED. LED configuration has to be added in `vars` section of `packages` as explained bellow.

!!! danger "WARNING: Conduct some tests before letting the system regulate alone"
    This temperature limit monitoring and safety limit may have some bug. It is strongly advised to validate the behaviour of your system carefully before letting the system working by its own.

The following schematic is representing the wiring of the temperature sensor:

![DS18B20](images/DS18B20_wiring.png){width=400}

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files: 
      - path: solar_router/temperature_limiter_DS18B20.yaml
        vars:
          DS18B20_pin: GPIO13
          temperature_update_interval: 1s
          red_led_inverted: "False"
          red_led_pin: GPIO4
```

This package needs to know the GPIO used by the temperature to get the temperature. This GPIO has to be defined by `DS18B20_pin` into `vars` section of your configuration as in example ballow:

Additionnal optional parameters can be set into `vars` section such as `DS18B20_address` (which is optional), `temperature_update_interval` (which is set by default to `5s`) and `red_led_inverted` defining if the LED is active on high or low level of pin (which is set default set to `False`).

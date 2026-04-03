# Temperature fan control

This package is designed to manage a fan with the objective to control the temprature of the solar router.  
This module is reading the temperature form a `temperature limiter`.
Fan can be configured to start spinning as soon as the start temperature is reached and stop spinning when the measured temperature comes bellow the stop temperature.

!!! note
    The two thresholds regulation use here is named **hysteresis**. This mechansim avoid regulation bouncing.  
    See ***More details about hysteresis and Schmitt trigger*** in [temperature_limiter](#temperature_limiter) page.


!!! danger "WARNING: Conduct some tests before letting the system regulate alone"
    This temperature limit monitoring and safety limit may have some bug. It is strongly advised to validate the behaviour of your system carefully before letting the system working by its own.

The energy available on pin of ESP32 is not sufficient to directly power the fan. It is then required to add an additionnal circuit to use 5V or 12V with the fan.

The following schematic is representing the wiring of the fan:

![FanControl](images/fan_controler.png){width=400}

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  fan_controler:
    url: https://github.com/XavierBerger/Solar-Router-for-ESPHome/
    files:
      - name: solar_router/temperature_fan_controler.yaml
        vars:
          fan_control_pin: GPIO4
```

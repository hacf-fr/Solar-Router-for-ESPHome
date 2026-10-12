# Temperature limiter DS 18B20

## Description

This package monitors the temperature from a **DS18B20 1-Wire sensor** wired directly to the ESP board and determines whether a temperature threshold has been reached. When the safety limit is triggered, the energy diversion is stopped and, optionally, a red LED is turned on to signal the safety condition.

The DS18B20 is a digital temperature sensor communicating over a single data wire, making it easy to integrate without additional circuitry beyond a pull-up resistor.

!!! danger "WARNING: Conduct some tests before letting the system regulate alone"
    This temperature limit monitoring and safety limit may have some bug. It is strongly advised to validate the behaviour of your system carefully before letting the system working by its own.

The following schematic is representing the wiring of the temperature sensor:

![DS18B20](images/DS18B20_wiring.png){width=400}

## Configuration

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

### Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `DS18B20_pin` | yes | — | GPIO pin connected to the DS18B20 data wire |
| `DS18B20_address` | no | `"0"` | ROM address of the sensor (useful with multiple sensors on the same bus) |
| `temperature_update_interval` | no | `5s` | Polling interval for temperature reading |
| `red_led_pin` | yes | — | GPIO pin for the red safety LED |
| `red_led_inverted` | no | `"False"` | Set to `"True"` if the red LED is active low |

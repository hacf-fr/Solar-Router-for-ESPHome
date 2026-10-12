# Temperature limiter Home Assistant

## Description

This package monitors a temperature from **any sensor available in Home Assistant** and determines whether a temperature threshold has been reached. When the safety limit is triggered, the energy diversion is stopped and, optionally, a red LED is turned on to signal the safety condition.

This approach is ideal when a temperature sensor is already integrated into Home Assistant (e.g. a Zigbee probe, a smart thermostat, or any other platform), avoiding the need to wire an additional sensor to the ESP.

!!! danger "WARNING: Conduct some tests before letting the system regulate alone"
    This temperature limit monitoring and safety limit may have some bug. It is strongly advised to validate the behaviour of your system carefully before letting the system working by its own.

## Configuration

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

!!! warning "Data availability and refresh rate"
    This temperature limiter rely on Home Assistant to gather the temperature. It also depends on the rate of sensor update. If a sensor is updated too slowly, the regulation may not work as expected.

### Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `temperature_sensor` | yes | — | Entity ID of the Home Assistant temperature sensor to monitor |
| `red_led_pin` | yes | — | GPIO pin for the red safety LED |
| `red_led_inverted` | no | `"False"` | Set to `"True"` if the red LED is active low |

# Home Assistant Power Meter

This power meter is designed get power consumption directly from Home Assistant sensor.

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  power_meter:
    url: http://github.com/XavierBerger/ESPHome-Solar-Router/
    file: solar_router/power_meter_home_assistant.yaml
    vars:
      main_power_sensor: sensor.grid_exchange
```

This package needs to know the IP address of the inverter. This IP address has to be defined by `main_power_sensor` into `vars` section as show upper.

!!! warning "Data availability and refresh rate"
    This power meter rely on Home Assistant to gather the value of energy exchanged with the grid. It also depends on the rate of sensor update. If a sensor is updated too slowly, the regulation may not work as expected.

    Contrary to Home Assistant power meter, native power meters are autonomous and can continue to regulate even is Home Assistant is offline. Some power meter can have a direct access to the measure and may even be independent to the network.
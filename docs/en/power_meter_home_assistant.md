# Home Assistant Power Meter

## Description

This power meter reads power consumption directly from Home Assistant sensors.

* `main_power_sensor` reflects the power exchanged with the grid. It is expected in Watts (W), positive (> 0) when electricity is consumed from the grid, and negative (< 0) when electricity is sent to the grid.

* `consumption_sensor` reflects the power consumption of your house. This value is used, for example, to calculate the energy diverted.

!!! warning "Data availability and refresh rate"
    This power meter relies on Home Assistant to gather the value of energy exchanged with the grid. It also depends on the sensor update rate. If a sensor is updated too slowly, regulation may not work as expected.

    Unlike this Home Assistant power meter, native power meters are autonomous and can continue to regulate even if Home Assistant is offline. Some power meters have direct access to the measurement and may even be independent of the network.

## Configuration

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/power_meter_home_assistant.yaml
        vars:
          main_power_sensor: "sensor.smart_meter_ts_100a_1_puissance_reelle"
          consumption_sensor: "sensor.solarnet_power_load_consumed"
```

### Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `main_power_sensor` | yes | — | Home Assistant entity ID for grid exchange power (W) |
| `consumption_sensor` | yes | — | Home Assistant entity ID for house consumption power (W) |
| `power_sign` | no | `"1"` | Polarity multiplier (`"-1"` to invert the sign of `main_power_sensor`) |

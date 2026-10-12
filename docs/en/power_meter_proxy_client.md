# Proxy Client Power Meter

## Description

A **proxy client** reads power meter values from another component. That component can be a dedicated device such as an ESP8266 running only a power meter package (see [proxy architecture](firmware.md#power-meter-proxy-configuration)) or another solar router running a power meter that reads the real power exchanged with the grid (see [multiple solar router architecture](firmware.md#multiple-solar-router-configuration)).

This integration is activated/deactivated with the global `power_meter_activated`. This variable can be modified by a switch in Home Assistant.

!!! warning "Network dependency"
    This power meter requires the network to gather information about energy exchanged with the grid.

## Configuration

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  power_meter:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/power_meter_proxy_client.yaml
        vars:
          power_meter_ip_address: "192.168.1.30"
```

### Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `power_meter_ip_address` | yes | — | IP address of the power meter proxy (or of another solar router exposing the sensors) |
| `power_meter_activated_at_start` | no | `"0"` | Set to `"1"` to activate the power meter at boot |
| `power_sign` | no | `"1"` | Polarity multiplier (`"-1"` to invert the sign of received values) |
| `consumption_sensor_internal` | no | `"false"` | Set to `"true"` to hide the Consumption sensor in Home Assistant |

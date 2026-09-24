# Shelly EM Power Meter

## Description

This power meter reads power consumption directly from a Shelly EM energy meter over HTTP.

This package is activated/deactivated with the global `power_meter_activated`. By default, a power meter is deactivated at startup. The activation switch in Home Assistant determines whether the power meter should run.

!!! warning "Network dependency"
    This power meter requires the network to gather information about energy exchanged with the grid.

## Configuration

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  power_meter:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/power_meter_shelly_em.yaml
        vars:
          power_meter_ip_address: "192.168.1.21"
          emeter_index: "0"
```

If this power meter is used inside a proxy, activate it at startup by setting `power_meter_activated_at_start` to `"1"` in the `vars` section.

### Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `power_meter_ip_address` | yes | — | IP address of the Shelly EM |
| `emeter_index` | yes | — | Shelly EM channel index (`"0"` or `"1"`) |
| `power_meter_auth_header` | no | — | HTTP Authorization header (Basic auth) if the Shelly requires authentication |
| `power_meter_activated_at_start` | no | `"0"` | Set to `"1"` to activate the power meter at boot (required for proxy use) |
| `power_sign` | no | `"1"` | Polarity multiplier (`"-1"` to invert CT orientation) |
| `consumption_sensor_internal` | no | `"false"` | Set to `"true"` to hide the Consumption sensor in Home Assistant |

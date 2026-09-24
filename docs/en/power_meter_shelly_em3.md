# Shelly EM3 Pro / Pro 3EM Power Meter

## Description

This power meter reads power consumption directly from a Shelly EM3 Pro / Pro 3EM three-phase energy meter over HTTP (Gen2/Gen3 "RPC" API).

This package is activated/deactivated with the global `power_meter_activated`. By default, a power meter is deactivated at startup. The activation switch in Home Assistant determines whether the power meter should run.

!!! warning "Network dependency"
    This power meter requires the network to gather information about energy exchanged with the grid.

## Three-phase sum

On a three-phase contract the meter adds the three phases and bills only the **net** value. When one phase produces more (photovoltaic) than the other two consume, that is the right time to divert energy.

This power meter therefore uses the *arithmetic sum* of the three phase active powers as the grid-exchange signal:

```
S_grid = a_act_power + b_act_power + c_act_power  ==  total_act_power
```

* `+` sign : power is taken from the grid
* `-` sign : power is pushed back to the grid

With routing on the 3-phase sum, the solar router diverts energy only when the whole installation is in surplus, never importing from the grid to run the load.

## Configuration

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  power_meter:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/power_meter_shelly_em3.yaml
        vars:
          power_meter_ip_address: "192.168.1.21"
```

If this power meter is used inside a proxy, activate it at startup by setting `power_meter_activated_at_start` to `"1"` in the `vars` section.

### Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `power_meter_ip_address` | yes | — | IP address of the Shelly EM3 Pro / Pro 3EM |
| `power_meter_emeter_id` | no | `"0"` | EM component id if it differs from the default |
| `power_meter_auth_header` | no | `""` | HTTP Authorization header (Basic auth) if the Shelly requires authentication |
| `show_phase_power` | no | `"False"` | Set to `"True"` to expose per-phase active power sensors in Home Assistant |
| `power_meter_activated_at_start` | no | `"0"` | Set to `"1"` to activate the power meter at boot (required for proxy use) |
| `power_sign` | no | `"1"` | Polarity multiplier (`"-1"` to invert CT orientation) |
| `consumption_sensor_internal` | no | `"true"` | Hide the unused Consumption sensor in Home Assistant (kept `"true"` by default for this meter) |

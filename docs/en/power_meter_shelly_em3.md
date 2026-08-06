# Shelly EM3 Pro / Pro 3EM Power Meter

This power meter is designed to get power consumption directly from a Shelly EM3 Pro / Pro 3EM three-phase energy meter over HTTP (Gen2/Gen3 "RPC" API).

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  power_meter:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    file: solar_router/power_meter_shelly_em3.yaml
    vars:
      power_meter_ip_address: "192.168.1.21"
```

This package needs to know the IP address of the Shelly EM3 Pro / Pro 3EM. This IP address has to be defined by `power_meter_ip_address` into `vars` section as shown above.

!!! note "Per-phase sensors"
    The package exposes the three per-phase active powers as internal sensors (for tuning). Set `show_phase_power: "True"` in `vars` to make them visible in Home Assistant.

!!! note "HTTP Authentication Header"
    This power meter allow to define HTTP Authentication Header with the variable `power_meter_auth_header`.
    This variable can be set in `vars` section.

!!! note "EM component id"
    If the EM component id of the meter differs from the default, set `power_meter_emeter_id` in `vars`.

## Three-phase sum

On a three-phase contract the meter adds the three phases and bills only the **net** value. When one phase produces more (photovoltaic) than the other two consume, that's the right time to divert energy.

This power meter therefore uses the *arithmetic sum* of the three phase active powers as the grid-exchange signal:

```
S_grid = a_act_power + b_act_power + c_act_power  ==  total_act_power
```

* `+` sign : power is taken from the grid
* `-` sign : power is pushed back to the grid

With routing on the 3-phase sum, the solar router diverts energy only when the whole installation is in surplus, never importing from the grid to run the load.

This package is activated/deactivated with the variable `power_meter_activated`. By default, a power meter is deactivated at startup. The activation switch in home assistant determines if the power meter should be started or not.

This power meter can be use in a proxy (a Solar Router only using a power meter). If this power meter is used in a proxy, it is required to activate it at startup by setting `power_meter_activated_at_start` to `1` in your yaml in the `vars` section defining the power meter configuration :

```yaml linenums="1"
power_meter_activated_at_start: "1"
```

!!! warning "Network dependency"
    This power meter require the network to gather information about energy exchanged with the grid.

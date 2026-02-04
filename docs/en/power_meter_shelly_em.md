# Shelly EM Power Meter

This power meter is designed get power consumption directly from Shelly EM sensor.

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  power_meter:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    file: solar_router/power_meter_shelly_em.yaml
    vars:
      power_meter_ip_address: "192.168.1.21"
      emeter_index: "0"
```

This package needs to know the IP address of the inverter. This IP address has to be defined by `power_meter_ip_address` and `emeter_index` into `vars` section as show upper.

!!! note "HTTP Authentication Header"
    This power meter allow to define HTTP Authentication Header with the variable `power_meter_auth_header`.
    This variable can be set in `vars` section.

This package is activated/deactivated with the variable `power_meter_activated`. By default, a power meter is deactivated at startup. The activation switch in home assistant determines if the power meter should be started or not.

This power meter can be use in a proxy (a Solar Router only using a power meter). If this power meter is used in a proxy, it is required to activate it at startup by setting `power_meter_activated_at_start` to `1` in your yaml in the `vars` section defining the power meter configuration :

```yaml linenums="1"
power_meter_activated_at_start: "1"
```

!!! warning "Network dependency"
    This power meter require the network to gather information about energy exchanged with the grid.

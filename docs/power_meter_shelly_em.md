# Shelly EM Power Meter

This power meter is designed get power consumption directly from Shelly EM sensor.

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  power_meter:
    url: http://github.com/XavierBerger/ESPHome-Solar-Router/
    file: solar_router/power_meter_shelly_em.yaml
    vars:
      power_meter_ip_address: "192.168.1.21"
      emeter_index: "0"
```

This package needs to know the IP address of the inverter. This IP address has to be defined by `power_meter_ip_address` and `emeter_index` into `vars` section as show upper.

!!! note "HTTP Authentication Header"
    This power meter allow to define HTTP Authentication Header with the variable `power_meter_auth_header`.
    This variable can be set in `vars` section.

This power meter can be use in a proxy (a Solar Router only using a power meter) with the following lines:

```yaml linenums="1"
packages:
  power_meter: !include
    url: https://github.com/XavierBerger/Solar-Router-for-ESPHome/
    file: solar_router/power_meter_shelly_em.yaml
    vars:
      power_meter_ip_address: "192.168.1.21"
      emeter_index: "0"
      power_meter_activated_at_start: 1
```

!!! warning "Network dependency"
    This power meter require the network to gather information about energy exchanged with the grid.
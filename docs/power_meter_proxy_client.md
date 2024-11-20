# Proxy Client Power Meter

A **proxy client** is designed to get the power meter values from an other component. This component could be a dedicated device such as an ESP8266 running only one power meter package (See [proxy architecture](firmware.md#power-meter-proxy-configuration)) or it can be another solar router runing a power meter reading the real power exchanged with the grid (See [multiple solar router architecture](firmware.md#multiple-solar-router-configuration)).

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  power_meter:
    url: http://github.com/XavierBerger/ESPHome-Solar-Router/
    file: solar_router/power_meter_proxy.yaml
    vars:
      power_meter_ip_address: "192.168.1.30"
```
This package needs to know the IP address of the inverter. This IP address has to be defined by `power_meter_ip_address` into `vars` section as show upper.

This integration is activated/deactivated with a global variable `power_meter_activated`. This `globals` is provided by an ***engine*** package.

!!! warning "Network dependency"
    This power meter require the network to gather information about energy exchanged with the grid.
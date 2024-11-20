# Fronius Power Meter

This power meter is designed to work with [Fronius Smart Meter](https://www.fronius.com/en-gb/uk/solar-energy/installers-partners/technical-data/all-products/system-monitoring/hardware/fronius-smart-meter/fronius-smart-meter-ts-100a-1) in conjunction with a [Fronius Inverter](https://www.fronius.com/en-gb/uk/solar-energy/installers-partners/technical-data/all-products/inverters/fronius-primo-gen24/fronius-primo-gen24-3-0).

Fronius is providing an *Open Inteface* named [Fronius Solar API](https://www.fronius.com/en-gb/uk/solar-energy/installers-partners/technical-data/all-products/system-monitoring/open-interfaces/fronius-solar-api-json-) which is allowing the quiery the inverter and **locally** get data.

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  power_meter:
    url: http://github.com/XavierBerger/ESPHome-Solar-Router/
    file: solar_router/power_meter_fronius.yaml
    vars:
      power_meter_ip_address: "192.168.1.21"
```

This package needs to know the IP address of the inverter. This IP address has to be defined by `power_meter_ip_address` into `vars` section as show upper.

This power meter can be use in a proxy (a Solar Router only using a power meter) with the following lines:

```yaml linenums="1"
packages:
  power_meter: !include
    url: https://github.com/XavierBerger/Solar-Router-for-ESPHome/
    file: solar_router/power_meter_fronius.yaml
    vars:
      power_meter_ip_address: "192.168.1.21"
      power_meter_activated_at_start: 1
```

!!! warning "Network dependency"
    This power meter require the network to gather information about energy exchanged with the grid.

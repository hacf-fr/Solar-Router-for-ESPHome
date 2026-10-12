# Fronius Power Meter

## Description

This power meter works with a [Fronius Smart Meter](https://www.fronius.com/en-gb/uk/solar-energy/installers-partners/technical-data/all-products/system-monitoring/hardware/fronius-smart-meter/fronius-smart-meter-ts-100a-1) in conjunction with a [Fronius Inverter](https://www.fronius.com/en-gb/uk/solar-energy/installers-partners/technical-data/all-products/inverters/fronius-primo-gen24/fronius-primo-gen24-3-0).

Fronius provides an open interface named [Fronius Solar API](https://www.fronius.com/en-gb/uk/solar-energy/installers-partners/technical-data/all-products/system-monitoring/open-interfaces/fronius-solar-api-json-) which allows querying the inverter and obtaining data **locally**.

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
      - path: solar_router/power_meter_fronius.yaml
        vars:
          power_meter_ip_address: "192.168.1.21"
```

If this power meter is used inside a proxy, activate it at startup by setting `power_meter_activated_at_start` to `"1"` in the `vars` section.

### Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `power_meter_ip_address` | yes | — | IP address of the Fronius inverter |
| `power_meter_activated_at_start` | no | `"0"` | Set to `"1"` to activate the power meter at boot (required for proxy use) |
| `power_sign` | no | `"1"` | Polarity multiplier (`"-1"` to invert CT orientation) |
| `consumption_sensor_internal` | no | `"false"` | Set to `"true"` to hide the Consumption sensor in Home Assistant |

# Home Assistant Recorder configuration

## Description

**Power meters** and **energy sensors** are updated every second.  
By default, the Home Assistant *recorder* saves these values in its database.  
To keep storage under control, exclude the noisiest entities.

This page is part of the [Home Assistant integration](home_assistant.md) guide.

## Configuration

1. **Identify the sensors to filter out**  
   The power meter provides `real_power`.  
   The theoretical energy counter provides sensors such as total energy diverted / power divertion.  
   In Home Assistant they are prefixed with your device name, for example `sensor.solarrouter_real_power` or `sensor.solarrouter_total_energy_diverted`.  
   Check your device entities and adapt the list.

2. **Add a `recorder` exclude block** in `configuration.yaml`:

```yaml
recorder:
  exclude:
    entities:
      - sensor.solarrouter_real_power
      - sensor.solarrouter_total_energy_diverted
      - sensor.solarrouter_power_divertion
```

!!! note "About recorder"
    Home Assistant `recorder` continuously saves data. See the [recorder documentation](https://www.home-assistant.io/integrations/recorder/) for details.  
    **Review the data produced by your solar router and adapt the exclude list to your needs.**

!!! warning "If you are using InfluxDB"
    Apply the same exclusions in InfluxDB.  
    See the [InfluxDB integration](https://www.home-assistant.io/integrations/influxdb/).

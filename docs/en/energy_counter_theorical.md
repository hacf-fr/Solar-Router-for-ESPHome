# Energy Counter Theorical

## Description

**Energy Counter Theorical** calculates the amount of energy diverted to the load based on the **declared load power** (in Watts) and the **diversion level** applied each second by the engine. It is an optional package that adds an estimation of energy savings to your solar router setup.

Because the calculation is purely theoretical, the counter does not require any additional hardware — it relies entirely on the engine's internal `router_level` and the load power value you configure in Home Assistant.

!!! warning "Energy saved reported by this counter is for information only"
    Remember that values are calculated and not measured.  
    The values presented by this sensor are only estimations of energy diverted based on the configuration you made in Home Assistant.

## Configuration

To use this counter, add the following lines to your configuration file.

```yaml
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/energy_counter_theorical.yaml
```

!!! question "What happens if theoretical diverted energy is not consumed?"
    If the water in the boiler is already hot, regulation can rise to 100%, but no energy will be consumed.
    If the power meter provides consumption data, the energy counter detects this situation and reports 0 diverted energy.
    If consumption is not reported, the theoretical diverted energy is calculated at its maximum.

Then you have to define the **load power** in Home Assistant `Control` interface. The power entered has to reflect the power of the element plugged on the solar router.

![alt text](images/SolarRouterEnergyCounterTheoricalConfiguration.png)

The instantaneous and cumulated energy diverted are available in `sensors` interface:

![alt text](images/SolarRouterEnergyCounterTheoricalSensors.png)

### Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| — | — | — | This module has no configuration variables. Load power is set at runtime via Home Assistant. |
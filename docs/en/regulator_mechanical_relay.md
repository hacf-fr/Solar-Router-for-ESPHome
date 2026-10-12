# Mechanical Relay Regulator

## Description

This regulator performs an **All or Nothing Regulation**.

A relay is able to let current pass to the load or not. This is the simplest form of regulation: the load is either fully powered or completely off.

!!! Warning "Be careful during wiring and use the Normally Open (NO) pin."

!!! Danger "This kind of relay can only be used with [Engine 1 x switch](engine_1switch.md) or [Engine 1 x dimmer + 1 x bypass](engine_1dimmer_1bypass.md)"

## Diagram

![All or nothing regulation](images/Regulation_on_off.png)

## Hardware

This regulator works with standard mechanical relays.

## Wiring Diagram

The following schematic shows the wiring of the relay:

![Mechanical relay wiring](images/mechanical_relay.drawio.png)

## Configuration

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  regulator:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/regulator_mechanical_relay.yaml
        vars:
          relay_regulator_gate_pin: GPIO22
```

### Variables

| Variable | Required | Default | Description |
| -------- | -------- | ------- | ----------- |
| `relay_regulator_gate_pin` | yes | — | GPIO pin connected to the gate of the relay. |

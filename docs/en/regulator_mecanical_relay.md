# Mecanical Relay Regulator

This regulator is performing an **All or Nothing Regulation**.

![alt text](images/Regulation_on_off.png)

A relay is able to let current pass to the load or not. 

The following schematic is representing the wiring of the relay:

![relay](images/mecanical_relay.drawio.png)

!!! Warning "Be carefull during wiring and use the Normally Open (NO) pin."

!!! Danger "This kind of relay is only use it with [Engine 1 x switch](engine_1switch.md) or [Engine 1 x dimmer + 1 x bypass](engine_1dimmer_1bypass.md)"

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  regulator:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/regulator_mecanical_relay.yaml
        vars:
          relay_regulator_gate_pin: GPIO22
```

This package require the definition of pin connected to the gate of the relay. Set `relay_regulator_gate_pin` into `vars` according to your hardware

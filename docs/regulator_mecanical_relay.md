# Mecanical Relay Regulator

A relay is able to let current pass to the load or not. 

The following schematic is representing the wiring of the relay:

![relay](images/mecanical_relay.drawio.png)

!!! Warning "Be carefull during wiring and use the Normally Open (NO) pin."

!!! Danger "WARNING : This kind of relay is not compatible with variable engine. Only use it [engine ON/OFF](engine_on_off.md)"

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  regulator:
    url: http://github.com/XavierBerger/ESPHome-Solar-Router/
    file: solar_router/regulator_mecanical_relay.yaml
    vars:
      regulator_gate_pin: GPIO22
```

This package require the definition of pin connected to the gate of the relay. Set `regulator_gate_pin` into `vars` according to your hardware

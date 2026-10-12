# Solid State Relay Regulator

## Description

This regulator performs a **Burst Fire Regulation**.

A relay is able to let current pass to the load or not. By sending small parts of current (blinking), it is possible to divert a well-defined amount of energy to the load.

!!! tip "Tip: This regulator can also be used with a triac"

## Diagram

![Burst fire regulation](images/Regulation_burst_fire.png)

??? note "How does this regulator work?"
    This regulator sends a PWM (Pulse Width Modulation) signal to the relay. The period of the PWM is 330ms. The duty cycle determines the amount of energy transferred.  
    If you want to know more about how a PWM can regulate the transmitted energy, you can refer to [Wikipedia](https://en.wikipedia.org/wiki/Pulse-width_modulation).  
    <figure markdown="span">
      ![Duty cycle examples](images/Duty_Cycle_Examples.png){ width="300" } 
      <figcaption>Duty Cycle examples (Source: Wikipedia)</figcaption>
    </figure>

## Hardware

![Solid State Relay](images/SSR.png)

!!! warning
    It is recommended to attach the relay to a heat sink.

## Wiring Diagram

The following schematic shows the wiring of the relay:

![Solid state relay wiring](images/solid_state_relay.drawio.png)

## Configuration

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  regulator:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/regulator_solid_state_relay.yaml
        vars:
          regulator_gate_pin: GPIO22
```

### Variables

| Variable | Required | Default | Description |
| -------- | -------- | ------- | ----------- |
| `regulator_gate_pin` | yes | — | GPIO pin connected to the gate of the relay. |

# Hybrid Integration of Xavier Berger’s Solar Router

## 1 – Objective: Build a Hybrid Control System for the Solar Router

By design, a solar router starts a load in order to converge toward **zero grid injection** by dynamically modulating its power. In installations with batteries or other active loads, there is no priority management: the solar router is always the last device to be supplied and only consumes surplus energy.

When the solar router is used to power a domestic hot water tank (**DHW**), low-sunlight days may result in insufficient routed energy to properly heat the water. In such cases, energy may need to be supplemented at night during off-peak hours.

In battery-based systems, this is counterproductive because double energy conversion (PV → Battery → Grid) introduces losses and reduces overall system efficiency.

The ideal solution is to:

* Operate the solar router in **manual mode** via Home Assistant when you want to prioritize the router over battery charging.
* Switch it to **automatic mode** when the battery is sufficiently charged and you want to increase routing responsiveness.

Several algorithmic approaches are possible. This document details the solution I use:
[**Solar Optimizer (SO)**](https://github.com/jmcollin78/solar_optimizer) by [Jean-Marc COLLIN](https://github.com/jmcollin78)

---

## 2 – Overview of Solar Optimizer (SO)

Solar Optimizer is a Home Assistant integration that acts as an **energy orchestration engine** for managed devices.

Its objective is **not** to reach zero grid injection, but rather to compute the **most cost-effective energy strategy**.

**SO** can manage multiple devices simultaneously. At each configurable iteration interval, it computes the optimal solution using:

* Grid exchange power sensor
* Electricity purchase cost
* Electricity resale price
* Battery charge/discharge power (if present)
* Battery state of charge (if present)

---

## 3 – Requirements to Use the Solar Router with SO

### ON/OFF Control

The Solar Router does not provide a native ON/OFF switch (only AUTO/MANUAL).
**SO** requires an ON/OFF entity.

Create a template switch using an `input_boolean`.

---

### Power Control

Two Options:

1. Directly control the Solar Router `router_level`
2. Use a **number proxy**
   This method allows reshaping the control setpoint through a correction table to compensate for load non-linearity (recommended).

---

## 4 – Configuring the Solar Router in SO

Refer to the official **SO** documentation if needed:
[https://github.com/jmcollin78/solar_optimizer/blob/main/README-fr.md#configurer-un-%C3%A9quipement-avec-une-puissance-variable](https://github.com/jmcollin78/solar_optimizer/blob/main/README-fr.md#configurer-un-%C3%A9quipement-avec-une-puissance-variable)

### Power Step Configuration

Example: 1800 W water heater
(1% resolution, 10% minimum step)

![Power settings](../images/SO_power_settings.png)

---

### Timing Parameters

For a highly reactive configuration and a resistive load tolerant to frequent switching, the following parameters are used:

![Timing settings](../images/SO_timing_settings.png)

---

### Action Services

Define:

* ON service
* OFF service
* Power level change service

![Service configuration](../images/SO_service_configuration.png)

---

### Division Factor

Used by **SO** to convert real power (0–1800 W) into routing level (0–100%).

![Division factor](../images/SO_division_factor.png)

---

### Optional

* Minimum and maximum daily runtime
* Off-peak hours configuration

(Personally not used — night charging decisions are based on stored daily energy via automation.)

---

## 5 – ON/OFF Template Switch (`input_boolean`)

Since the Solar Router only supports AUTO/MANUAL, an ON/OFF abstraction must be created.

* When switching OFF → Set `router_level` to `0`(This emulates a true OFF behavior)
* When switching ON → No action required (**SO** assigns the power)

### Example Automation

```yaml
alias: Water heater OFF management
description: ""

triggers:
  - trigger: state
    entity_id:
      - input_boolean.on_off_cumulus
    from:
      - "on"

conditions: []

actions:
  - action: input_number.set_value
    target:
      entity_id: input_number.router_level_desired
    data:
      value: 0

mode: single
metadata: {}
```

---

## 6 – Operating Point Proxy (Non-Linear Compensation)

### Architecture

```
input_number.router_level_desired
        ↓
number.router_level_adapted
        ↓
Solar Router router_level
```

**SO** writes an integer between 0 and 100 into:

```
input_number.router_level_desired
```

This represents the desired theoretical power percentage.

`number.router_level_adapted` is a template number applying correction through interpolation.

---

### Template Configuration

```yaml
{% set input_value = states('input_number.router_level_desired') | float %}

{% set points = [
    [0, 0],
    [11, 0.3],
    [15, 0.6],
    [20, 1.1],
    [23, 1.5],
    [25, 1.9],
    [33, 3.9],
    [38, 5.6],
    [45, 9.2],
    [56, 18.9],
    [61, 25],
    [68, 36.1],
    [72, 42.8],
    [80, 56.1],
    [93, 96.7],
    [100, 100]
] %}

{% set interval = points | selectattr("1", "le", input_value) | list %}
{% set prev_point = interval[-1] %}

{% if points.index(prev_point) < (points|length - 1) %}
  {% set next_point = points[points.index(prev_point) + 1] %}
{% else %}
  {% set next_point = prev_point %}
{% endif %}

{% set x1, y1 = prev_point[1], prev_point[0] %}
{% set x2, y2 = next_point[1], next_point[0] %}

{% if x2 != x1 %}
  {% set adapted_value = y1 + (input_value - x1) * (y2 - y1) / (x2 - x1) %}
{% else %}
  {% set adapted_value = y1 %}
{% endif %}

{{ adapted_value | round(1) }}
```

---

Explanations : 

* Updated each time `router_level_desired` changes.
* The `points` table acts as a mapping mechanism to match the requested percentage to the correct router setpoint, ensuring the operating point is as close as possible to the theoretical equivalent. It can be easily derived by measuring the actual load power at different **router_level** percentage setpoints.
* The algorithm simply performs linear interpolation to determine the optimal value.
* The final step is to update the **router_level** of the Solar Router (**SR**).


---

### Automation to update router_level with the calculated value

```yaml
alias: Update solar router level + ON/OFF management
description: ""

triggers:
  - trigger: state
    entity_id:
      - number.router_level_adapted

conditions: []

actions:
  - action: number.set_value
    data:
      value: "{{ states('number.router_level_adapted') | float(0) }}"
    target:
      entity_id: number.solarrouter_router_level

  - if:
      - condition: numeric_state
        entity_id: number.router_level_adapted
        above: 0
    then:
      - action: input_boolean.turn_on
        target:
          entity_id: input_boolean.on_off_cumulus
    else:
      - action: input_boolean.turn_off
        target:
          entity_id: input_boolean.on_off_cumulus

mode: single
```

---

Logic Summary

On each `router_level_adapted` update:

* Update Solar Router `router_level`
* If value = 0 → switch OFF
* If value > 0 → switch ON

![Architecture overview](../images/SO_architecture_overview.png)

---

## 7 – Hybrid Mode Management (AUTO / MANUAL)

An automation dynamically switches:

* Solar Router AUTO/MANUAL mode
* Solar Optimizer device management

based on battery state of charge.

### Logic Used

* Battery > 79% → Solar Router in AUTO mode
* Battery < 80% → Solar Router in MANUAL mode with **SO** control

---

### Example Automation

```yaml
alias: Switch solar router mode based on battery threshold
description: ""

triggers:
  - trigger: numeric_state
    entity_id:
      - sensor.solarman_battery
    above: 79
  - trigger: numeric_state
    entity_id:
      - sensor.solarman_battery
    below: 80

conditions: []

actions:
  - if:
      - condition: numeric_state
        entity_id: sensor.solarman_battery
        above: 79
    then:
      - action: switch.turn_off
        target:
          entity_id: switch.enable_solar_optimizer_cumulus
      - action: switch.turn_on
        target:
          entity_id: switch.solarrouter_activate_solar_routing
      - action: input_boolean.turn_off
        target:
          entity_id: input_boolean.on_off_cumulus
    else:
      - action: switch.turn_off
        target:
          entity_id: switch.solarrouter_activate_solar_routing
      - action: switch.turn_on
        target:
          entity_id: switch.enable_solar_optimizer_cumulus

mode: single
```

---

## 8 – Conclusion

This implementation reflects my personal approach.
Adjustments may be required depending on your installation.

However, it provides a solid technical foundation for designing hybrid solar routing strategies.

In my case, it fully meets the original objective:
**prioritizing water heater usage over battery charge when appropriate.**

---

## 9 – Appendix

General **SO** settings and water heater device configuration:

![SO general settings](../images/SO_general_settings.png)
![Water heater configuration](../images/SO_water_heater_settings.png)

---

## 10 – Credits

[@M3c4tr0x](https://github.com/M3c4tr0x)

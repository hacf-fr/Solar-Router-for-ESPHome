# Blueprint Priority_To_EV

This blueprint is designed to activate and deactivate the solar router when EV requiring charge is connected and enough energy is produced to charge this EV.

## Behavior

The decision is driven by the total available solar surplus, computed as
the sum of the power currently being **diverted** by the router and the
power currently being **exported** to the grid:

```
available_surplus = diverted_power + exported_power
                  = diverted_power - grid_power     (grid_power < 0 when exporting)
```

The blueprint follows this algorithm:

```
// EV is disconnected
IF NOT ev_connected
THEN activate the solar router

// EV is connected and enough surplus is available to run the EV charger
IF ev_connected
   AND available_surplus > ev_charging_threshold          // e.g. 1400 W
       FOR delay_before_deactivation seconds
THEN deactivate the solar router
     (so the diverted portion is released and joins the exported portion,
      giving the EV access to the full surplus)

// EV battery is fully charged - the EV no longer draws power, so
// surplus reappears in the grid export
IF ev_connected
   AND the solar router is deactivated
   AND available_surplus > ev_full_threshold              // e.g. 200 W
       FOR delay_before_activation seconds
THEN activate the solar router.
```

Checking the *sum* (diverted + exported) rather than just the exported
power matters when the router is not yet saturated: even at 30% diversion
with a near-zero grid balance, the routed power alone may already be
enough to feed the EV. This condition would be missed by an export-only
threshold.

## Sign convention

This blueprint assumes the Solar Router firmware default (`power_sign: "1"`),
where `solar_router.real_power` is **positive when energy is imported** from
the grid and **negative when exported**. The two thresholds
(`ev_charging_threshold`, `ev_full_threshold`) are expressed as **positive**
watts (the minimum required surplus magnitude).

To install this blueprint, refer to [Home assistant documention](https://www.home-assistant.io/docs/automation/using_blueprints/).

The URL to use is : [https://raw.githubusercontent.com/XavierBerger/Solar-Router-for-ESPHome/refs/heads/main/blueprints/priority_to_ev.yaml](https://raw.githubusercontent.com/XavierBerger/Solar-Router-for-ESPHome/refs/heads/main/blueprints/priority_to_ev.yaml)

!!! note
    EV connected is a binary sensor. If your EV charge is displaying a string saying id EV is connected or not it will be required to create a custom sensors to create this binary sensor.

    Example for MyEnergi Zappi:

    ```yaml
    template:
        - binary_sensor:
            - name: "EV Connected Status"
              unique_id: ev_connected_status
              state: "{{ is_state('sensor.myenergi_zappi_plug_status', 'EV Connected') }}"
              device_class: plug

    ```
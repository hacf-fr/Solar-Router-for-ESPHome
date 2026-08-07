# Blueprint Priority_To_EV

This blueprint is designed to activate and deactivate the solar router when EV requiring charge is connected and enough energy is produced to charge this EV.

## Behavior

The blueprint follows this algorithm:

```
// EV is disconnected
IF NOT ev_connected
THEN activate the solar router

// EV is connected and drawing power (surplus is being taken by the EV)
IF ev_connected
   AND energy_diversion > max_diverted_energy (%)
   AND grid_power < export_threshold          // exporting more than |export_threshold| W
       FOR delay_before_deactivation seconds
THEN deactivate the solar router

// EV battery is fully charged (surplus flows back to the grid)
IF ev_connected
   AND the solar router is deactivated
   AND grid_power < reactivation_export_threshold   // exporting more than |reactivation_export_threshold| W
       FOR delay_before_activation seconds
THEN activate the solar router.
```

## Sign convention

This blueprint assumes the Solar Router firmware default (`power_sign: "1"`),
where `solar_router.real_power` is **positive when energy is imported** from the
grid and **negative when exported**. The two export thresholds
(`export_threshold`, `reactivation_export_threshold`) are therefore configured
as **negative** watts — e.g. `-500 W` means "exporting at least 500 W".

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
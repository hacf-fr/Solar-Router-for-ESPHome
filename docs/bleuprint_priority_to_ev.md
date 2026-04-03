# Blueprint Priority_To_EV

This blueprint is designed to activate and deactivate the solar router when EV requiring charge is connected and enough energy is produced to charge this EV.

Here is a transcription of the prompt which help me to create this blueprint wiht AI.  
It clearly explain how it behaves:

```
I would like to write a blueprint for Home Assistant that implements the following algorithm: 

// EV is disconnected
IF NOT ev_connected 
THEN activate the solar router

// EV is connected and its battery needs to be charged
IF ev_connected
   AND energy_diversion > max_diverted_energy (%) 
   AND energy_sent_to_grid is greater than excess_energy_threshold 
       FOR delay_before_deactivation in seconds 
THEN deactivate the solar router

// EV battery is fully charged
IF ev_connected
   AND the solar router is deactivated 
   AND the energy sent back to the grid is greater than max_energy_sent 
       FOR delay_before_activation 
THEN activate the solar router.

The blueprint should be written in English and each variable should be commented.
```

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
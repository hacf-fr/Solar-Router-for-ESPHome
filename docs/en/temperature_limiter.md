# Temperature limiters

## Description

A temperature limiter monitors a temperature source and **stops energy diverting when a configurable threshold is reached**. Once the temperature drops back (or rises back for cooling systems) to a safe level, the regulation is **automatically reactivated**.

Two packages are available depending on how the temperature is measured:

| Package | Temperature source | Requires |
| --- | --- | --- |
| [`temperature_limiter_DS18B20.yaml`](temperature_limiter_DS18B20.md) | DS18B20 1-Wire sensor wired directly to the ESP | GPIO pin, DS18B20 probe |
| [`temperature_limiter_home_assistant.yaml`](temperature_limiter_home_assistant.md) | Any sensor exposed in Home Assistant | Home Assistant sensor entity ID |

The 2-threshold regulation is named hysteresis. This mechanism avoids regulation bouncing.
??? Note "More details about hysteresis and Schmitt trigger here"
    The implementation of hysteresis in this package is similar to the electronic circuit named [Schmitt trigger](https://en.wikipedia.org/wiki/Schmitt_trigger). The circuit is named a **trigger** because the output retains its value until the input changes sufficiently to trigger a change.

    ![](images/hysteresis.png)  
    Transfer function of a Schmitt trigger. The horizontal and vertical axes are input voltage and output voltage, respectively. T and −T are the switching thresholds, and M and −M are the output voltage levels.

    ![](images/schmitt_trigger.png)  
    Comparison of the action of an ordinary comparator (A) and a Schmitt trigger (B) on a noisy analog input signal (U). The green dotted lines are the circuit's switching thresholds. The Schmitt trigger tends to remove noise from the signal.

    source: [wikipedia](https://en.wikipedia.org/wiki/Schmitt_trigger)

!!! warning "If temperature is not reachable, `safety_limit` is activated and energy divertion is stopped" 

![HA](images/temperature_limiter_controls.png){ align=left }
!!! note ""
    **Controls**
    
    * ***Restart temperature***  
      Define the temperature when regulation can restart after a safety limit.
    * ***Stop temperature***  
      Define the temperature when regulation is stopped due to threshold reached.
    * ***Use for cooling***  
      When regulation is use on a heating system *restart temperature* has to be lower than *stop temperature*. This is the oposit for a cooling system.

<pre> 




</pre>

![HA](images/temperature_limiter_sensor.png){ align=left }
!!! note ""
    **Sensors**
    
    * ***Safety limit***  
      This binary sensor shows if safety limit is activated or not.
    * ***safety temperature***
      This sensors show the actual temperature which is compared with thresholds. 
<pre> 




</pre>

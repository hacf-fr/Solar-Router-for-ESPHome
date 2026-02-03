# Details on Using a JSY-MK-194T Power Sensor

Two configurations are possible when using this sensor:

- **standalone**: both sensors of the JSY-MK-194T are used (Ch1: sensor on the load, Ch2: household power sensor at the utility meter)
- **hybrid** (example: Home Assistant for real_power measurement + JSY-MK-194T for derived energy): useful if the router is far from the measurement point, or if the contract is zero-injection (you will need to create a virtual sensor in Home Assistant to simulate injection by estimating the potential energy not produced; see for example the project https://github.com/M3c4tr0x/ESP-PowerSunSensor)

## 1 – Common Part: Communication with the JSY-MK-194T

This file manages communication with the board. If you wish, you can expose the JSY-MK-194T measurements in Home Assistant; see the example below.

```yaml
packages:
  solar_router:
    url: https://github.com/XavierBerger/Solar-Router-for-ESPHome/
    refresh: 1s
    files: 
      # JSY-MK-194T management
      - path: solar_router/jsy-mk-194t_common.yaml
        vars:          
          uart_tx_pin: GPIO26
          uart_rx_pin: GPIO27
          uart_baud_rate: 4800
          AP_Ch2_internal: "false" # optional, allows displaying one of the JSY-MK-194T sensors
```

List of available JSY-MK-194T sensors:

```yaml
  U_Ch1_internal: "true"       # Voltage on Channel 1
  I_Ch1_internal: "true"       # Current on Channel 1
  AP_Ch1_internal: "true"      # Active Power on Channel 1
  PAE_Ch1_internal: "true"     # Positive Active Energy on Channel 1
  PF_Ch1_internal: "true"      # Power Factor on Channel 1
  NAE_Ch1_internal: "true"     # Negative Active Energy on Channel 1
  PD_Ch1_internal: "true"      # Power Direction on Channel 1
  PD_Ch2_internal: "true"      # Power Direction on Channel 2
  frequency_internal: "true"   # Frequency
  # Voltage on Channel 2 not implemented => same as Voltage on Channel 1
  I_Ch2_internal: "true"       # Current on Channel 2
  AP_Ch2_internal: "true"      # Active Power on Channel 2
  PAE_Ch2_internal: "true"     # Positive Active Energy on Channel 2
  PF_Ch2_internal: "true"      # Power Factor on Channel 2
  NAE_Ch2_internal: "true"     # Negative Active Energy on Channel 2
```

## 2 – Standalone Mode

This mode allows the router to be 100% autonomous regarding power sensors. Regulation is therefore more precise and faster than when using Home Assistant entities.
Note that this only works if your system injects surplus power into the grid. Otherwise, see the next section.

```yaml
packages:
  solar_router:
    url: https://github.com/XavierBerger/Solar-Router-for-ESPHome/
    refresh: 1s
    files: 
      # JSY-MK-194T management (as seen previously)
      - path: solar_router/jsy-mk-194t_common.yaml
        vars:          
          uart_tx_pin: GPIO26
          uart_rx_pin: GPIO27
          uart_baud_rate: 4800
          AP_Ch2_internal: "false"

      # derived energy measurement via JSY-MK-194T
      - path: solar_router/energy_counter_jsy-mk-194t.yaml

      # in automatic mode, power exchanged with the grid via JSY-MK-194T
      - path: solar_router/power_meter_jsy-mk-194t.yaml
		vars:
		  consumption_sensor_internal: true # Prevents the “Consumption” sensor from being displayed in Home Assistant, as it is never used and remains “unavailable” when using the JSY-MK-194T
```

## 3 – Hybrid Mode

This mode allows the JSY-MK-194T to be used to measure energy on the load only. Grid-level measurement must be done via Home Assistant, using a virtual sensor that reports an estimated injection power.
It is useful in systems with no real grid injection, or where the measurement point is inaccessible or too far away.

```yaml
packages:
  solar_router:
    url: https://github.com/XavierBerger/Solar-Router-for-ESPHome/
    refresh: 1s
    files: 
      - path: solar_router/common.yaml 

      # JSY-MK-194T management
      - path: solar_router/jsy-mk-194t_common.yaml
        vars:          
          uart_tx_pin: GPIO26
          uart_rx_pin: GPIO27
          uart_baud_rate: 4800
          AP_Ch2_internal: "false"

      # derived energy measurement via JSY-MK-194T
      - path: solar_router/energy_counter_jsy-mk-194t.yaml

      # in automatic mode, using JSY-MK-194T for derived energy calculation,
      # grid power measurement via Home Assistant (case where JSY has no access
      # to the measurement, or in zero-injection mode)
      - path: solar_router/power_meter_home_assistant.yaml
        vars:
          main_power_sensor: sensor.puissance_soutiree_reseau_simulee_prevision_filtree_2
          consumption_sensor: sensor.inverter_activepower_load_sys
```

This package needs to know which sensors to use to obtain the energy exchanged with the grid and the energy consumed by the house.
The grid exchange sensor must be defined by `main_power_sensor`, and the consumption sensor by `consumption_sensor`, in the substitutions section of your configuration, as shown above.

- `main_power_sensor` represents the energy exchanged with the grid. It is expected to be in watts (W), positive (>0) when electricity is drawn from the grid and negative (<0) when electricity is fed back into the grid.

- `consumption_sensor` represents the energy consumed by your home. This information allows, for example, calculation of the theoretical rerouted energy.

!!! Warning "Data availability and refresh rate"
    This power meter relies on Home Assistant to collect the value of the energy exchanged with the grid. It also depends on the sensor update frequency. If a sensor updates too slowly, regulation may not work as expected.

    Unlike Home Assistant power meters, native power meters are autonomous and can continue to regulate even if Home Assistant is offline. Some power meters may have direct access to measurements and can even be independent of the network.

# JSY-MK-194T Energy Counter

## Description

The **JSY-MK-194T Energy Counter** measures the actual energy diverted to the load using the **current readings from the JSY-MK-194T dual-channel power meter**. Unlike the theoretical counter, this module uses real hardware measurements rather than calculations based on a declared load power, giving a more accurate account of the energy effectively consumed.

This package shares the UART communication layer with the [JSY-MK-194T power meter](power_meter_jsy-mk-194t.md) via the `jsy-mk-194t_common.yaml` package. Both packages must be included together in your configuration.

![jsy-mk-194t](../images/jsy-mk-194t.png)

## 1 – Common Part: Communication with the JSY-MK-194T

This file manages communication with the board. If you wish, you can expose
JSY-MK-194T measurements in Home Assistant; see the example below.

```yaml
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
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

## 2 – Enabling the Energy Counter

To enable the energy counter, simply add it to your configuration as shown
in the example below:

```yaml
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    refresh: 1s
    files: 
      - path: solar_router/energy_counter_jsy-mk-194t.yaml
```

For a complete implementation example, refer to the
[JSY-MK-194T example](jsy-mk-194t.md).

### Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| — | — | — | This module has no configuration variables. It uses the JSY-MK-194T measurements configured via `jsy-mk-194t_common.yaml`. |

# JSY-MK-194T Power Meter

## Description

The JSY-MK-194T power meter shares common code with the
[JSY-MK-194T energy counter](energy_counter_jsy-mk-194t.md) to communicate with the module.
The rest of this documentation explains how to configure this common part
and how to configure a JSY-MK-194T power meter.

This package reads grid exchange power from channel 2 of the JSY-MK-194T over UART, so it does not require the network.

![jsy-mk-194t](../images/jsy-mk-194t.png)

## 1 – Common Part: Communication with the JSY-MK-194T

This file manages communication with the board. Add `jsy-mk-194t_common.yaml`
and configure the GPIOs according to your hardware as shown in the example below:

```yaml linenums="1"
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

### Variables (common)

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `uart_tx_pin` | yes | — | GPIO pin for UART TX to the JSY-MK-194T |
| `uart_rx_pin` | yes | — | GPIO pin for UART RX from the JSY-MK-194T |
| `uart_baud_rate` | yes | — | UART baud rate (typically `4800`) |
| `U_Ch1_internal` | no | `"true"` | Hide Voltage Ch1 in Home Assistant when `"true"` |
| `I_Ch1_internal` | no | `"true"` | Hide Current Ch1 in Home Assistant when `"true"` |
| `AP_Ch1_internal` | no | `"true"` | Hide Active Power Ch1 in Home Assistant when `"true"` |
| `PAE_Ch1_internal` | no | `"true"` | Hide Positive Active Energy Ch1 when `"true"` |
| `PF_Ch1_internal` | no | `"true"` | Hide Power Factor Ch1 when `"true"` |
| `NAE_Ch1_internal` | no | `"true"` | Hide Negative Active Energy Ch1 when `"true"` |
| `PD_Ch1_internal` | no | `"true"` | Hide Power Direction Ch1 when `"true"` |
| `PD_Ch2_internal` | no | `"true"` | Hide Power Direction Ch2 when `"true"` |
| `frequency_internal` | no | `"true"` | Hide Frequency when `"true"` |
| `U_Ch2_internal` | no | `"true"` | Hide Voltage Ch2 when `"true"` |
| `I_Ch2_internal` | no | `"true"` | Hide Current Ch2 when `"true"` |
| `AP_Ch2_internal` | no | `"true"` | Hide Active Power Ch2 when `"true"` (set `"false"` to expose) |
| `PAE_Ch2_internal` | no | `"true"` | Hide Positive Active Energy Ch2 when `"true"` |
| `PF_Ch2_internal` | no | `"true"` | Hide Power Factor Ch2 when `"true"` |
| `NAE_Ch2_internal` | no | `"true"` | Hide Negative Active Energy Ch2 when `"true"` |

## 2 – Enabling the Power Meter

To enable the power meter, simply add it to your configuration as shown
in the example below:

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    refresh: 1s
    files: 
      - path: solar_router/power_meter_jsy-mk-194t.yaml
        vars:
          consumption_sensor_internal: "true" # Hide unused Consumption sensor in Home Assistant
```

For a complete implementation example, refer to the
[JSY-MK-194T example](jsy-mk-194t.md).

### Variables (power meter)

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `power_meter_activated_at_start` | no | `"0"` | Set to `"1"` to activate the power meter at boot |
| `power_sign` | no | `"1"` | Polarity multiplier (`"-1"` to invert CT orientation) |
| `consumption_sensor_internal` | no | `"false"` | Set to `"true"` to hide the unused Consumption sensor in Home Assistant |

# Power Meter

## Description

A power meter gathers the power exchanged with the grid. Based on this value, the solar router engine decides how much energy to divert to minimise energy sent to the grid.

### Available power meters

| Power meter | Use case |
| --- | --- |
| [`power_meter_home_assistant`](power_meter_home_assistant.md) | Any Home Assistant sensor as source. Convenient, but refresh rate depends on HA. |
| [`power_meter_fronius`](power_meter_fronius.md) | Fronius Smart Meter via the inverter Solar API (local HTTP). |
| [`power_meter_shelly_em`](power_meter_shelly_em.md) | Shelly EM single/dual-channel energy meter (HTTP). |
| [`power_meter_shelly_em3`](power_meter_shelly_em3.md) | Shelly EM3 Pro / Pro 3EM three-phase meter (HTTP RPC API). |
| [`power_meter_jsy-mk-194t`](power_meter_jsy-mk-194t.md) | JSY-MK-194T dual-channel meter over UART (no network required). |
| [`power_meter_proxy_client`](power_meter_proxy_client.md) | Reads `real_power` / `consumption` from another ESPHome device over HTTP. |

**Home Assistant power meter** can use any HA sensor as source but may refresh more slowly than native meters. **Native power meters** talk to the probe directly and refresh faster; some (like the JSY-MK-194T) do not depend on WiFi or Ethernet.

## Using a Power Meter as a Proxy

Every power meter can be used as a proxy. A proxy can be placed near the measurement probe and deliver its measurement to other solar routers over the network.

See [proxy example](example_proxy.md) for implementation details.

!!! important
    ESP8266 and ESP8285 have little memory but can be used as a proxy if SSL support is disabled in `http_request`.

    ```yaml linenums="1"
    http_request:
      esp8266_disable_ssl_support: True
    ```
    See [HTTP Request component](https://esphome.io/components/http_request.html#esp8266-disable-ssl-support) for details.

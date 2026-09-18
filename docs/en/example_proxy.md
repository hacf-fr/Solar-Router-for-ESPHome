# Solar Router using a proxy

The configuration of the **Proxy client** is only using a [Home Assistant power meter](power_meter_home_assistant.md)

```yaml linenums="1"
--8<-- "examples/esp8285-power-meter-proxy.yaml"
```

This configuration the **Solar Router** is using [Proxy client power meter](power_meter_proxy_client.md), [Triac regulator](regulator_triac.md) and [Solar router engine](engine_1dimmer.md).

GPIO pins have been defined to match hardware configuration described [here](hardware.md)

```yaml linenums="1"
--8<-- "examples/esp8266-proxy-client.yaml"
```
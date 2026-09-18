# Routeur solaire utilisant un proxy

La configuration du **client Proxy** utilise uniquement un [compteur de puissance Home Assistant](power_meter_home_assistant.md)


```yaml linenums="1"
--8<-- "examples/esp8285-power-meter-proxy.yaml"
```

Cette configuration du **Routeur Solaire** utilise un [compteur de puissance client Proxy](power_meter_proxy_client.md), un [régulateur Triac](regulator_triac.md) et un [moteur de routeur solaire](engine_1dimmer.md).

Les broches GPIO ont été définies pour correspondre à la configuration matérielle décrite [ici](hardware.md)

```yaml linenums="1"
--8<-- "examples/esp8266-proxy-client.yaml"
```
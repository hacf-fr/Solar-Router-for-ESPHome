# Power Meter

## Description

Un compteur de puissance mesure la puissance échangée avec le réseau électrique. Sur la base de cette valeur, le moteur du routeur solaire décide quelle quantité d'énergie détourner pour minimiser l'énergie injectée sur le réseau.

### Compteurs de puissance disponibles

| Compteur de puissance | Cas d'usage |
| --- | --- |
| [`power_meter_home_assistant`](power_meter_home_assistant.md) | N'importe quel capteur Home Assistant comme source. Pratique, mais le taux de rafraîchissement dépend de HA. |
| [`power_meter_fronius`](power_meter_fronius.md) | Fronius Smart Meter via l'API Solar de l'onduleur (HTTP local). |
| [`power_meter_shelly_em`](power_meter_shelly_em.md) | Compteur d'énergie Shelly EM mono/bi-canal (HTTP). |
| [`power_meter_shelly_em3`](power_meter_shelly_em3.md) | Compteur triphasé Shelly EM3 Pro / Pro 3EM (API HTTP RPC). |
| [`power_meter_jsy-mk-194t`](power_meter_jsy-mk-194t.md) | Compteur bi-canal JSY-MK-194T via UART (sans réseau). |
| [`power_meter_proxy_client`](power_meter_proxy_client.md) | Lit `real_power` / `consumption` depuis un autre appareil ESPHome via HTTP. |

Le **compteur Home Assistant** peut utiliser n'importe quel capteur HA comme source, mais peut se rafraîchir plus lentement que les compteurs natifs. Les **compteurs natifs** dialoguent directement avec la sonde et se rafraîchissent plus vite ; certains (comme le JSY-MK-194T) ne dépendent pas du WiFi ni de l'Ethernet.

## Utiliser un Power Meter comme proxy

Chaque compteur de puissance peut être utilisé comme proxy. Un proxy peut être placé près de la sonde de mesure et transmettre ses mesures à d'autres routeurs solaires via le réseau.

Consultez l'[exemple de proxy](example_proxy.md) pour voir comment le mettre en œuvre.

!!! important
    Les ESP8266 et ESP8285 ont peu de mémoire mais peuvent être utilisés comme proxy si le support SSL est désactivé dans `http_request`.

    ```yaml linenums="1"
    http_request:
      esp8266_disable_ssl_support: True
    ```
    Voir [Composant HTTP Request](https://esphome.io/components/http_request.html#esp8266-disable-ssl-support) pour plus de détails.

# Proxy Client Power Meter

## Description

Un **client proxy** lit les valeurs du compteur de puissance depuis un autre composant. Ce composant peut être un appareil dédié tel qu'un ESP8266 exécutant uniquement un package de compteur de puissance (voir [architecture proxy](firmware.md#configuration-avec-proxy-de-compteur-denergie)) ou un autre routeur solaire exécutant un compteur qui lit la puissance réelle échangée avec le réseau (voir [architecture avec plusieurs routeurs solaires](firmware.md#configuration-avec-plusieurs-routeurs-solaires)).

Cette intégration est activée/désactivée via la globale `power_meter_activated`. Cette variable peut être modifiée par un interrupteur dans Home Assistant.

!!! warning "Dépendance réseau"
    Ce compteur de puissance nécessite le réseau pour recueillir les informations sur l'énergie échangée avec le réseau.

## Configuration

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  power_meter:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/power_meter_proxy_client.yaml
        vars:
          power_meter_ip_address: "192.168.1.30"
```

### Variables

| Variable | Requis | Défaut | Description |
| --- | --- | --- | --- |
| `power_meter_ip_address` | oui | — | Adresse IP du proxy de compteur (ou d'un autre routeur solaire exposant les capteurs) |
| `power_meter_activated_at_start` | non | `"0"` | Mettre à `"1"` pour activer le compteur au démarrage |
| `power_sign` | non | `"1"` | Multiplicateur de polarité (`"-1"` pour inverser le signe des valeurs reçues) |
| `consumption_sensor_internal` | non | `"false"` | Mettre à `"true"` pour masquer le capteur Consumption dans Home Assistant |

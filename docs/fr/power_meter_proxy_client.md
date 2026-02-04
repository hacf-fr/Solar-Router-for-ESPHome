# Client proxy pour *power meter*

Un **client proxy** est conçu pour obtenir les valeurs du *power meter* à partir d'un autre composant. Ce composant peut être un appareil dédié tel qu'un ESP8266 exécutant uniquement un package de *power meter* (Voir [architecture proxy](firmware.md#configuration-avec-proxy-de-compteur-denergie)) ou il peut s'agir d'un autre routeur solaire exécutant un *power meter* qui lit la puissance réelle échangée avec le réseau (Voir [architecture avec plusieurs routeurs solaires](firmware.md#configuration-avec-plusieurs-routeurs-solaires)).

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  power_meter:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/power_meter_proxy.yaml
        vars:
          power_meter_ip_address: "192.168.1.30"
```

Cette intégration doit connaître l'adresse IP du proxy du *power meter*. Cette adresse IP doit être définie dans `power_meter_ip_address` dans la section `vars` de votre configuration, comme dans l'exemple ci-dessus.

Cette intégration est activée/désactivée avec une variable globale `power_meter_activated`. Cette variable peut être modifiée par un interrupteur dans Home Assistant.

!!! warning "Dépendance au réseau"
    Ce *power meter* nécessite le réseau pour recueillir des informations sur l'énergie échangée avec le réseau.


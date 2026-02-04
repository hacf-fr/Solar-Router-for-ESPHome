# Power meter Fronius

Ce *power meter* est conçu pour fonctionner avec le [Fronius Smart Meter](https://www.fronius.com/en-gb/uk/solar-energy/installers-partners/technical-data/all-products/system-monitoring/hardware/fronius-smart-meter/fronius-smart-meter-ts-100a-1) en conjonction avec un [Onduleur Fronius](https://www.fronius.com/en-gb/uk/solar-energy/installers-partners/technical-data/all-products/inverters/fronius-primo-gen24/fronius-primo-gen24-3-0).

Fronius fournit une *Interface Ouverte* appelée [Fronius Solar API](https://www.fronius.com/en-gb/uk/solar-energy/installers-partners/technical-data/all-products/system-monitoring/open-interfaces/fronius-solar-api-json-) qui permet d'interroger l'onduleur et d'obtenir des données **localement**.

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :


```yaml linenums="1"
packages:
  power_meter:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/power_meter_fronius.yaml
        vars:
          power_meter_ip_address: "192.168.1.21"
```

Cette intégration doit connaître l'adresse IP du proxy du *power meter*. Cette adresse IP doit être définie dans `power_meter_ip_address` dans la section `vars` de votre configuration, comme dans l'exemple ci-dessus.

Ce package est activé/désactivé à l'aide d'une variable globale `power_meter_activated`. Par défaut, un compteur de puissance est désactivé au démarrage. L'interrupteur d'activation dans home assistant détermine si le compteur de puissance doit être démarré ou non.

Si ce compteur de puissance est utilisé à l'intérieur d'un proxy, il est nécessaire de l'activer au démarrage en définissant `power_meter_activated_at_start` à `1` dans votre fichier de configuration yaml, comme dans l'exemple ci-dessous :

```yaml linenums="1"
power_meter_activated_at_start: "1"
```

!!! warning "Dépendance réseau"
    Ce compteur électrique nécessite une connexion réseau pour recueillir des informations sur l'énergie échangée avec le réseau électrique.


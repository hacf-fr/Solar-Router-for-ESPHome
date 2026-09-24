# Fronius Power Meter

## Description

Ce compteur de puissance fonctionne avec un [Fronius Smart Meter](https://www.fronius.com/en-gb/uk/solar-energy/installers-partners/technical-data/all-products/system-monitoring/hardware/fronius-smart-meter/fronius-smart-meter-ts-100a-1) associé à un [onduleur Fronius](https://www.fronius.com/en-gb/uk/solar-energy/installers-partners/technical-data/all-products/inverters/fronius-primo-gen24/fronius-primo-gen24-3-0).

Fronius fournit une interface ouverte appelée [Fronius Solar API](https://www.fronius.com/en-gb/uk/solar-energy/installers-partners/technical-data/all-products/system-monitoring/open-interfaces/fronius-solar-api-json-) qui permet d'interroger l'onduleur et d'obtenir des données **localement**.

Ce package est activé/désactivé via la globale `power_meter_activated`. Par défaut, un compteur de puissance est désactivé au démarrage. L'interrupteur d'activation dans Home Assistant détermine si le compteur doit tourner.

!!! warning "Dépendance réseau"
    Ce compteur de puissance nécessite le réseau pour recueillir les informations sur l'énergie échangée avec le réseau électrique.

## Configuration

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

Si ce compteur est utilisé à l'intérieur d'un proxy, activez-le au démarrage en définissant `power_meter_activated_at_start` à `"1"` dans la section `vars`.

### Variables

| Variable | Requis | Défaut | Description |
| --- | --- | --- | --- |
| `power_meter_ip_address` | oui | — | Adresse IP de l'onduleur Fronius |
| `power_meter_activated_at_start` | non | `"0"` | Mettre à `"1"` pour activer le compteur au démarrage (requis en mode proxy) |
| `power_sign` | non | `"1"` | Multiplicateur de polarité (`"-1"` pour inverser l'orientation du TC) |
| `consumption_sensor_internal` | non | `"false"` | Mettre à `"true"` pour masquer le capteur Consumption dans Home Assistant |

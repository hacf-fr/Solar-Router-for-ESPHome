# Shelly EM Power Meter

## Description

Ce compteur de puissance lit la consommation directement depuis un compteur d'énergie Shelly EM via HTTP.

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
      - path: solar_router/power_meter_shelly_em.yaml
        vars:
          power_meter_ip_address: "192.168.1.21"
          emeter_index: "0"
```

Si ce compteur est utilisé à l'intérieur d'un proxy, activez-le au démarrage en définissant `power_meter_activated_at_start` à `"1"` dans la section `vars`.

### Variables

| Variable | Requis | Défaut | Description |
| --- | --- | --- | --- |
| `power_meter_ip_address` | oui | — | Adresse IP du Shelly EM |
| `emeter_index` | oui | — | Index du canal Shelly EM (`"0"` ou `"1"`) |
| `power_meter_auth_header` | non | — | En-tête HTTP Authorization (Basic auth) si le Shelly exige une authentification |
| `power_meter_activated_at_start` | non | `"0"` | Mettre à `"1"` pour activer le compteur au démarrage (requis en mode proxy) |
| `power_sign` | non | `"1"` | Multiplicateur de polarité (`"-1"` pour inverser l'orientation du TC) |
| `consumption_sensor_internal` | non | `"false"` | Mettre à `"true"` pour masquer le capteur Consumption dans Home Assistant |

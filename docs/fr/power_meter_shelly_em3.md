# Shelly EM3 Pro / Pro 3EM Power Meter

## Description

Ce compteur de puissance lit la consommation directement depuis un compteur d'énergie triphasé Shelly EM3 Pro / Pro 3EM via HTTP (API Gen2/Gen3 « RPC »).

Ce package est activé/désactivé via la globale `power_meter_activated`. Par défaut, un compteur de puissance est désactivé au démarrage. L'interrupteur d'activation dans Home Assistant détermine si le compteur doit tourner.

!!! warning "Dépendance réseau"
    Ce compteur de puissance nécessite le réseau pour recueillir les informations sur l'énergie échangée avec le réseau électrique.

## Somme triphasée

Sur un abonnement triphasé, le compteur additionne les trois phases et ne facture que la valeur **nette**. Lorsqu'une phase produit plus (photovoltaïque) que les deux autres ne consomment, c'est le bon moment pour détourner l'énergie.

Ce compteur utilise donc la *somme arithmétique* des trois puissances actives par phase comme signal d'échange avec le réseau :

```
S_grid = a_act_power + b_act_power + c_act_power  ==  total_act_power
```

* signe `+` : l'énergie est prélevée du réseau
* signe `-` : l'énergie est réinjectée sur le réseau

Avec le détournement sur la somme triphasée, le routeur solaire ne détourne l'énergie que lorsque toute l'installation est en surplus, sans jamais prélever du réseau pour alimenter la charge.

## Configuration

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  power_meter:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/power_meter_shelly_em3.yaml
        vars:
          power_meter_ip_address: "192.168.1.21"
```

Si ce compteur est utilisé à l'intérieur d'un proxy, activez-le au démarrage en définissant `power_meter_activated_at_start` à `"1"` dans la section `vars`.

### Variables

| Variable | Requis | Défaut | Description |
| --- | --- | --- | --- |
| `power_meter_ip_address` | oui | — | Adresse IP du Shelly EM3 Pro / Pro 3EM |
| `power_meter_emeter_id` | non | `"0"` | Identifiant du composant EM s'il diffère de la valeur par défaut |
| `power_meter_auth_header` | non | `""` | En-tête HTTP Authorization (Basic auth) si le Shelly exige une authentification |
| `show_phase_power` | non | `"False"` | Mettre à `"True"` pour exposer les capteurs de puissance active par phase dans Home Assistant |
| `power_meter_activated_at_start` | non | `"0"` | Mettre à `"1"` pour activer le compteur au démarrage (requis en mode proxy) |
| `power_sign` | non | `"1"` | Multiplicateur de polarité (`"-1"` pour inverser l'orientation du TC) |
| `consumption_sensor_internal` | non | `"true"` | Masque le capteur Consumption inutilisé dans Home Assistant (conservé à `"true"` par défaut pour ce compteur) |

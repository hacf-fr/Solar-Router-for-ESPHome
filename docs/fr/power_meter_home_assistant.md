# Home Assistant Power Meter

## Description

Ce compteur de puissance lit la consommation directement depuis des capteurs Home Assistant.

* `main_power_sensor` représente la puissance échangée avec le réseau. Il est attendu en Watts (W), positif (> 0) lorsque l'électricité est consommée depuis le réseau, et négatif (< 0) lorsque l'électricité est envoyée au réseau.

* `consumption_sensor` représente la puissance consommée par votre maison. Cette valeur sert, par exemple, au calcul de l'énergie détournée.

!!! warning "Disponibilité des données et fréquence de rafraîchissement"
    Ce compteur s'appuie sur Home Assistant pour recueillir la valeur de l'énergie échangée avec le réseau. Il dépend également de la fréquence de mise à jour des capteurs. Si un capteur est mis à jour trop lentement, la régulation peut ne pas fonctionner comme prévu.

    Contrairement à ce compteur Home Assistant, les compteurs natifs sont autonomes et peuvent continuer à réguler même si Home Assistant est hors ligne. Certains compteurs ont un accès direct aux mesures et peuvent même être indépendants du réseau.

## Configuration

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/power_meter_home_assistant.yaml
        vars:
          main_power_sensor: "sensor.smart_meter_ts_100a_1_puissance_reelle"
          consumption_sensor: "sensor.solarnet_power_load_consumed"
```

### Variables

| Variable | Requis | Défaut | Description |
| --- | --- | --- | --- |
| `main_power_sensor` | oui | — | Identifiant d'entité Home Assistant pour la puissance d'échange réseau (W) |
| `consumption_sensor` | oui | — | Identifiant d'entité Home Assistant pour la consommation de la maison (W) |
| `power_sign` | non | `"1"` | Multiplicateur de polarité (`"-1"` pour inverser le signe de `main_power_sensor`) |

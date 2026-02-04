# Power meter pour Home Assistant

Ce *power meter* est conçu pour obtenir la consommation électrique directement à partir d'un capteur Home Assistant.

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

Ce package doit connaître le capteur à utiliser pour obtenir l'énergie échangée avec le réseau et l'énergie consommé par la maison. Le capteur déchange d'énergie avec le réseau doit être défini par `main_power_sensor` et la capteur de consommation par `consumption_sensor` dans la section `substitutions` de votre configuration comme présenté dans l'exemple ci-dessus.

* `main_power_sensor` représent l'energie echangée avec le réseau. Il est attendu que ce capteur soit en Watts (W), qu'il soit positif (>0) lorsque l'électricité est consommée depuis le réseau et négatif (<0) lorsque l'électricité est envoyée au réseau. 

* `consumption_sensor` représente l'énergie consomée par votre maison. Cette imformation permet, par exemple, le calcul de l'énergie théorique reroutée.

!!! warning "Disponibilité des données et fréquence de rafraîchissement"
    Ce compteur électrique s'appuie sur Home Assistant pour recueillir la valeur de l'énergie échangée avec le réseau. Il dépend également de la fréquence de mise à jour des capteurs. Si un capteur est mis à jour trop lentement, la régulation peut ne pas fonctionner comme prévu.

    Contrairement aux compteurs électriques de Home Assistant, les compteurs électriques natifs sont autonomes et peuvent continuer à réguler même si Home Assistant est hors ligne. Certains compteurs électriques peuvent avoir un accès direct aux mesures et peuvent même être indépendants du réseau.


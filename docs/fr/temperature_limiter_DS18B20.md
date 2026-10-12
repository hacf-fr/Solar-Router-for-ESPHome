# Temperature limiter DS18B20

## Description

Ce package surveille la température provenant d'un **capteur 1-Wire DS18B20** câblé directement sur la carte ESP et détermine si un seuil de température a été atteint. Lorsque la limite de sécurité est déclenchée, le détournement d'énergie est arrêté et, en option, une LED rouge s'allume pour signaler l'état de sécurité.

Le DS18B20 est un capteur de température numérique qui communique sur un seul fil de données, ce qui facilite son intégration sans circuit supplémentaire au-delà d'une résistance de tirage (pull-up).

!!! danger "AVERTISSEMENT : Effectuez des tests avant de laisser le système réguler seul"
    Cette surveillance de la limite de température et la limite de sécurité peuvent comporter des bugs. Il est fortement conseillé de valider soigneusement le comportement de votre système avant de le laisser fonctionner de manière autonome.

Le schéma suivant représente le câblage du capteur de température :

![DS18B20](images/DS18B20_wiring.png){width=400}

## Configuration

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  temperature_limiter:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files: 
      - path: solar_router/temperature_limiter_DS18B20.yaml
        vars:
          DS18B20_pin: GPIO13
          temperature_update_interval: 1s
          red_led_inverted: "False"
          red_led_pin: GPIO4
```

### Variables

| Variable | Requis | Défaut | Description |
| --- | --- | --- | --- |
| `DS18B20_pin` | oui | — | Broche GPIO connectée au fil de données du DS18B20 |
| `DS18B20_address` | non | `"0"` | Adresse ROM du capteur (utile avec plusieurs capteurs sur le même bus) |
| `temperature_update_interval` | non | `5s` | Intervalle de scrutation pour la lecture de la température |
| `red_led_pin` | oui | — | Broche GPIO pour la LED rouge de sécurité |
| `red_led_inverted` | non | `"False"` | Mettre à `"True"` si la LED rouge est active à l'état bas |

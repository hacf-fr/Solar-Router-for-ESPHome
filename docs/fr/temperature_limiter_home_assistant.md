# Temperature limiter Home Assistant

## Description

Ce package surveille une température provenant de **n'importe quel capteur disponible dans Home Assistant** et détermine si un seuil de température a été atteint. Lorsque la limite de sécurité est déclenchée, le détournement d'énergie est arrêté et, en option, une LED rouge s'allume pour signaler l'état de sécurité.

Cette approche est idéale lorsqu'un capteur de température est déjà intégré dans Home Assistant (par exemple une sonde Zigbee, un thermostat connecté ou toute autre plateforme), évitant ainsi de câbler un capteur supplémentaire sur l'ESP.

!!! danger "AVERTISSEMENT : Effectuez des tests avant de laisser le système réguler seul"
    Cette surveillance de limite de température et la limite de sécurité peuvent comporter des bugs. Il est fortement conseillé de valider soigneusement le comportement de votre système avant de le laisser fonctionner de manière autonome.

## Configuration

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  temperature_limiter:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/temperature_limiter_home_assistant.yaml
        vars:
          temperature_sensor: "input_number.test_temperature"
          red_led_pin: GPIO4
```

!!! warning "Disponibilité des données et taux de rafraîchissement"
    Ce limiteur de température dépend de Home Assistant pour récupérer la température. Il dépend également du taux de mise à jour du capteur. Si un capteur est mis à jour trop lentement, la régulation peut ne pas fonctionner comme prévu.

### Variables

| Variable | Requis | Défaut | Description |
| --- | --- | --- | --- |
| `temperature_sensor` | oui | — | Identifiant de l'entité Home Assistant du capteur de température à surveiller |
| `red_led_pin` | oui | — | Broche GPIO pour la LED rouge de sécurité |
| `red_led_inverted` | non | `"False"` | Mettre à `"True"` si la LED rouge est active à l'état bas |

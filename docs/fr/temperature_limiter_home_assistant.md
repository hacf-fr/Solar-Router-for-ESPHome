# Temperature limiter Home Assistant

Ce package est conçu pour surveiller une température provenant d'un capteur dans Home Assistant et déterminer si un seuil de température a été atteint ou non.

Lorsque la limite de sécurité est atteinte, il est possible d'allumer une LED. La configuration de la LED doit être ajoutée dans la section `substitutions` comme expliqué ci-dessous.

!!! danger "AVERTISSEMENT : Effectuez des tests avant de laisser le système réguler seul"
    Cette surveillance de limite de température et la limite de sécurité peuvent comporter des bugs. Il est fortement conseillé de valider soigneusement le comportement de votre système avant de le laisser fonctionner de manière autonome.

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

Ce package doit connaître le capteur à utiliser pour obtenir la température à surveiller. Ce capteur doit être défini par `temperature_sensor` dans la section `vars` de votre configuration, comme dans l'exemple ci-dessus.

Additionnal optional parameters can be set into `vars` section such as `red_led_inverted` defining if the LED is active on high or low level of pin (which is set default set to `False`).

!!! warning "Disponibilité des données et taux de rafraîchissement"
    Ce limiteur de température dépend de Home Assistant pour récupérer la température. Il dépend également du taux de mise à jour du capteur. Si un capteur est mis à jour trop lentement, la régulation peut ne pas fonctionner comme prévu.


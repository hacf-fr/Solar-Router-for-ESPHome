# Temperature limiter DS18B20

Ce package est conçu pour surveiller la température provenant d'un capteur DS18B20 connecté à un ESP32 et déterminer si un seuil de température a été atteint ou non.

Lorsque la limite de sécurité est atteinte, il est possible d'allumer une LED. La configuration de la LED doit être ajoutée dans la section `substitutions` comme expliqué ci-dessous.

!!! danger "AVERTISSEMENT : Effectuez des tests avant de laisser le système réguler seul"
    Cette surveillance de la limite de température et la limite de sécurité peuvent comporter des bugs. Il est fortement conseillé de valider soigneusement le comportement de votre système avant de le laisser fonctionner de manière autonome.

Le schéma suivant représente le câblage du capteur de température :

![DS18B20](images/DS18B20_wiring.png){width=400}

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

Ce package doit connaître le GPIO utilisé par le capteur de température pour obtenir la température. Ce GPIO doit être défini par `DS18B20_pin` dans la section `vars` de votre configuration, comme dans l'exemple ci-dessus.

Des paramètres optionnels supplémentaires peuvent être définis dans la section `vars`, tels que `DS18B20_address` (qui est optionnel) et `temperature_update_interval` (qui est défini par défaut à `5s`).

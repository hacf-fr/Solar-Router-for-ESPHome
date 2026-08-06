# Sécurité de la carte gradateur (RobotDyn AC Dimmer 40 A "avec capteur de courant")

Ce package ajoute une sécurité locale pour le **RobotDyn AC Dimmer 40 A "avec capteur de courant"** (variante premium : NTC dissipateur + ventilateur 5 V + capteur de courant CT intégré).

Il fournit trois niveaux de protection :

1. **Limiteur de température du dissipateur** — fonctionne sans WiFi ni Home Assistant :
   - dissipateur >= `heatsink_stop_temperature` → `safety_limit = True` (le moteur passe à 0 %)
   - dissipateur <= `heatsink_restart_temperature` → `safety_limit = False`
   - panne du capteur de température (NaN) → `safety_limit = True` (sécurité intrinsèque)

2. **Coupure surintensité** — courant de charge >= `overcurrent_current` → `safety_limit = True`
   - débloqué une fois le courant repassé sous `overcurrent_restart_current`

3. **Alarmes de santé** (informatives, pas de coupure) :
   - *Triac Stuck ON* : courant circulant alors que le régulateur est fermé (triac en court-circuit)
   - *Boiler Not Powered* : régulateur ouvert mais aucun courant (triac mort / gâchette)
   - *Current Sensor Failure* : sortie CT illisible

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  safety:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    file: solar_router/dimmer_safety.yaml
    vars:
      dimmer_temp_pin: GPIO34
      dimmer_current_pin: GPIO35
      red_led_pin: GPIO21
```

!!! note "Un SEUL package de limitation de sécurité"
    Ce package possède la variable globale partagée `safety_limit` (comme les
    packages *temperature limiter*). N'incluez qu'un seul package de limitation
    de sécurité dans une configuration.

## Variables

| Variable | Défaut | Description |
|---|---|---|
| `dimmer_temp_pin` | `GPIO34` | Entrée NTC du dissipateur (ADC1 ESP32, broches input-only 32–39) |
| `dimmer_current_pin` | `GPIO35` | Entrée du capteur de courant CT (ADC1 ESP32) |
| `red_led_pin` | `GPIO21` | Sortie LED de sécurité |
| `heatsink_stop_temperature` | `80` | Température de coupure (°C) |
| `heatsink_restart_temperature` | `60` | Température de redémarrage (°C) |
| `overcurrent_current` | `12.0` | Seuil de surintensité (A RMS) |
| `overcurrent_restart_current` | `8.0` | Seuil de redémarrage surintensité (A RMS) |
| `current_calibration_factor` | `1.0` | Calibration du CT (A par V sur la broche CUR), à régler sur banc |

La calibration NTC (`ntc_reference_*`, `ntc_b_coefficient`, `ntc_configuration`) peut être ajustée pour correspondre au diviseur de la carte — voir la procédure de banc.

!!! warning "Entrées analogiques"
    `dimmer_temp_pin` et `dimmer_current_pin` doivent être des broches ADC1 de l'ESP32 (broches input-only 32–39).

# Capteurs de debug

## Description

Le package de capteurs de debug expose des informations de diagnostic ESPHome dans Home Assistant pour la surveillance et le dépannage (heap, temps de boucle, raison de reset, etc.).

Cette page fait partie du guide d'[intégration Home Assistant](home_assistant.md).

![Debug Sensors](images/diagnostics.png){ align=center }

## Configuration

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    refresh: 1d
    files: 
      - path: solar_router/debug_sensors.yaml
```

### Variables

| Variable | Requis | Défaut | Description |
| --- | --- | --- | --- |
| — | — | — | Ce package n'a pas de variables de configuration. |

!!! note "Matériel"
    Le package active les capteurs `debug` d'ESPHome et déclare un bloc PSRAM. Utilisez-le sur des cartes qui supportent ces fonctions (typiquement ESP32).

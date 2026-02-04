# debug sensors

Permet de remonter certaines informations dans Home Assistant pour la mise au point et la surveillance.

![Debug Sensors](images/diagnostics.png){ align=center }
 
Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    refresh: 1d
    files: 
      - path: solar_router/debug_sensors.yaml
```

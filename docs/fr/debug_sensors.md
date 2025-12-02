# debug sensors

Permet de remonter certaines informations dans Home Assistant pour la mise au point et la surveillance.

<img width="322" height="663" alt="image" src="https://github.com/user-attachments/assets/100217d4-8056-4abb-91b7-7876b9944a9b" />
 
Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :
```packages:
  solar_router:
    url: https://github.com/M3c4tr0x/Solar-Router-for-ESPHome/
    refresh: 1s
    files: 
      # ajout des capteurs pour le debug
      - path: solar_router/debug_sensors.yaml```

# Configuration du Recorder Home Assistant

## Description

Les **compteurs de puissance** et les **capteurs d'énergie** sont mis à jour chaque seconde.  
Par défaut, le *recorder* de Home Assistant enregistre ces valeurs dans sa base de données.  
Pour maîtriser le stockage, excluez les entités les plus bruyantes.

Cette page fait partie du guide d'[intégration Home Assistant](home_assistant.md).

## Configuration

1. **Identifiez les capteurs à filtrer**  
   Le compteur de puissance fournit `real_power`.  
   Le compteur d'énergie théorique fournit des capteurs tels que l'énergie détournée totale / power divertion.  
   Dans Home Assistant, ils sont préfixés par le nom de votre appareil, par exemple `sensor.solarrouter_real_power` ou `sensor.solarrouter_total_energy_diverted`.  
   Vérifiez les entités de votre appareil et adaptez la liste.

2. **Ajoutez un bloc d'exclusion `recorder`** dans `configuration.yaml` :

```yaml
recorder:
  exclude:
    entities:
      - sensor.solarrouter_real_power
      - sensor.solarrouter_total_energy_diverted
      - sensor.solarrouter_power_divertion
```

!!! note "À propos du recorder"
    Le `recorder` de Home Assistant enregistre en continu. Voir la [documentation du recorder](https://www.home-assistant.io/integrations/recorder/) pour plus de détails.  
    **Examinez les données produites par votre routeur solaire et adaptez la liste d'exclusion à vos besoins.**

!!! warning "Si vous utilisez InfluxDB"
    Appliquez les mêmes exclusions dans InfluxDB.  
    Voir l'[intégration InfluxDB](https://www.home-assistant.io/integrations/influxdb/).

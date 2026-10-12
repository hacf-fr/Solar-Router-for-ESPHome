# Intégration Home Assistant

## Description

Les appareils **Solar-Router-for-ESPHome** apparaissent dans Home Assistant via l'intégration native [ESPHome](https://www.home-assistant.io/integrations/esphome/). Une fois adoptés, HA expose des interrupteurs, nombres, capteurs et lumières pour surveiller et piloter le routeur.

Cette page est le point d'entrée central pour les sujets Home Assistant. Pages détaillées :

| Sujet | Page |
| --- | --- |
| Réduire la croissance de la base | [Configuration du recorder](recorder_configuration.md) |
| Capteurs de diagnostic supplémentaires | [Capteurs de debug](debug_sensors.md) |
| Quels packages sont chargés | [Versions des modules](module_version.md) |
| Priorité du surplus à un chargeur VE | [Blueprint — Priorité au VE](blueprint_priority_to_ev.md) |
| Puissance depuis des capteurs HA | [Compteur de puissance Home Assistant](power_meter_home_assistant.md) |
| Sécurité température depuis HA | [Limiteur de température Home Assistant](temperature_limiter_home_assistant.md) |

## Adoption

1. Flashez un appareil ESPHome vide et adoptez-le dans Home Assistant (voir [Installation](installation.md)).
2. Ajoutez les packages Solar Router au YAML de l'appareil et téléversez via OTA.
3. Les entités apparaissent sur la page de l'appareil. Les noms sont préfixés par le nom de votre appareil (les exemples ci-dessous utilisent `solarrouter`).

!!! tip "Masquer les entités bruyantes"
    Par défaut, l'ouverture du régulateur et les LED sont masquées (`hide_regulators` / `hide_leds`). Mettez-les à `'False'` dans les `vars` de l'engine pour les exposer dans HA. Voir [Aperçu des engines](engine.md).

## Entités principales

Les identifiants d'entités dépendent du nom de votre appareil. La colonne **Nom** est ce qu'ESPHome publie.

### Contrôle

| Nom | Entité typique | Rôle |
| --- | --- | --- |
| Activate Solar Routing | `switch.solarrouter_activate_solar_routing` | Active la régulation automatique et la scrutation du compteur |
| Router Level | `number.solarrouter_router_level` | Niveau de routage principal 0–100 % (à préférer à l'ouverture du régulateur) |
| Target grid exchange | `number.solarrouter_target_grid_exchange` | Cible d'échange réseau en W (0 = pas d'échange ; &lt;0 continuer à exporter ; &gt;0 autoriser un léger import) |
| Up Reactivity | `number.solarrouter_up_reactivity` | Vitesse de montée du niveau quand le surplus augmente |
| Down Reactivity | `number.solarrouter_down_reactivity` | Vitesse de descente du niveau quand le surplus diminue |
| Regulator Opening | `number.solarrouter_regulator_opening` | Ouverture physique du régulateur (souvent masquée) |

### Supervision

| Nom | Entité typique | Rôle |
| --- | --- | --- |
| Real Power | `sensor.solarrouter_real_power` | Échange réseau (W). Positif = import, négatif = export |
| Consumption | `sensor.solarrouter_consumption` | Consommation de la maison lorsque fournie par le compteur |
| Power divertion | `sensor.solarrouter_power_divertion` | Puissance détournée instantanée (avec compteur d'énergie) |
| Total energy diverted | `sensor.solarrouter_total_energy_diverted` | Énergie détournée cumulée (compteur théorique) |

### Sécurité (si limiteur de température installé)

| Nom | Entité typique | Rôle |
| --- | --- | --- |
| Safety limit reached | `binary_sensor.solarrouter_safety_limit_reached` | Détournement inhibé lorsque ON |
| Stop temperature / Restart temperature | `number.*` | Seuils avec hystérésis |
| safety_temperature | `sensor.*` | Température mesurée utilisée pour la limite |

### Spécifique à l'engine

| Engine | Entités supplémentaires |
| --- | --- |
| [1 × switch](engine_1switch.md) | Niveaux et tempos de démarrage/arrêt |
| [1 × dimmer + bypass](engine_1dimmer_1bypass.md) | Relais de bypass, Bypass tempo |
| [Multi-canaux](engine_1dimmer_2switches.md) | Comptes à rebours des relais, Bypass tempo, détournement par relais |

### Planificateur (optionnel)

Voir [Planificateur marche forcée](scheduler_forced_run.md) : Activate scheduler, heure/minute de début et de fin, niveau du routeur, seuil de vérification de fin.

## Tableau de bord Lovelace suggéré

Jeu minimal de cartes pour un usage quotidien :

```yaml
type: vertical-stack
cards:
  - type: entities
    title: Solar Router
    entities:
      - entity: switch.solarrouter_activate_solar_routing
      - entity: number.solarrouter_router_level
      - entity: number.solarrouter_target_grid_exchange
      - entity: number.solarrouter_up_reactivity
      - entity: number.solarrouter_down_reactivity
  - type: history-graph
    title: Échange réseau
    hours_to_show: 24
    entities:
      - entity: sensor.solarrouter_real_power
      - entity: sensor.solarrouter_power_divertion
  - type: gauge
    entity: number.solarrouter_router_level
    name: Niveau du routeur
    min: 0
    max: 100
    severity:
      green: 0
      yellow: 50
      red: 90
```

Remplacez `solarrouter` par le préfixe de votre appareil. Ajoutez les entités de sécurité et de planificateur si ces packages sont chargés.

## Automatisations et blueprints

- Utilisez l'interrupteur **Activate Solar Routing** depuis n'importe quelle automatisation HA pour suspendre ou reprendre le détournement (ex. : quand une pompe à chaleur ou un chargeur VE a besoin du surplus).
- Blueprint prêt à l'emploi : [Priorité au VE](blueprint_priority_to_ev.md) — coupe le routeur pour laisser le chargeur VE prendre le surplus, puis le rétablit.

## Bonnes pratiques

1. **Excluez les capteurs haute fréquence** du recorder (`real_power`, compteurs d'énergie) — voir [Configuration du recorder](recorder_configuration.md).
2. Préférez **Router Level** pour le contrôle manuel ; ne combattez pas le curseur de régulation automatique tant que Activate est ON.
3. Conservez les entités de [versions de modules](module_version.md) activées si vous pouvez avoir besoin de support.
4. Pour une régulation qui doit survivre à une panne de HA, préférez un compteur **natif** au [compteur HA](power_meter_home_assistant.md).

## Voir aussi

- [Dépannage](troubleshooting.md)
- [Installation](installation.md)

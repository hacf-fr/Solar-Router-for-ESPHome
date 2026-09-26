---
title: Solar Router for ESPHome
description: Construire et configurer un routeur solaire ESPHome pour rediriger le surplus photovoltaïque vers des charges domestiques.
---

# Solar Router for ESPHome

**Solar Router for ESPHome** est un projet DIY visant à fournir un dispositif matériel spécialisé et un logiciel conçu pour optimiser l'utilisation de l'énergie solaire. Il effectue une surveillance en temps réel et une gestion intelligente de l'énergie excédentaire pour rediriger efficacement le surplus d'énergie solaire vers des charges désignées comme les chauffe-eau ou les systèmes de protection contre le gel.

Les principales caractéristiques comprennent un choix d'algorithmes de routage d'énergie dynamique (progressif, tout ou rien), de sources de compteurs d'énergie (locales ou distantes ...), de régulateurs (avec gradateur ou relais ...), et une intégration transparente avec [HomeAssistant](http://home-assistant.io) via le firmware [ESPHome](http://esphome.io).

Ce composant permet aux utilisateurs de surveiller et de contrôler facilement les fonctionnalités du routeur au sein de l'écosystème *Home Assistant*, facilitant ainsi la gestion et l'automatisation de l'énergie.

## Commencer ici

Choisissez le parcours correspondant à votre installation :

| Objectif | Page recommandée |
| --- | --- |
| Installer un premier routeur autonome | [Installation](installation.md) |
| Comprendre les architectures disponibles | [Architectures du firmware](firmware.md) |
| Partir d'un exemple YAML complet | [Exemple autonome](example_standalone.md) |
| Utiliser un compteur pour plusieurs routeurs | [Exemple avec proxy](example_proxy.md) |
| Diagnostiquer un routeur qui ne détourne pas l'énergie | [Dépannage](troubleshooting.md) |
| Connecter le routeur à Home Assistant | [Intégration Home Assistant](home_assistant.md) |

## Architecture du Solar Router

```mermaid
flowchart LR
    M[Compteur de puissance] --> E[Engine]
    E --> R[Régulateur]
    R --> L[Charge domestique]
    E -. optionnel .-> T[Limiteur de température]
    E -. optionnel .-> C[Compteur d'énergie]
    HA[Home Assistant] -. supervision et contrôle .-> E
```

La [vue d'ensemble du firmware](firmware.md) explique comment ces blocs sont assemblés. Le [guide matériel](hardware.md) présente les architectures électriques et les précautions de sécurité.

!!! danger "Avis important"
    Ce projet implique de travailler avec de la haute tension (110 ou 230 volts), ce qui peut être dangereux.  
    Veuillez lire l'[avertissement](disclaimer.md) avant de mettre en oeuvre le projet **Solar Router for ESPHome**.

!!! tips "Capacités étendues avec les capteurs Home Assistant"

    **Solar Router for ESPHome** est nativement compatible avec certains compteurs d'énergie bien connus du marché (voir le chapitre *Power meter* dans le menu de gauche). Le ***power meter [Home Assistant](power_meter_home_assistant.md)*** étend la source de mesure à tous les capteurs de *Home Assistant*, le rendant compatible avec un grand nombre de compteurs d'énergie.

![SolarRouterClosed](../images/SolarRouterClosed.png){width=350}
![Dashboard](../images/SolarRouterInHomeAssistantDashboard.png){width=350}

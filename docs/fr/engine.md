# Moteur de routeur solaire

## Description

Un moteur implémente la logique de décision du routeur solaire : il lit les mesures de puissance du compteur et pilote les régulateurs pour détourner l'énergie solaire excédentaire vers des charges locales plutôt que de l'exporter vers le réseau.

Le moteur est le cœur du routeur solaire. Il possède l'interrupteur `activate`, le `router_level` (0–100 %) et le script `energy_regulation`. Lorsque la régulation automatique est activée, il ajuste en continu le niveau du routeur en fonction des mesures de puissance en temps réel pour maintenir l'échange avec le réseau proche de la cible configurée.

### Moteurs disponibles

| Moteur | Cas d'usage |
| --- | --- |
| [`engine_1dimmer`](engine_1dimmer.md) | Charge unique avec contrôle progressif (TRIAC/SSR). Le choix le plus simple et le plus courant. |
| [`engine_1switch`](engine_1switch.md) | Charge unique avec relais ON/OFF (ex. : pompe, résistance sans gradation). Commute selon des seuils de puissance et des temporisations configurables. |
| [`engine_1dimmer_1bypass`](engine_1dimmer_1bypass.md) | Gradateur + relais de bypass. Active le relais de bypass lorsque le gradateur reste à 100 % afin de réduire la chaleur du régulateur. |
| [`engine_1dimmer_2switches`](engine_1dimmer_2switches.md) | Gradateur + 2 relais ON/OFF. Distribue la puissance sur trois canaux de manière séquentielle (ex. : chauffe-eau trois résistances). |
| [`engine_1dimmer_2switches_1bypass`](engine_1dimmer_2switches_1bypass.md) | Gradateur + 2 relais ON/OFF + relais de bypass sur le troisième canal. Efficacité maximale pour les charges multi-résistances. |

!!! note "Nommage des moteurs"
    Le nom du moteur reflète la façon dont le détournement d'énergie est effectué :  
    **Exemple** : `engine_1dimmer_1bypass` gérera 1 gradateur assurant une régulation progressive associée à un relais de dérivation.


### LEDs de retour utilisateur

La LED jaune reflète la connexion réseau :

- ***ÉTEINTE*** : le routeur solaire n'est pas connecté à l'alimentation.
- ***ALLUMÉE*** : le routeur solaire est connecté au réseau.
- ***CLIGNOTANTE*** : le routeur solaire n'est pas connecté au réseau et tente de se reconnecter.
- ***CLIGNOTEMENT RAPIDE*** : Une erreur se produit lors de la lecture de l'énergie échangée avec le réseau.

La LED verte reflète la configuration actuelle de la régulation :

- ***ÉTEINTE*** : la régulation automatique est désactivée.
- ***ALLUMÉE*** : la régulation automatique est active et ne détourne pas d'énergie vers la charge.
- ***CLIGNOTANTE*** : le routeur solaire envoie actuellement de l'énergie à la charge.

La configuration des LED est effectuée dans la configuration de l'`engine`.

### Afficher ou masquer des capteurs

Une variable optionnelle `hide_regulators` permet de changer la visibilité des capteurs de régulateurs dans HA (cachés par défaut).

Une variable optionnelle `hide_leds` permet de changer la visibilité des valeurs de leds dans HA (cachés par défaut).

Cette configuration est effectuée dans la configuration de l'`engine`.
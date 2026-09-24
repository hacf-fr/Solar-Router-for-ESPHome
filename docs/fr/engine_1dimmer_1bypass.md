# Engine 1 x dimmer + 1 x bypass

## Description

Ce package implémente le moteur du routeur solaire qui détermine quand et quelle quantité d'énergie doit être détournée vers la charge, avec une fonction de bypass pour une efficacité maximale.

Lorsque le régulateur est utilisé intensivement pendant une période prolongée, il a tendance à surchauffer. Ce moteur évite ce problème en activant un relais de bypass et en éteignant le régulateur lorsque celui-ci est resté pleinement ouvert (100 %) pendant un nombre configurable de cycles de régulation consécutifs. Pour éviter le scintillement, le relais de bypass n'est activé qu'après avoir atteint ce seuil.

**Engine 1 x dimmer + 1 x bypass** lit le compteur de puissance à chaque mise à jour pour obtenir l'énergie réelle échangée avec le réseau. Si l'énergie produite dépasse l'énergie consommée et que le surplus dépasse la cible d'échange configurée, le moteur calcule le **pourcentage d'ouverture du régulateur** et l'ajuste dynamiquement pour atteindre la cible. Lorsque le régulateur reste à 100 % pendant le nombre de cycles configuré, le relais de bypass est activé pour une efficacité maximale.

La régulation automatique du moteur peut être activée ou désactivée avec l'interrupteur d'activation.

## Comment câbler le relais de bypass

- Phase sur le Commun (COM) du relais de bypass et sur le relais vers l'entrée Phase du régulateur
- Normalement Fermé (NC) flottant
- Normalement Ouvert (NO) du relais vers la sortie Charge du régulateur (ou directement vers la charge)

!!! Danger "Suivez les instructions de câblage"
    Ne branchez pas l'entrée Phase du régulateur au Normalement Fermé (NC) du relais ! Votre charge serait mise hors tension lors de la commutation du relais, créant potentiellement des arcs à l'intérieur du relais.
    Plus d'informations dans cette [discussion](https://github.com/hacf-fr/Solar-Router-for-ESPHome/pull/51#issuecomment-2625724543).

## Router Level vs Regulator Opening

Le routeur solaire utilise trois contrôles de niveau distincts mais liés :

- **Router Level** : c'est le contrôle principal du système (0-100 %) qui représente l'état global du routage. Il pilote les indicateurs LED et la logique du compteur d'énergie. Lorsque la régulation automatique est activée, ce niveau est ajusté dynamiquement en fonction des mesures de puissance.

- **Regulator Opening** : cela représente le niveau d'ouverture réel (0-100 %) du régulateur physique. Par défaut, il reflète le niveau du routeur puisqu'il n'y a qu'un seul régulateur. Bien qu'il puisse être contrôlé indépendamment, les changements de `regulator_opening` seuls n'affectent pas le `router_level` et ne déclenchent pas de changements d'état des LED.

- **Relais de Bypass** : cela représente l'état réel (ON/OFF) du relais de bypass physique. Lorsque la régulation est activée, ce relais s'active automatiquement après la durée `Bypass tempo` définie dans Home Assistant. Lorsque la régulation est désactivée, vous pouvez déclencher manuellement ce relais pour alimenter complètement votre charge ; les LED et le compteur d'énergie (s'il est activé) ne seront pas déclenchés. Vous pouvez aussi régler le *Router Level* à 100 : cela active le relais, alimente complètement votre charge et déclenche les LED et le compteur d'énergie.

## Configuration

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/engine_1dimmer_1bypass.yaml
        vars:
          green_led_pin: GPIO1
          green_led_inverted: 'False'
          yellow_led_pin: GPIO2
          yellow_led_inverted: 'False'
          hide_regulators: 'True'
          hide_leds: 'True'
```

Lorsque ce package est utilisé, il est nécessaire de définir `green_led_pin` et `yellow_led_pin` dans la section `vars` comme montré dans l'exemple ci-dessus.

### Variables

| Variable | Requis | Défaut | Description |
| --- | --- | --- | --- |
| `green_led_pin` | oui | — | Broche GPIO pour la LED verte d'état |
| `yellow_led_pin` | oui | — | Broche GPIO pour la LED jaune réseau/erreur |
| `green_led_inverted` | non | `'False'` | Mettre à `'True'` si la LED verte est active à l'état bas |
| `yellow_led_inverted` | non | `'False'` | Mettre à `'True'` si la LED jaune est active à l'état bas |
| `hide_regulators` | non | `'True'` | Mettre à `'False'` pour exposer les capteurs de régulateur dans Home Assistant |
| `hide_leds` | non | `'True'` | Mettre à `'False'` pour exposer l'état des LED dans Home Assistant |

!!! tip "Ajustement du Bypass Tempo"
    Le `Bypass Tempo` détermine combien de régulations consécutives à 100 % sont nécessaires avant d'activer le relais de bypass. Une valeur plus basse rendra le bypass plus réactif mais pourrait causer des commutations plus fréquentes (scintillement). Si votre compteur de puissance se met à jour 1 fois par seconde, `Bypass Tempo` peut être approximé comme le temps en secondes avec le régulateur à 100 % avant activation du relais de bypass ; sinon cela correspond au nombre de mises à jour du compteur.

# Engine 1 x dimmer + 1 x bypass

Ce package implémente le moteur du routeur solaire qui détermine quand et quelle quantité d'énergie doit être déviée vers la charge, avec une fonction de bypass pour une efficacité maximale.

Lorsque le régulateur est utilisé intensivement pendant une période prolongée, il aura tendance à surchauffer. Ce moteur est conçu pour éviter ce problème en activant un relais de bypass et en éteignant le régulateur lorsque celui-ci est ouvert à 100% pendant une période prolongée. Pour éviter le scintillement, le relais de bypass n'est activé que lorsque le régulateur est ouvert à 100% pendant un nombre consécutif de régulations.

L'**Engine 1 x dimmer + 1 x bypass** interroge le compteur d'énergie à chaque mise à jour de la valeur de celui-ci pour obtenir l'énergie réelle échangée avec le réseau. Si l'énergie produite est supérieure à l'énergie consommée et dépasse l'objectif d'échange défini, le moteur déterminera le **pourcentage d'ouverture du régulateur** et l'ajustera dynamiquement pour atteindre l'objectif. Lorsque le régulateur atteint 100% pendant une période prolongée, le relais de bypass est activé pour une efficacité maximale.

La régulation automatique du moteur peut être activée ou désactivée avec l'interrupteur d'activation.

## Comment câbler le relais de bypass

- Phase sur le Commun (COM) du relais de bypass et sur le relais vers l'entrée Phase du régulateur
- Normalement Fermé (NC) flottant
- Normalement Ouvert (NO) du relais vers la sortie Charge du régulateur (ou directement vers la charge)

!!! Danger "Suivez les instructions de câblage"
    Ne branchez pas l'entrée Phase du régulateur au Normalement Fermé (NC) du relais ! Votre charge serait mise hors tension lors de la commutation du relais, créant potentiellement des arcs à l'intérieur du relais.
    Plus d'informations dans cette [discussion](https://github.com/XavierBerger/Solar-Router-for-ESPHome/pull/51#issuecomment-2625724543).

## Router level vs regulator opening

Le routeur solaire utilise trois contrôles de niveau distincts mais liés :

- **Router level** : C'est le contrôle principal du système (0-100%) qui représente l'état global du routage. Il contrôle les indicateurs LED et la logique du compteur d'énergie. Lorsque la régulation automatique est activée, ce niveau est ajusté dynamiquement en fonction des mesures de puissance.

- **Regulator opening** : Cela représente le niveau d'ouverture réel (0-100%) du régulateur physique. Par défaut, il reflète le niveau du routeur puisqu'il n'y a qu'un seul régulateur. Bien qu'il puisse être contrôlé indépendamment, les changements de regulator_opening seuls n'affecteront pas le router_level ni ne déclencheront de changements d'état des LED.

- **Relais de Bypass** : Cela représente l'état réel (ON/OFF) du relais de bypass physique. Lorsque la régulation est activée, ce relais s'active automatiquement après la durée `Bypass tempo` définie ci-dessous. Lorsque la régulation est désactivée, vous pouvez déclencher manuellement ce relais pour alimenter complètement votre charge, les LED et le compteur d'énergie (si activé) ne seront pas déclenchés. Vous pouvez également régler le *router level* à 100, cela activera le relais, alimentera complètement votre charge, déclenchera les LED et le compteur d'énergie.


## Configuration

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/XavierBerger/Solar-Router-for-ESPHome/
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
Il est necessaire de définir `green_led_pin` et `yellow_led_pin` dans la section `vars` comme montré dans l'exemple ci-dessus.

 * Le paramètre `xxx_led_inverted` permet de définir si la LED est active sur niveau haut ou bas. Ce paramètre est optionnel.
 * Le paramètre `hide_regulators` permet de définir si le capteur de régulateur est affiché dans HA. Ce paramètre est optionnel.
 * Le paramètre `hide_leds` permet de définir si les valeurs des leds sont affichées dans HA. Ce paramètre est optionnel.

!!! tip "Ajustement du Bypass tempo"
    Le `Bypass tempo` détermine combien de régulations consécutives à 100% sont nécessaires avant d'activer le relais de bypass. Une valeur plus basse rendra le bypass plus réactif mais pourrait causer des commutations plus fréquentes (scintillement). Si votre capteur d'énergie se met à jour 1 fois par seconde, `Bypass tempo` peut être approximé comme le temps en secondes avec le régulateur à 100% avant que le relais de bypass ne soit activé, sinon celà correpond au nombre de mises à jours du capteur d'énergie.

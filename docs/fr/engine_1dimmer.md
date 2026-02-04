# Engine 1 x dimmer

Ce package implémente le moteur du routeur solaire qui détermine quand et quelle quantité d'énergie doit être déviée vers la charge.

L'**Engine 1 x dimmer** appelle le compteur d'énergie à chaque mise à jour de la valeur de celui-ci pour obtenir l'énergie réelle échangée avec le réseau. Si l'énergie produite est supérieure à l'énergie consommée et dépasse la cible d'échange définie, le moteur déterminera le **pourcentage d'ouverture du régulateur** et l'ajustera dynamiquement pour atteindre la cible.

La régulation automatique du moteur peut être activée ou désactivée avec l'interrupteur d'activation.
 - Lors de son activation, l'interrupteur ON/OFF du mode manuel est coupé.

Un second interrupteur permet le ON/OFF général en mode manuel. Il est nécessaire de l'ajouter pour rendre le projet compatible avec https://github.com/jmcollin78/solar_optimizer
 - Lors de son activation, l'interrupteur du mode automatique est coupé.
 - Lors de la désactivation de cet interrupteur, la consigne d'angle de conduction du triac passe à 0.

Pour que le triac puisse être piloté, il faut qu'un de ces deux interrupteurs soit activé, sinon le triac reste sur OFF.

## Configuration

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/engine_1dimmer.yaml
        vars:
          green_led_pin: GPIO32
          green_led_inverted: 'False'
          yellow_led_pin: GPIO14
          yellow_led_inverted: 'False'
          hide_regulators: 'True'
          hide_leds: 'True'
```

Il est necessaire de définir `green_led_pin` et `yellow_led_pin` dans la section `vars` comme montré dans l'exemple ci-dessus.

 * Le paramètre `xxx_led_inverted` permet de définir si la LED est active sur niveau haut ou bas. Ce paramètre est optionnel.
 * Le paramètre `hide_regulators` permet de définir si le capteur de régulateur est affiché dans HA. Ce paramètre est optionnel.
 * Le paramètre `hide_leds` permet de définir si les valeurs des leds sont affichées dans HA. Ce paramètre est optionnel.



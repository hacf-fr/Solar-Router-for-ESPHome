# Engine 1 x dimmer

Ce package implémente le moteur du routeur solaire qui détermine quand et quelle quantité d'énergie doit être déviée vers la charge.

L'**Engine 1 x dimmer** appelle le compteur d'énergie à chaque mise à jour de la valeur de celui-ci pour obtenir l'énergie réelle échangée avec le réseau. Si l'énergie produite est supérieure à l'énergie consommée et dépasse la cible d'échange définie, le moteur déterminera le **pourcentage d'ouverture du régulateur** et l'ajustera dynamiquement pour atteindre la cible.

La régulation automatique du moteur peut être activée ou désactivée avec l'interrupteur d'activation.

## Configuration

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/XavierBerger/Solar-Router-for-ESPHome/
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



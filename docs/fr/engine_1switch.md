# Engine 1 x switch

Ce package implémente le moteur du routeur solaire qui détermine si l'énergie peut être détournée vers une charge locale ou non.

L'***Engine 1 x switch*** appelle le compteur d'énergie à chaque mise à jour de la valeur de celui-ci pour obtenir la puissance réelle consommée. Si l'énergie envoyée au réseau est supérieure au niveau de démarrage du détournement (en W) pendant le temps de démarrage (en s), le relais est fermé pour utiliser l'énergie localement. Lorsque l'énergie envoyée au réseau atteint le niveau défini (en W) pour arrêter le détournement pendant le temps d'arrêt (en s), le relais est ouvert et la consommation locale est arrêtée.

La régulation automatique du *engine_1switch* peut être activée ou désactivée avec l'interrupteur d'activation.

Le schéma suivant représente la consommation avec ce moteur activé :

![engine_1switch](images/engine_1switch.png)

**Légende :**

 * Vert : Énergie consommée provenant des panneaux solaires (autoconsommation)
 * Jaune : Énergie envoyée au réseau
 * Rouge : Énergie consommée provenant du réseau

**Comment ça fonctionne ?**

* **①** La partie jaune du graphique montre le niveau de démarrage. Lorsque l'énergie envoyée au réseau atteint le niveau de démarrage, l'énergie est détournée localement.
* **②** La partie jaune du graphique montre le niveau d'arrêt. Dans cet exemple, 0W.

!!! Danger "Définissez soigneusement les niveaux de démarrage et d'arrêt"
    Le niveau de démarrage doit être supérieur à la puissance de la charge branchée au routeur solaire. Sinon, dès que l'énergie sera détournée vers la charge, le niveau d'arrêt sera atteint et vous verrez le routeur basculer entre ON et OFF (en fonction de la temporisation que vous avez définie).

!!! Astuce "Ajustez finement les temps de démarrage et d'arrêt"
    Les temps de démarrage et d'arrêt déterminent la réactivité de la régulation. Ces délais doivent être finement ajustés pour éviter les oscillations. Par exemple, si vous avez une cuisinière électrique, faites attention aux délais de chauffe.

## Configuration

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/engine_1switch.yaml
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

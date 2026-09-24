# Engine 1 x switch

## Description

Ce package implémente le moteur du routeur solaire qui détermine si l'énergie peut être détournée vers une charge locale ou non.

**Engine 1 x switch** lit le compteur de puissance à chaque mise à jour pour obtenir la puissance réelle consommée. Si l'énergie envoyée au réseau dépasse le niveau de démarrage (W) pendant le tempo de démarrage (s), le relais se ferme pour consommer l'énergie localement. Lorsque l'énergie envoyée au réseau descend au niveau d'arrêt (W) pendant le tempo d'arrêt (s), le relais s'ouvre et la consommation locale est arrêtée.

La régulation automatique du moteur peut être activée ou désactivée avec l'interrupteur d'activation.

Le schéma suivant représente la consommation avec ce moteur activé :

![Engine 1 x switch](images/engine_1switch.png)

**Légende :**

 * Vert : énergie consommée provenant des panneaux solaires (autoconsommation)
 * Jaune : énergie envoyée au réseau
 * Rouge : énergie consommée provenant du réseau

**Comment ça fonctionne ?**

* **①** La partie jaune du graphique montre le niveau de démarrage. Lorsque l'énergie envoyée au réseau atteint le niveau de démarrage, l'énergie est détournée localement.
* **②** La partie jaune du graphique montre le niveau d'arrêt. Dans cet exemple, 0 W.

!!! Danger "Définissez soigneusement les niveaux de démarrage et d'arrêt"
    Le niveau de démarrage doit être supérieur à la puissance de la charge branchée au routeur solaire. Sinon, dès que l'énergie sera détournée vers la charge, le niveau d'arrêt sera atteint et vous verrez le routeur basculer entre ON et OFF (en fonction de la temporisation que vous avez définie).

!!! tip "Ajustez finement les tempos de démarrage et d'arrêt"
    Les tempos de démarrage et d'arrêt déterminent la réactivité de la régulation. Ces délais doivent être finement ajustés pour éviter les oscillations. Par exemple, si vous avez une cuisinière électrique, faites attention aux délais de chauffe.

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

Lorsque ce package est utilisé, il est nécessaire de définir `green_led_pin` et `yellow_led_pin` dans la section `vars` comme montré dans l'exemple ci-dessus.

### Variables

| Variable | Requis | Défaut | Description |
| --- | --- | --- | --- |
| `green_led_pin` | oui | — | Broche GPIO pour la LED verte d'état |
| `yellow_led_pin` | oui | — | Broche GPIO pour la LED jaune réseau/erreur |
| `green_led_inverted` | non | `'False'` | Mettre à `'True'` si la LED verte est active à l'état bas |
| `yellow_led_inverted` | non | `'False'` | Mettre à `'True'` si la LED jaune est active à l'état bas |
| `hide_regulators` | non | `'True'` | Mettre à `'False'` pour exposer l'état des relais dans Home Assistant |
| `hide_leds` | non | `'True'` | Mettre à `'False'` pour exposer l'état des LED dans Home Assistant |

# Engine 1 x dimmer

## Description

Ce package implémente le moteur du routeur solaire qui détermine quand et quelle quantité d'énergie doit être détournée vers la charge.

**Engine 1 x dimmer** lit le compteur de puissance à chaque mise à jour pour obtenir l'énergie réelle échangée avec le réseau. Si l'énergie produite dépasse l'énergie consommée et que le surplus dépasse la cible d'échange configurée, le moteur calcule le **pourcentage d'ouverture du régulateur** et l'ajuste dynamiquement pour atteindre la cible.

La régulation automatique du moteur peut être activée ou désactivée avec l'interrupteur d'activation.

## Router Level vs Regulator Opening

Le routeur solaire utilise deux contrôles de niveau distincts mais liés :

- **Router Level** : c'est le contrôle principal du système (0-100 %) qui représente l'état global du routage. Il pilote les indicateurs LED et la logique du compteur d'énergie. Lorsque la régulation automatique est activée, ce niveau est ajusté dynamiquement en fonction des mesures de puissance.

- **Regulator Opening** : cela représente le niveau d'ouverture réel (0-100 %) du régulateur physique. Par défaut, il reflète le niveau du routeur puisqu'il n'y a qu'un seul régulateur. Bien qu'il puisse être contrôlé indépendamment, les changements de `regulator_opening` seuls n'affectent pas le `router_level` et ne déclenchent pas de changements d'état des LED.

L'entité d'ouverture du régulateur est masquée de Home Assistant par défaut. Pour l'exposer, définissez `hide_regulators: 'False'` dans vos `vars`.

Note : il est recommandé d'ajuster le `router_level` plutôt que le `regulator_opening` directement, afin d'assurer un retour d'état correct via les LED et le suivi d'énergie.

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

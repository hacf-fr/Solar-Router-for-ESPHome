# Interrupteur d'activation

Ce package ajoute au routeur solaire un **interrupteur physique à deux positions**, câblé sur une broche GPIO de l'ESP32. Sa position pilote l'activation du routage solaire, sans avoir besoin de réseau, de Home Assistant ni d'un navigateur.

- interrupteur fermé → routage solaire **activé**,
- interrupteur ouvert → routage solaire **désactivé**.

Si vous souhaitez en plus une position forçant le routeur à 100 %, utilisez plutôt [activate_switch_3positions](activate_switch_3positions.md).

!!! warning "L'interrupteur physique est toujours prioritaire"
    La position de l'interrupteur physique est recopiée **en permanence** sur l'interrupteur `activate`, dans les deux sens. Tant que ce package est inclus :

    - basculer *Activate Solar Routing* depuis Home Assistant ou depuis le serveur web n'a pas d'effet durable : l'état revient à la position de l'interrupteur physique en moins d'une seconde,
    - un bouton poussoir fourni par [activate_button](activate_button.md) n'a pas non plus d'effet durable,
    - le package `scheduler_forced_run.yaml` **ne peut plus fonctionner** : le routage qu'il désactive pendant la plage de marche forcée est immédiatement réactivé.

    Si vous souhaitez que les autres sources gardent la main entre deux manœuvres de l'interrupteur, positionnez `activate_switch_strict` à `"false"`. La position de l'interrupteur n'est alors appliquée que lorsqu'il est manœuvré, ainsi qu'au démarrage.

## Prérequis

Ce package n'est pas autonome. Il repose sur un identifiant fourni par un autre package qui doit être inclus dans votre configuration :

- un package `engine_*` (par exemple `engine_1dimmer.yaml`) qui fournit l'interrupteur `activate`.

## Comportement au démarrage

`activate` est restauré depuis la mémoire flash au démarrage, ce qui peut ne pas correspondre à la position de l'interrupteur physique (le routeur peut par exemple avoir été hors tension pendant que l'interrupteur était manœuvré). Le package réaligne `activate` sur l'interrupteur physique dans la seconde qui suit le démarrage : l'état constaté correspond donc toujours à ce que l'on lit en façade.

## Câblage

L'interrupteur est un simple contact sec entre la broche GPIO et la masse. Aucune résistance externe n'est nécessaire : la résistance de tirage interne de l'ESP32 est activée par le package.

![](../images/activate_switch.drawio.png)


Avec ce câblage, le contact est **fermé** lorsque le routage doit être activé, ce qui correspond à la polarité par défaut du package (`activate_switch_inverted: "True"`). Si votre interrupteur est câblé dans l'autre sens (contact fermé = routage désactivé), positionnez `activate_switch_inverted` à `"False"`.

!!! danger "Choisissez une broche GPIO utilisable"
    Les broches GPIO6 à GPIO11 sont reliées à la mémoire flash SPI interne de l'ESP32 et ne peuvent pas être utilisées. Les broches GPIO34 à GPIO39 sont en entrée seule et ne disposent **pas** de résistance de tirage interne : elles ne conviennent donc pas non plus, sauf à ajouter une résistance de tirage externe. GPIO32 et GPIO33 sont des choix sûrs.

## Retour d'état dans Home Assistant

Le package expose un capteur texte *Activate Switch Position*, en catégorie diagnostic, indiquant la position réellement lue sur le contact : `Disabled` ou `Solar routing`. Positionnez `hide_activate_switch_position` à `"True"` pour le masquer.

## Configuration

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  activate_switch:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/activate_switch.yaml
        vars:
          activate_switch_pin: GPIO33
```

### Variables

| Variable                        | Obligatoire | Défaut    | Description                                                                                                                                                                 |
| ------------------------------- | ----------- | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `activate_switch_pin`           | oui         | —         | Broche GPIO sur laquelle l'interrupteur est raccordé. La résistance de tirage interne est activée.                                                                          |
| `activate_switch_inverted`      | non         | `"True"`  | À mettre à `"False"` si un contact **fermé** signifie routage désactivé.                                                                                                    |
| `activate_switch_debounce`      | non         | `50ms`    | Temps d'anti-rebond du contact mécanique.                                                                                                                                   |
| `activate_switch_strict`        | non         | `"true"`  | À mettre à `"false"` pour n'appliquer la position que lors des manœuvres, et laisser Home Assistant, un bouton poussoir ou le planificateur piloter `activate` entre-temps. |
| `hide_activate_switch`          | non         | `"True"`  | À mettre à `"False"` pour exposer l'état brut du contact dans Home Assistant, ce qui est pratique pour vérifier votre câblage.                                              |
| `hide_activate_switch_position` | non         | `"False"` | À mettre à `"True"` pour masquer le capteur texte *Activate Switch Position*.                                                                                               |

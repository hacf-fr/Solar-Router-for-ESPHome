# Interrupteur d'activation 3 positions

Ce package ajoute au routeur solaire un **interrupteur physique à trois positions**, câblé sur deux broches GPIO de l'ESP32. Sa position pilote le routage solaire, sans avoir besoin de réseau, de Home Assistant ni d'un navigateur.

| Position du levier | Contact fermé               | État du routeur                           |
| ------------------ | --------------------------- | ----------------------------------------- |
| haut               | `activate_switch_off_pin`   | routage solaire **désactivé**, niveau à 0 |
| centre             | aucun                       | routage solaire **activé**                |
| bas                | `activate_switch_force_pin` | routeur **forcé à 100 %**                 |

Les deux premières positions se comportent exactement comme [activate_switch](activate_switch.md). La troisième force la charge à pleine puissance de la même manière que `scheduler_forced_run.yaml` : `activate` est coupé pour que la régulation solaire cesse d'ajuster le niveau, puis `router_level` est fixé à 100 %.

!!! warning "L'interrupteur physique est toujours prioritaire"
    La position de l'interrupteur est appliquée **en permanence**. Tant que ce package est inclus :

    - basculer *Activate Solar Routing* ou déplacer *Router Level* depuis Home Assistant n'a pas d'effet durable : le routeur revient à la position de l'interrupteur en moins d'une seconde,
    - un bouton poussoir fourni par [activate_button](activate_button.md) n'a pas non plus d'effet durable,
    - le package `scheduler_forced_run.yaml` **ne peut plus fonctionner**.

    Si vous souhaitez que les autres sources gardent la main entre deux manœuvres, positionnez `activate_switch_strict` à `"false"`. La position n'est alors appliquée que lors des manœuvres, ainsi qu'au démarrage.

!!! note "La position de forçage respecte le limiteur de température"
    Lorsque `activate` est coupé, le script `energy_regulation` ne tourne plus, or c'est le seul endroit où l'indicateur `safety_limit` d'un package `temperature_limiter_*` est normalement contrôlé. Ce package le relit donc lui-même : tant que la sécurité est active, la position de forçage maintient `router_level` à 0, puis le laisse remonter à 100 % une fois la température redescendue sous le seuil de redémarrage.

    Notez que `scheduler_forced_run.yaml` ne dispose **pas** de cette protection.

## Prérequis

Ce package n'est pas autonome. Il repose sur des identifiants fournis par un autre package qui doit être inclus dans votre configuration :

- un package `engine_*` (par exemple `engine_1dimmer.yaml`) qui fournit l'interrupteur `activate` et le nombre `router_level`.

Il est **exclusif** de [activate_switch](activate_switch.md) : les deux déclarent les mêmes identifiants, il faut donc inclure l'un ou l'autre, jamais les deux.

## Comportement au démarrage

`activate` est restauré depuis la mémoire flash au démarrage, ce qui peut ne pas correspondre à la position de l'interrupteur physique. Le package applique la position de l'interrupteur dans la seconde qui suit le démarrage : l'état du routeur correspond donc toujours à ce que l'on lit en façade.

## Câblage

Utilisez un interrupteur à levier ON-OFF-ON classique (ou un commutateur rotatif 3 positions avec borne commune). La borne commune va à la masse, les deux bornes extrêmes aux broches GPIO. Aucune résistance externe n'est nécessaire : les résistances de tirage internes de l'ESP32 sont activées par le package.

![](../images/activate_switch_3positions.drawio.png)

Avec ce câblage, un contact est **fermé** lorsque le levier le sélectionne, ce qui correspond à la polarité par défaut du package. Si un contact est câblé dans l'autre sens, positionnez `activate_switch_off_inverted` ou `activate_switch_force_inverted` à `"False"`.

Si les deux contacts se retrouvent fermés en même temps (erreur de câblage, ou interrupteur court-circuitant les deux bornes au passage par le centre), la position de forçage l'emporte.

!!! danger "Choisissez des broches GPIO utilisables"
    Les broches GPIO6 à GPIO11 sont reliées à la mémoire flash SPI interne de l'ESP32 et ne peuvent pas être utilisées. Les broches GPIO34 à GPIO39 sont en entrée seule et ne disposent **pas** de résistance de tirage interne : elles ne conviennent donc pas non plus, sauf à ajouter des résistances de tirage externes. GPIO32 et GPIO33 sont des choix sûrs.

## Retour d'état dans Home Assistant

Le package expose un capteur texte *Activate Switch Position*, en catégorie diagnostic, indiquant la position réellement lue sur les contacts : `Disabled`, `Solar routing` ou `Forced 100%`. Positionnez `hide_activate_switch_position` à `"True"` pour le masquer.

Les deux contacts bruts sont exposés sous les noms *Activate Switch Off Contact* et *Activate Switch Force Contact* ; ils sont internes par défaut et peuvent être affichés avec `hide_activate_switch: "False"` pour vérifier votre câblage.

## Configuration

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  activate_switch_3positions:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/activate_switch_3positions.yaml
        vars:
          activate_switch_off_pin: GPIO32
          activate_switch_force_pin: GPIO33
```

### Variables

| Variable                         | Obligatoire | Défaut    | Description                                                                                                                                             |
| -------------------------------- | ----------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `activate_switch_off_pin`        | oui         | —         | Broche GPIO fermée par la position « routage désactivé ». La résistance de tirage interne est activée.                                                  |
| `activate_switch_force_pin`      | oui         | —         | Broche GPIO fermée par la position « forçage ». La résistance de tirage interne est activée.                                                            |
| `activate_switch_off_inverted`   | non         | `"True"`  | À mettre à `"False"` si le contact « routage désactivé » est **ouvert** lorsque le levier le sélectionne.                                               |
| `activate_switch_force_inverted` | non         | `"True"`  | À mettre à `"False"` si le contact « forçage » est **ouvert** lorsque le levier le sélectionne.                                                         |
| `activate_switch_debounce`       | non         | `50ms`    | Temps d'anti-rebond des contacts mécaniques.                                                                                                            |
| `activate_switch_forced_level`   | non         | `"100"`   | Niveau du routeur, en pourcentage, appliqué dans la position de forçage.                                                                                |
| `activate_switch_strict`         | non         | `"true"`  | À mettre à `"false"` pour n'appliquer la position que lors des manœuvres, et laisser Home Assistant ou le planificateur piloter le routeur entre-temps. |
| `hide_activate_switch`           | non         | `"True"`  | À mettre à `"False"` pour exposer l'état brut des deux contacts dans Home Assistant, ce qui est pratique pour vérifier votre câblage.                   |
| `hide_activate_switch_position`  | non         | `"False"` | À mettre à `"True"` pour masquer le capteur texte *Activate Switch Position*.                                                                           |

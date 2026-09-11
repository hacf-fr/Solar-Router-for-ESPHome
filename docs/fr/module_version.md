# Versions des modules

Chaque package du routeur solaire publie sa propre version dans Home Assistant : un appareil indique
ainsi de quels modules il est composé, et dans quelle version il utilise chacun d'eux.

Un routeur solaire est assemblé à partir de packages qui, une fois compilés, ne laissent aucune
trace de cet assemblage : deux routeurs aux capacités très différentes se ressemblent vus depuis
Home Assistant. Ces entités comblent ce manque.

## Où les trouver

Ce sont des entités de **diagnostic**, que Home Assistant regroupe donc dans la section
*Diagnostic* de la page de l'appareil. Chacune porte le nom du fichier de package dont elle provient,
et son état est la version :

| Entité                                      | État    |
| ------------------------------------------- | ------- |
| `sensor.solarrouter_common`                 | `1.1.1` |
| `sensor.solarrouter_power_meter_fronius`    | `1.6.3` |
| `sensor.solarrouter_regulator_triac`        | `1.6.3` |
| `sensor.solarrouter_engine_1dimmer`         | `1.6.6` |

La liste que vous voyez **est** la composition de votre routeur. Un package non chargé ne publie
rien : le régulateur, le compteur de puissance et le moteur se distinguent donc d'un coup d'œil. Cela
compte surtout pour les régulateurs, car `regulator_triac`, `regulator_solid_state_relay` et
`regulator_mecanical_relay` ne publient aucune autre entité.

## Lire les versions

!!! note "Des versions différentes d'un module à l'autre, c'est normal"
    Une publication n'incrémente que la version des modules réellement modifiés. Un routeur en bonne
    santé affiche donc des versions disparates : `common` peut rester en `1.1.1` alors que
    `temperature_fan_control` est en `1.6.7`, tous deux issus de la même publication.

    Il en découle que la version la plus élevée d'un appareil est une **borne inférieure** de la
    publication à partir de laquelle il a été construit, et non cette publication. Un routeur
    construit en `v1.6.7` dont aucun package n'a été touché par cette version n'affichera rien
    au-dessus de `1.6.6`.

Pour savoir si un module est en retard, comparez-le au même fichier dans le
[dépôt](https://github.com/hacf-fr/Solar-Router-for-ESPHome/tree/main/solar_router) plutôt qu'au
numéro de publication.

## Quand elles sont publiées

La valeur est envoyée **une seule fois, environ dix secondes après le démarrage** de l'appareil, puis
plus jamais — elle ne peut pas changer pendant que l'appareil fonctionne. Deux conséquences à
connaître :

* juste après un redémarrage, les entités sont brièvement à `unknown`, c'est attendu ;
* la valeur affichée est celle compilée dans le firmware, elle n'est pas lue en direct. Mettre à jour
  vos packages suppose de recompiler et de téléverser avant que les versions ne changent.

## Packages chargés plusieurs fois

`regulator_mecanical_relay` et `scheduler_forced_run` peuvent être chargés plusieurs fois : le nom de
leur entité porte donc leur identifiant unique. Avec trois relais mécaniques vous obtenez
`regulator_mecanical_relay_1`, `_2` et `_3` ; avec le planificateur par défaut, vous obtenez
`scheduler_forced_run_Forced`.

!!! warning "Un module reste invisible"
    `power_meter_home_assistant` surcharge les capteurs de `power_meter_common`, et cette surcharge
    remplace aussi l'entité de version du common. Sur un routeur utilisant le compteur de puissance
    Home Assistant, `power_meter_common` ne publie donc aucune version bien qu'il soit chargé. Son
    absence ne vous apprend rien.

## Les désactiver

Ces entités sont sans conséquence — elles contiennent une courte chaîne de caractères et ne se
mettent jamais à jour — mais elles peuvent être désactivées dans Home Assistant comme n'importe
quelle autre entité si vous préférez ne pas les voir. Cela masque la composition de votre routeur à
tout ce qui la lit : gardez-les actives si vous pouvez avoir besoin d'assistance un jour.

# Engine 1 x dimmer + 2 x switches + 1 x bypass

## Description

Ce package implémente le moteur du routeur solaire qui détermine quand et quelle quantité d'énergie doit être détournée vers trois charges utilisant trois canaux, ou une seule charge à trois canaux comme un chauffe-eau à trois résistances, le troisième canal disposant d'une fonction de bypass pour une efficacité maximale.

Le moteur utilise trois relais pour contrôler différentes charges, avec un régulateur supplémentaire pour un contrôle fin de la puissance. Les charges sont activées séquentiellement à mesure que plus de puissance devient disponible :

1. Premier canal : Relais 1 (contrôle On/Off)
2. Deuxième canal : Relais 2 (contrôle On/Off)
3. Troisième canal : Relais 3 ET gradateur (contrôle de puissance variable)

Lorsque les besoins en puissance augmentent :

- D'abord, le régulateur du canal 3 augmente progressivement la puissance
- Lorsque le régulateur atteint 33,33 %, le relais 1 s'active
- Lorsque le régulateur atteint 66,66 %, le relais 2 s'active
- Lorsque le régulateur atteint 100 %, le relais 3 s'active et contourne le régulateur

**Engine 1 x dimmer + 2 x switches + 1 x bypass** interroge chaque seconde le compteur de puissance pour obtenir l'énergie réelle échangée avec le réseau. Si l'énergie produite est supérieure à l'énergie consommée et dépasse la cible d'échange définie, le moteur détermine la combinaison appropriée de relais et d'ouverture du régulateur pour atteindre la cible.

La régulation automatique du moteur peut être activée ou désactivée avec l'interrupteur d'activation.

## Comment câbler les relais (canaux 1 et 2)

- Phase sur le Commun (COM) du relais
- Normalement Ouvert (NO) du relais de l'entrée Charge directement vers la charge

## Comment câbler le régulateur et le relais de bypass (canal 3)

- Phase sur le Commun (COM) du relais de bypass et sur le relais vers l'entrée Phase du régulateur
- Normalement Fermé (NC) flottant
- Normalement Ouvert (NO) du relais vers la sortie Charge du régulateur (ou directement vers la charge)

!!! Danger "Suivez les instructions de câblage"
    Ne branchez pas l'entrée Phase du régulateur au Normalement Fermé (NC) du relais ! Votre charge serait mise hors tension lors de la commutation du relais, créant potentiellement des arcs à l'intérieur du relais.
    Plus d'informations dans cette [discussion](https://github.com/hacf-fr/Solar-Router-for-ESPHome/pull/51#issuecomment-2625724543).

## Schéma d'exemple de câblage

![Schéma d'exemple de câblage pour chauffe-eau](images/3ResistorsWaterHeaterExampleWithBypass.svg)

## Configuration

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  engine:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/engine_1dimmer_2switches_1bypass.yaml
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

!!! note "Distribution de la puissance"
    Le moteur divise la puissance totale disponible en trois parts égales (33,33 % chacune). Cela permet des transitions fluides entre les différents niveaux de puissance et une distribution efficace du surplus solaire sur plusieurs charges.

!!! tip "Ajustement du Bypass Tempo"
    Le Bypass Tempo détermine combien de régulations consécutives à 33,33 %, 66,66 % ou 100 % sont nécessaires avant d'activer le relais de _bypass_. Une valeur plus basse rendra le bypass plus réactif mais pourrait causer des commutations plus fréquentes (scintillement). Comme il y a environ 1 régulation par seconde, le Bypass Tempo peut être approximé comme le temps en secondes avec le régulateur à 33,33 %, 66,66 % ou 100 % avant activation des relais.

![HA](images/countdown_engine_1dimmer_2switch_1bypass.png){ align=left }
!!! note ""
    **Capteurs**
    
    * ***Compte à rebours du relais n° X*** 
        Pour chaque relais, le compte à rebours en cours est affiché.
        Au départ, le compte à rebours est égal à la valeur du Bypass Tempo, puis à chaque régulation d'énergie où le régulateur est à 100 % le compte à rebours diminue ; enfin, lorsqu'il atteint zéro, le relais est activé.
    * ***Ouverture du régulateur*** 
        Masquée par défaut (voir `hide_regulators`), affiche le niveau du régulateur (TRIAC ou SSR).

Ce package nécessite l'utilisation du package régulateur à relais mécanique ET d'un package régulateur (TRIAC ou SSR). N'oubliez pas de les inclure également.

Vous trouverez ci-dessous un exemple de configuration pour les relais :

```yaml linenums="1"
packages:
  relay1_regulator:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/regulator_mechanical_relay.yaml
        vars:
          relay_regulator_gate_pin: GPIO17
          relay_unique_id: "1"
  relay2_regulator:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/regulator_mechanical_relay.yaml
        vars:
          relay_regulator_gate_pin: GPIO18
          relay_unique_id: "2"
  relay3_bypass_regulator:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/regulator_mechanical_relay.yaml
        vars:
          relay_regulator_gate_pin: GPIO21
          relay_unique_id: "3"
```

!!! note "Identifiants des relais"
    Les identifiants uniques des relais ne peuvent pas être modifiés pour utiliser ce moteur ; en particulier, `relay_unique_id: "3"` est toujours utilisé pour le relais de bypass.

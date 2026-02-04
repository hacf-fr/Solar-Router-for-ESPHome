# Détails sur l'utilisation d'un capteur de puissance JSY-MK-194T

Deux configurations sont possibles lors de l'utilisation de ce capteur :

  - standalone : on utilise les deux capteurs du JSY-MK-194T (Ch1 : capteur sur la charge, Ch2 : capteur de puissance de la maison au niveau du compteur EDF)
  - hybride (exemple : Home Assistant pour la mesure real_power + JSY-MK-194T pour l’énergie dérivée) → utile si le routeur est loin du point de mesure, ou si le contrat est en 0 injection (il faudra créer dans HA un capteur virtuel de simulation d’injection en estimant l’énergie potentielle non produite, cf. par exemple le projet [https://github.com/M3c4tr0x/ESP-PowerSunSensor](https://github.com/M3c4tr0x/ESP-PowerSunSensor))

## 1 - Partie Commune : la communication avec le JSY-MK-194T :

Ce fichier gère la communication avec la carte. Vous pouvez, si vous le souhaitez, remonter les mesures du JSY-MK-194T dans Home Assistant, voir l'exemple ci-dessous.
```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    refresh: 1s
    files: 
      # gestion du JSY-MK-194T
      - path: solar_router/jsy-mk-194t_common.yaml
        vars:          
          uart_tx_pin: GPIO26
          uart_rx_pin: GPIO27
          uart_baud_rate: 4800
          AP_Ch2_internal: "false" # optionnel, permet d'afficher un des sensors du JSY-MK-194T
```
Liste des capteurs du JSY-MK-194T accessibles :
```yaml linenums="1"
  U_Ch1_internal: "true"       # Voltage on Channel 1
  I_Ch1_internal: "true"       # Current on Channel 1
  AP_Ch1_internal: "true"      # Active Power of Channel 1
  PAE_Ch1_internal: "true"     # Positive Active Energy of Channel 1
  PF_Ch1_internal: "true"      # Power Factor on Channel 1
  NAE_Ch1_internal: "true"     # Negative Active Energy of Channel 1
  PD_Ch1_internal: "true"      # Power Direction on Channel 1
  PD_Ch2_internal: "true"      # Power Direction on Channel 2
  frequency_internal: "true"   # Frequency
  # Voltage on Channel 2 not implemented => same as Voltage on Channel 1
  I_Ch2_internal: "true"       # Current on Channel 2
  AP_Ch2_internal: "true"      # Active Power of Channel 2
  PAE_Ch2_internal: "true"     # Positive Active Energy of Channel 2
  PF_Ch2_internal: "true"      # Power Factor on Channel 2 
  NAE_Ch2_internal: "true"     # Negative Active Energy of Channel 2
```

## 2 - Mode Standalone
Ce mode permet au routeur d'être 100 % autonome au niveau des capteurs de puissance. La régulation est donc plus fine et plus rapide que lorsqu'on passe par des entités Home Assistant.
Il est important de noter que ceci fonctionne uniquement si votre système injecte le surplus dans le réseau. Dans le cas contraire, voir le paragraphe suivant.

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    refresh: 1s
    files: 
      # gestion du JSY-MK-194T (partie vue précedemment)
      - path: solar_router/jsy-mk-194t_common.yaml
        vars:          
          uart_tx_pin: GPIO26
          uart_rx_pin: GPIO27
          uart_baud_rate: 4800
          AP_Ch2_internal: "false" # optionnel, permet d'afficher un des sensors du JSY-MK-194T

      # mesure d'energie dérivé via JSY-MK-194T
      - path: solar_router/energy_counter_jsy-mk-194t.yaml

      # en mode automatique, mesure de puissance échangé avec le réseau via JSY-MK-194T
      - path: solar_router/power_meter_jsy-mk-194t.yaml
		vars:
		  consumption_sensor_internal: true # Permet d'éviter d'avoir le sensor "Consumption" d'affiché dans Home Assistant, car il n'est jamais utilisé et reste "indisponible" avec l'utilisation du JSY-MK-194T
```

## 3 - Mode Hybride
Ce mode permet l'utilisation du JSY-MK-194T pour mesurer l'énergie dans la charge uniquement. La mesure au niveau du réseau doit se faire via Home Assistant, à l'aide d'un capteur virtuel qui remonte une puissance d'injection estimée.
Il est utile dans les systèmes où il n'y a pas d'injection réelle dans le réseau, ou si la mesure n'est pas accessible car trop éloignée.

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    refresh: 1s
    files: 
      - path: solar_router/common.yaml 

      # gestion du JSY-MK-194T (partie vue précedemment)
      - path: solar_router/jsy-mk-194t_common.yaml
        vars:          
          uart_tx_pin: GPIO26
          uart_rx_pin: GPIO27
          uart_baud_rate: 4800
          AP_Ch2_internal: "false"

      # mesure d'energie dérivé via JSY-MK-194T
      - path: solar_router/energy_counter_jsy-mk-194t.yaml

      # en mode automatique et en ayant configuré un JSY-MK-194T pour le calcul de l'energie dérivée, mesure de puissance échangé 
      # avec le réseau via home assistant ( cas où le JSY n'a pas accès à la mesure, ou si on est en 0 injection)
      - path: solar_router/power_meter_home_assistant.yaml
        vars:
          main_power_sensor: sensor.puissance_soutiree_reseau_simulee_prevision_filtree_2
          consumption_sensor: sensor.inverter_activepower_load_sys
```
Ce package doit connaître le capteur à utiliser pour obtenir l'énergie échangée avec le réseau et l'énergie consommée par la maison.
Le capteur d'échange d'énergie avec le réseau doit être défini par `main_power_sensor` et le capteur de consommation par `consumption_sensor` dans la section substitutions de votre configuration, comme présenté dans l'exemple ci-dessus.

* `main_power_sensor` représente l'énergie échangée avec le réseau. Il est attendu que ce capteur soit en watts (W), qu'il soit positif (>0) lorsque l'électricité est consommée depuis le réseau et négatif (<0) lorsque l'électricité est envoyée au réseau. 

* `consumption_sensor` représente l'énergie consommée par votre maison. Cette information permet, par exemple, le calcul de l'énergie théorique reroutée.

!!! Warning "Disponibilité des données et fréquence de rafraîchissement"
    Ce compteur électrique s'appuie sur Home Assistant pour recueillir la valeur de l'énergie échangée avec le réseau. Il dépend également de la fréquence de mise à jour des capteurs. Si un capteur est mis à jour trop lentement, la régulation peut ne pas fonctionner comme prévu.

    Contrairement aux compteurs électriques de Home Assistant, les compteurs électriques natifs sont autonomes et peuvent continuer à réguler même si Home Assistant est hors ligne. Certains compteurs électriques peuvent avoir un accès direct aux mesures et être même indépendants du réseau.

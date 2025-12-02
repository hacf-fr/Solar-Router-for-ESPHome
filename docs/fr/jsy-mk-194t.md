# Détails sur l'utilisation d'un capteur de puissance JSY-MK-194T

Deux configurations sont possibles lors de l'utilisation de ce capteur :
  - standalone, on utilise les deux capteur du JSY-MK-194T (Ch1 : capteur sur la charge, Ch2 capteur de puissance de la mainson au niveau du compteur EDF)
  - hybride (exemple home assistant pour la mesure real_power + jsy-mk-194t pour l'energie dérivée) => utile si le routeur est loin du point de mesure, ou si contrat en 0 injection (il faudra creer dans HA un capteur virtuelle de simulation d'injection en estimant l'energie potentielle non produite cf par exemple le projet   https://github.com/M3c4tr0x/ESP-PowerSunSensor)

## 1 - Partie Commune : la communication avec le JSY-MK-194T :

Ce fichier gère la communication avec la carte, vous pouvez si vous le souhaitez, remonter les mesure du JSY-MK-194T dans home assistant, voir dans l'exemple ci-dessous
```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/XavierBerger/Solar-Router-for-ESPHome/
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
liste des sensors du JSY-MK194-T accéssible :
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
Ce mode permet au routeur d'être 100% autonome au niveau des capteur de puissance, la régulation est donc plus fine et rapide qu'en passant par des entité home assistant. 
Il est important de noter que ceci fonctionne uniquement si votre système injecte le surplus dans le réseau, dans le cas contraire, voir le paragraphe suivant.

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/XavierBerger/Solar-Router-for-ESPHome/
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
```

## 3 - Mode Hybride
Ce mode permet l'utilisation du JSY-MK-194T pour mesurer l'energie dans la charge uniquement, la mesure au niveau du réseau doit se faire par home assistant, via un capteur virtuel qui remonte un puissance d'injection estimée.
Il est utile dans les système où il n'y a pas d'injectione réel dans le réseau, ou si la mesure n'est pas accessible car trop éloignée.


```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/XavierBerger/Solar-Router-for-ESPHome/
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
      - path: solar_router/power_meter_home_assistant_with_energy_counter_jsy-mk-194t.yaml
        vars:
          main_power_sensor: sensor.puissance_soutiree_reseau_simulee_prevision_filtree_2
          consumption_sensor: sensor.inverter_activepower_load_sys
```
Ce package doit connaître le capteur à utiliser pour obtenir l'énergie échangée avec le réseau et l'énergie consommé par la maison. Le capteur déchange d'énergie avec le réseau doit être défini par `main_power_sensor` et la capteur de consommation par `consumption_sensor` dans la section `substitutions` de votre configuration comme présenté dans l'exemple ci-dessus.

* `main_power_sensor` représent l'energie echangée avec le réseau. Il est attendu que ce capteur soit en Watts (W), qu'il soit positif (>0) lorsque l'électricité est consommée depuis le réseau et négatif (<0) lorsque l'électricité est envoyée au réseau. 

* `consumption_sensor` représente l'énergie consomée par votre maison. Cette imformation permet, par exemple, le calcul de l'énergie théorique reroutée.

!!! warning "Disponibilité des données et fréquence de rafraîchissement"
  Ce compteur électrique s'appuie sur Home Assistant pour recueillir la valeur de l'énergie échangée avec le réseau. Il dépend également de la fréquence de mise à jour des capteurs. Si un capteur est mis à jour trop lentement, la régulation peut ne pas fonctionner comme prévu.
    
  Contrairement aux compteurs électriques de Home Assistant, les compteurs électriques natifs sont autonomes et peuvent continuer à réguler même si Home Assistant est hors ligne. Certains compteurs électriques peuvent avoir un accès direct aux mesures et peuvent même être indépendants du réseau.

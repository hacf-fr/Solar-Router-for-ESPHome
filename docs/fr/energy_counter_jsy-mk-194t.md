# Compteur d'énergie JSY-MK-194T

## Description

Le **compteur d'énergie JSY-MK-194T** mesure l'énergie réellement détournée vers la charge en utilisant les **relevés de courant du compteur de puissance double canal JSY-MK-194T**. Contrairement au compteur théorique, ce module s'appuie sur des mesures matérielles réelles plutôt que sur des calculs basés sur une puissance de charge déclarée, offrant ainsi un bilan plus précis de l'énergie effectivement consommée.

Ce package partage la couche de communication UART avec le [power meter jsy-mk-194t](power_meter_jsy-mk-194t.md) via le package `jsy-mk-194t_common.yaml`. Les deux packages doivent être inclus ensemble dans votre configuration.

![jsy-mk-194t](../images/jsy-mk-194t.png)


## 1 - Partie Commune, la communication avec le JSY-MK-194T :

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

## 2 - Activation du compteur d'énergie

Pour activer le compteur d'énergie, il suffit de l'ajouter à votre configuration comme dans l'exemple ci-dessous:


```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    refresh: 1s
    files: 
      - path: solar_router/energy_counter_jsy-mk-194t.yaml
```

Pour un exemple de mise en oeuvre, reporter vous à l'[exemple JSY-MK-149T](jsy-mk-194t.md).

### Variables

| Variable | Requis | Défaut | Description |
| --- | --- | --- | --- |
| — | — | — | Ce module n'a pas de variables de configuration. Il utilise les mesures du JSY-MK-194T configurées via `jsy-mk-194t_common.yaml`. |

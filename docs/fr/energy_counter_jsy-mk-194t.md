# Compteur d'énergie JSY-MK-194T

## Description

Le **compteur d'énergie JSY-MK-194T** mesure l'énergie réellement détournée vers la charge en utilisant les **relevés de courant du compteur de puissance double canal JSY-MK-194T**. Contrairement au compteur théorique, ce module s'appuie sur des mesures matérielles réelles plutôt que sur des calculs basés sur une puissance de charge déclarée, offrant ainsi un bilan plus précis de l'énergie effectivement consommée.

Ce package partage la couche de communication UART avec le [power meter jsy-mk-194t](power_meter_jsy-mk-194t.md) via le package `jsy-mk-194t_common.yaml`. Les deux packages doivent être inclus ensemble dans votre configuration.

![jsy-mk-194t](../images/jsy-mk-194t.png)


## Configuration de la partie commune

!!! note "Configuration partagée"
    Le fichier `solar_router/jsy-mk-194t_common.yaml` configure la communication UART et est utilisé à la fois par le compteur de puissance et le compteur d'énergie.

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
### Options des capteurs JSY-MK-194T

La tension du canal 2 n'est pas implémentée ; le compteur utilise la tension du canal 1.

| Variable | Requis | Défaut | Description |
| --- | --- | --- | --- |
| `U_Ch1_internal` | non | `"true"` | Masque la tension du canal 1 dans Home Assistant si `"true"` |
| `I_Ch1_internal` | non | `"true"` | Masque le courant du canal 1 dans Home Assistant si `"true"` |
| `AP_Ch1_internal` | non | `"true"` | Masque la puissance active du canal 1 dans Home Assistant si `"true"` |
| `PAE_Ch1_internal` | non | `"true"` | Masque l'énergie active positive du canal 1 dans Home Assistant si `"true"` |
| `PF_Ch1_internal` | non | `"true"` | Masque le facteur de puissance du canal 1 dans Home Assistant si `"true"` |
| `NAE_Ch1_internal` | non | `"true"` | Masque l'énergie active négative du canal 1 dans Home Assistant si `"true"` |
| `PD_Ch1_internal` | non | `"true"` | Masque le sens de la puissance du canal 1 dans Home Assistant si `"true"` |
| `PD_Ch2_internal` | non | `"true"` | Masque le sens de la puissance du canal 2 dans Home Assistant si `"true"` |
| `frequency_internal` | non | `"true"` | Masque la fréquence dans Home Assistant si `"true"` |
| `I_Ch2_internal` | non | `"true"` | Masque le courant du canal 2 dans Home Assistant si `"true"` |
| `AP_Ch2_internal` | non | `"true"` | Masque la puissance active du canal 2 dans Home Assistant si `"true"` |
| `PAE_Ch2_internal` | non | `"true"` | Masque l'énergie active positive du canal 2 dans Home Assistant si `"true"` |
| `PF_Ch2_internal` | non | `"true"` | Masque le facteur de puissance du canal 2 dans Home Assistant si `"true"` |
| `NAE_Ch2_internal` | non | `"true"` | Masque l'énergie active négative du canal 2 dans Home Assistant si `"true"` |

## Configuration du compteur d'énergie

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

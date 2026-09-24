# JSY-MK-194T Power Meter

## Description

Le compteur de puissance JSY-MK-194T partage un code commun avec le
[compteur d'énergie JSY-MK-194T](energy_counter_jsy-mk-194t.md) pour communiquer avec le module.
La suite de cette documentation explique comment configurer cette partie
commune et comment configurer un compteur de puissance JSY-MK-194T.

Ce package lit la puissance d'échange réseau sur le canal 2 du JSY-MK-194T via UART, et ne nécessite donc pas le réseau.

![jsy-mk-194t](../images/jsy-mk-194t.png)

## 1 – Partie commune : communication avec le JSY-MK-194T

Ce fichier gère la communication avec la carte. Ajoutez `jsy-mk-194t_common.yaml`
et configurez les GPIO selon votre matériel comme dans l'exemple ci-dessous :

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    refresh: 1s
    files: 
      # Gestion du JSY-MK-194T
      - path: solar_router/jsy-mk-194t_common.yaml
        vars:          
          uart_tx_pin: GPIO26
          uart_rx_pin: GPIO27
          uart_baud_rate: 4800
          AP_Ch2_internal: "false" # optionnel, permet d'afficher un des capteurs du JSY-MK-194T
```

### Variables (partie commune)

| Variable | Requis | Défaut | Description |
| --- | --- | --- | --- |
| `uart_tx_pin` | oui | — | Broche GPIO UART TX vers le JSY-MK-194T |
| `uart_rx_pin` | oui | — | Broche GPIO UART RX depuis le JSY-MK-194T |
| `uart_baud_rate` | oui | — | Débit UART (typiquement `4800`) |
| `U_Ch1_internal` | non | `"true"` | Masque Voltage Ch1 dans Home Assistant si `"true"` |
| `I_Ch1_internal` | non | `"true"` | Masque Current Ch1 dans Home Assistant si `"true"` |
| `AP_Ch1_internal` | non | `"true"` | Masque Active Power Ch1 dans Home Assistant si `"true"` |
| `PAE_Ch1_internal` | non | `"true"` | Masque Positive Active Energy Ch1 si `"true"` |
| `PF_Ch1_internal` | non | `"true"` | Masque Power Factor Ch1 si `"true"` |
| `NAE_Ch1_internal` | non | `"true"` | Masque Negative Active Energy Ch1 si `"true"` |
| `PD_Ch1_internal` | non | `"true"` | Masque Power Direction Ch1 si `"true"` |
| `PD_Ch2_internal` | non | `"true"` | Masque Power Direction Ch2 si `"true"` |
| `frequency_internal` | non | `"true"` | Masque Frequency si `"true"` |
| `U_Ch2_internal` | non | `"true"` | Masque Voltage Ch2 si `"true"` |
| `I_Ch2_internal` | non | `"true"` | Masque Current Ch2 si `"true"` |
| `AP_Ch2_internal` | non | `"true"` | Masque Active Power Ch2 si `"true"` (mettre `"false"` pour exposer) |
| `PAE_Ch2_internal` | non | `"true"` | Masque Positive Active Energy Ch2 si `"true"` |
| `PF_Ch2_internal` | non | `"true"` | Masque Power Factor Ch2 si `"true"` |
| `NAE_Ch2_internal` | non | `"true"` | Masque Negative Active Energy Ch2 si `"true"` |

## 2 – Activation du compteur de puissance

Pour activer le compteur de puissance, ajoutez-le à votre configuration comme
dans l'exemple ci-dessous :

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    refresh: 1s
    files: 
      - path: solar_router/power_meter_jsy-mk-194t.yaml
        vars:
          consumption_sensor_internal: "true" # Masque le capteur Consumption inutilisé dans Home Assistant
```

Pour un exemple de mise en œuvre, reportez-vous à l'[exemple JSY-MK-194T](jsy-mk-194t.md).

### Variables (compteur de puissance)

| Variable | Requis | Défaut | Description |
| --- | --- | --- | --- |
| `power_meter_activated_at_start` | non | `"0"` | Mettre à `"1"` pour activer le compteur au démarrage |
| `power_sign` | non | `"1"` | Multiplicateur de polarité (`"-1"` pour inverser l'orientation du TC) |
| `consumption_sensor_internal` | non | `"false"` | Mettre à `"true"` pour masquer le capteur Consumption inutilisé dans Home Assistant |

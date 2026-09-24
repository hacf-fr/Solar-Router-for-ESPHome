# Mechanical Relay Regulator

## Description

Ce régulateur effectue une **Régulation Tout ou Rien**.

Un relais est capable de laisser passer ou non le courant vers la charge. Il s'agit de la forme la plus simple de régulation : la charge est soit alimentée à pleine puissance, soit complètement éteinte.

!!! Attention "Soyez prudent lors du câblage et utilisez la broche Normalement Ouverte (NO)."

!!! Danger "Ce type de relais n'est compatible qu'avec [Engine 1 x switch](engine_1switch.md) et [Engine 1 x dimmer + 1 x bypass](engine_1dimmer_1bypass.md)"

## Diagramme

![Régulation tout ou rien](images/Regulation_on_off.png)

## Matériel

Ce régulateur fonctionne avec des relais mécaniques standards.

## Schéma de câblage

Le schéma suivant représente le câblage du relais :

![Schéma de câblage relais mécanique](images/mechanical_relay.drawio.png)

## Configuration

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  regulator:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/regulator_mechanical_relay.yaml
        vars:
          relay_regulator_gate_pin: GPIO22
```

### Variables

| Variable | Obligatoire | Défaut | Description |
| -------- | ----------- | ------ | ----------- |
| `relay_regulator_gate_pin` | oui | — | Broche GPIO connectée à la gâchette du relais. |

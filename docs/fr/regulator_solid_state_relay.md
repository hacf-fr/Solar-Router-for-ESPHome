# Solid State Relay Regulator

## Description

Ce régulateur effectue une **Régulation par Salves** (Burst Fire Regulation).

Un relais est capable de laisser passer ou non le courant vers la charge. En envoyant de petites parties de courant (clignotement), il est possible de dévier une quantité bien définie d'énergie vers la charge.

!!! tip "Astuce : Ce régulateur peut également être utilisé avec un gradateur"

## Diagramme

![Régulation par salves](images/Regulation_burst_fire.png)

??? note "Comment fonctionne ce régulateur ?"
    Ce régulateur envoie un signal PWM (Modulation de Largeur d'Impulsion) au relais. La période du PWM est de 330ms. Le rapport cyclique détermine la quantité d'énergie transférée.  
    Si vous voulez en savoir plus sur la façon dont un PWM peut réguler l'énergie transmise, vous pouvez vous référer à [Wikipédia](https://fr.wikipedia.org/wiki/Modulation_de_largeur_d%27impulsion).  
    <figure markdown="span">
      ![Exemples de rapport cyclique](images/Duty_Cycle_Examples.png){ width="300" } 
      <figcaption>Exemples de rapport cyclique (Source : Wikipédia)</figcaption>
    </figure>

## Matériel

![Relais à semi-conducteurs](images/SSR.png)

!!! warning
    Il est recommandé de fixer le relais à un dissipateur thermique.

## Schéma de câblage

Le schéma suivant représente le câblage du relais :

![Schéma de câblage relais à semi-conducteurs](images/solid_state_relay.drawio.png)

## Configuration

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  regulator:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/regulator_solid_state_relay.yaml
        vars:
          regulator_gate_pin: GPIO22
```

### Variables

| Variable | Obligatoire | Défaut | Description |
| -------- | ----------- | ------ | ----------- |
| `regulator_gate_pin` | oui | — | Broche GPIO connectée à la gâchette du relais. |

# Solid State Relay regulator

Ce régulateur effectue une **régulation par salves** (Burst Fire Regulation).

![texte alternatif](images/Regulation_burst_fire.png)

Un relais est capable de laisser passer ou non le courant vers la charge. En envoyant de petites parties de courant (clignotement), il est possible de dévier une quantité bien définie d'énergie vers la charge.

!!! tip "Astuce : Ce régulateur peut également être utilisé avec un gradateur"

??? note "Comment fonctionne ce régulateur ?"
    Ce régulateur envoie un signal PWM (Modulation de Largeur d'Impulsion) au relais. La période du PWM est de 330ms. Le rapport cyclique détermine la quantité d'énergie transférée.  
    Si vous voulez en savoir plus sur la façon dont un PWM peut réguler l'énergie transmise, vous pouvez vous référer à [Wikipédia](https://fr.wikipedia.org/wiki/Modulation_de_largeur_d%27impulsion).  
    <figure markdown="span">
      ![fonction triac](images/Duty_Cycle_Examples.png){ width="300" } 
      <figcaption>Exemples de rapport cyclique (Source : Wikipédia)</figcaption>
    </figure>

![SSR](images/SSR.png)

!!! warning
    Il est recommandé de fixer le relais à un dissipateur thermique.

Le schéma suivant représente le câblage du relais :

![relais](images/solid_state_relay.drawio.png)

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

Ce package nécessite la définition de la broche connectée à la gâchette du relais : `regulator_gate_pin`

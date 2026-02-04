# Mecanical Relay regulator

Ce régulateur effectue une **Régulation Tout ou Rien**.

![texte alternatif](images/Regulation_on_off.png)

Un relais est capable de laisser passer ou non le courant vers la charge.

Le schéma suivant représente le câblage du relais :

![relais](images/mecanical_relay.drawio.png)

!!! Attention "Soyez prudent lors du câblage et utilisez la broche Normalement Ouverte (NO)."

!!! Danger "Ce type de relais est uniquement compatible avec [Engine 1 x switch](engine_1switch.md) et [Engine 1 x dimmer + 1 x bypass](engine_1dimmer_1bypass.md)"

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  regulator:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/regulator_mecanical_relay.yaml
        vars:
          relay_regulator_gate_pin: GPIO22
```

Ce package nécessite la définition de la broche connectée à la porte du relais : `relay_regulator_gate_pin`

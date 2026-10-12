# Energy Counter Theorical

## Description

Le **Energy Counter Theorical** calcule la quantité d'énergie détournée vers la charge en se basant sur la **puissance de charge déclarée** (en Watts) et le **niveau de détournement** appliqué chaque seconde par l'engine. C'est un package optionnel qui ajoute une estimation des économies d'énergie à votre routeur solaire.

Le calcul étant purement théorique, ce compteur ne nécessite aucun matériel supplémentaire — il s'appuie entièrement sur le `router_level` interne de l'engine et sur la valeur de puissance de charge que vous configurez dans Home Assistant.

!!! attention "L'énergie économisée rapportée par ce compteur est à titre informatif uniquement"
    Rappelez-vous que les valeurs sont calculées et non mesurées.  
    Les valeurs présentées par ce capteur ne sont que des estimations de l'énergie détournée basées sur la configuration que vous avez faite dans Home Assistant.

## Configuration

Pour utiliser ce compteur, ajoutez les lignes suivantes à votre fichier de configuration.

```yaml
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/energy_counter_theorical.yaml
```

!!! question "Que se passe-t-il si l'énergie théorique déviée n'est pas consommée ?"
    Si l'eau dans la chaudière est déjà chaude, la régulation passe à 100 %, mais aucune énergie ne sera consommée.  
    Si le compteur de puissance utilisé fournit l'énergie consommée, le compteur d'énergie détecte la situation et rapporte une consommation nulle.  
    Si la consommation d'énergie n'est pas reportée, la consommation d'énergie théorique sera calculée à son maximum.

Ensuite, vous devez définir la puissance de charge (**Load power**) dans l'interface `Control` de Home Assistant. La puissance saisie doit refléter la puissance de l'élément branché sur le routeur solaire.

![texte alternatif](images/SolarRouterEnergyCounterTheoricalConfiguration.png)

L'énergie instantanée et cumulée détournée est disponible dans l'interface `sensors` :

![texte alternatif](images/SolarRouterEnergyCounterTheoricalSensors.png)

### Variables

| Variable | Requis | Défaut | Description |
| --- | --- | --- | --- |
| — | — | — | Ce module n'a pas de variables de configuration. La puissance de charge est définie à l'exécution via Home Assistant. |

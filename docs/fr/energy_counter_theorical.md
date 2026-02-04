# Energy Counter Theorical

Le **energy counter theorical** est conçu pour calculer la quantité d'énergie détournée vers la charge. *Il s'agit d'un package optionnel.*

La quantité d'énergie détournée est calculée en fonction de la puissance de la charge déclarée (en `W`) et du niveau d'énergie détourné chaque seconde.

!!! attention "L'énergie économisée rapportée par ce compteur est à titre informatif uniquement"
    Rappelez-vous que les valeurs sont calculées et non mesurées.  
    Les valeurs présentées par ce capteur ne sont que des estimations de l'énergie détournée basées sur la configuration que vous avez faite dans Home Assistant.

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

Ensuite, vous devez définir la puissance de charge (**Load power**)S dans l'interface `Control` de Home Assistant. La puissance saisie doit refléter la puissance de l'élément branché sur le routeur solaire.

![texte alternatif](images/SolarRouterEnergyCounterTheoricalConfiguration.png)

L'énergie instantanée et cumulée détournée est disponible dans l'interface `sensors` :

![texte alternatif](images/SolarRouterEnergyCounterTheoricalSensors.png)

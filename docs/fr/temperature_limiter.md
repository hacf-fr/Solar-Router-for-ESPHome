# Temperature limiter

## Description

Un *temperature limiter* surveille une source de température et **arrête le détournement d'énergie lorsqu'un seuil configurable est atteint**. Dès que la température redescend (ou remonte pour les systèmes de refroidissement) à un niveau sûr, la régulation est **réactivée automatiquement**.

Deux packages sont disponibles selon la façon dont la température est mesurée :

| Package | Source de température | Prérequis |
| --- | --- | --- |
| [`temperature_limiter_DS18B20.yaml`](temperature_limiter_DS18B20.md) | Capteur 1-Wire DS18B20 câblé directement sur l'ESP | Broche GPIO, sonde DS18B20 |
| [`temperature_limiter_home_assistant.yaml`](temperature_limiter_home_assistant.md) | N'importe quel capteur exposé dans Home Assistant | Entité capteur Home Assistant |

La régulation à 2 seuils est appelée hystérésis. Ce mécanisme évite les oscillations de la régulation.

??? Note "Plus de détails sur l'hystérésis et le trigger de Schmitt ici"
    L'implémentation de l'hystérésis dans ce package est similaire au circuit électronique appelé [trigger de Schmitt](https://fr.wikipedia.org/wiki/Trigger_de_Schmitt). Le circuit est appelé **trigger** car la sortie conserve sa valeur jusqu'à ce que l'entrée change suffisamment pour déclencher un changement.

    ![](images/hysteresis.png)  
    Fonction de transfert d'un trigger de Schmitt. Les axes horizontal et vertical représentent respectivement la tension d'entrée et la tension de sortie. T et −T sont les seuils de commutation, et M et −M sont les niveaux de tension de sortie.

    ![](images/schmitt_trigger.png)  
    Comparaison de l'action d'un comparateur ordinaire (A) et d'un trigger de Schmitt (B) sur un signal d'entrée analogique bruité (U). Les lignes pointillées vertes sont les seuils de commutation du circuit. Le trigger de Schmitt tend à éliminer le bruit du signal.

    source : [wikipedia](https://fr.wikipedia.org/wiki/Trigger_de_Schmitt)

!!! warning "Si la température n'est pas atteignable, la `safety limit` est activée et le détournement d'énergie est arrêté"

![HA](images/temperature_limiter_controls.png){ align=left }
!!! note ""
    **Contrôles**
    
    * ***Température de redémarrage***  
      Définit la température à laquelle la régulation peut redémarrer après une limite de sécurité.
    * ***Température d'arrêt***  
      Définit la température à laquelle la régulation est arrêtée en raison du seuil atteint.
    * ***Utiliser pour le refroidissement***  
      Lorsque la régulation est utilisée sur un système de chauffage, la *température de redémarrage* doit être inférieure à la *température d'arrêt*. C'est l'inverse pour un système de refroidissement.

<pre> 




</pre>

![HA](images/temperature_limiter_sensor.png){ align=left }
!!! note ""
    **Capteurs**
    
    * ***Limite de sécurité***  
      Ce capteur binaire indique si la limite de sécurité est activée ou non.
    * ***Température de sécurité***
      Ce capteur indique la température actuelle qui est comparée aux seuils.
<pre> 




</pre>

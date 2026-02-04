# Scheduler Forced Run / Planificateur marche forcée

Le *scheduler forced run / planificateur marche forcée* est conçu pour automatiser l'arrêt du routeur solaire et la marche forcée à une certainne puissance de la charge.

Exemples d'utilisation:

- Permettre une marche forcée de la charge pendant les heures creuses. (Router Level=100%)
- Désactiver le routeur et éteindre la charge afin de laisser la place à d'autres usages (Router Level=0%)

Ce *scheduler / planificateur* expose des contrôles afin de personnaliser l'automatisation à vos besoins depuis l'interface HomeAssistant.

![HA](images/SchedulerForcedRunInHomeAssistant.png){ align=left }
!!! note ""
    **Contrôles**
    
    * ***Activer le planificateur***  
      Contrôle si le planificateur doit être activé ou non.
      Ceci permet de désactiver la planification suivant vos propres critères (par exemple si votre chauffe-eau à eu déjà assez de puissance en journée, inutile de faire une marche forcée la nuit).
    * ***Heure de début du planifacteur***   
      De 0h à 23h. Heure à laquelle la marche forcée commence.
    * ***Minute de début du planifacteur***  
      De 0 minute à 55 minutes, avec un pas de 5 minutes.
      Si l'heure de début est à 1h et les minutes à 15 minutes, alors la planification de marche forcée débute à 1h15.
    * ***Seuil de vérification de l'arrêt du planificateur***  
      De 0 minute à 720 minutes, avec un pas de 5 minutes.
      Cette option permet de définir une marge de sécurité afin de vérifier toutes les 5 minutes entre la fin de la planification + X minutes que le routeur à bien été remis en fonctionnement.
      Par exemple si l'heure de fin est définit à 2h00 et le seuil de vérification à 60 minutes, toutes les 5 minutes entre 2h et 3h (inclus) le planificateur relance le routeur solaire s'il est arrêté.
      Ceci permet de s'assurer que la planification prend fin même s'il y a un plantage de l'ESP lors de l'heure de fin.
    * ***Heure de fin du planifacteur***   
      De 0h à 23h. Heure à laquelle la marche forcée s'arrête.
    * ***Minute de fin du planifacteur***  
      De 0 minute à 55 minutes, avec un pas de 5 minutes.
      Si l'heure de fin est à 1h et les minutes à 15 minutes, alors la planification de marche forcée termine à 1h15.
    * ***Niveau du routeur***  
      De 0% à 100% avec un pas de 1%.
      Définit le niveau cible où le routeur sera réglé pendant le fonctionnement du planificateur entre l'heure de début et de fin.



## Configuration basique

Pour utiliser plusieurs ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  scheduler_forced_run:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/scheduler_forced_run.yaml
```

## Configuration multiple

Pour utiliser plusieurs instances de ce package, par exemple pour programée une marche forcée en journée et une autre la nuit, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  scheduler_forced_run:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/scheduler_forced_run.yaml
        vars:
          scheduler_unique_id: "NightForced"
      - path: solar_router/scheduler_forced_run.yaml
        vars:
          scheduler_unique_id: "DayForced"
```

Il est necessaire de définir `scheduler_unique_id` dans la section `vars` comme montré dans l'exemple ci-dessus. Cette variable ne doit pas contenir d'espace ou de caractères spéciaux, et doit être unique pour chaque *scheduler forced run / planificateur marche forcée*. Elle permet d'avoir autant d'instance que nécessaire sans aucun conflits.


## Configuration avancée (script)

Ce package fournit la possibilité d'appeler un script personnalisé toutes les 5 minutes lors de l'éxécution de la planification.

Par exemple pour arrêter la planification avant l'heure de fin si un capteur de température atteint une valeur cible, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  scheduler_forced_run:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/scheduler_forced_run.yaml
        vars:
          scheduler_unique_id: "NightForced"
          custom_script: check_temperature_for_NightForcedScheduler
          
script:
  # ...
  - id: check_temperature_for_NightForcedScheduler
    mode: single
    then:
        -if:
            condition:
                - lambda: return id(myTemperatureSensor).state >= 80;
            then:
                # Name of the switch is different for every scheduler, it depend of the scheduler_unique_id (default value: forced) : "${scheduler_unique_id}_scheduler_activate"
                - switch.turn_off: NightForced_scheduler_activate
```

Il est necessaire de définir `custom_script` dans la section `vars` comme montré dans l'exemple ci-dessus. Cette variable permet de transmettre le nom du script qui sera appellé toutes les 5 minutes lors de l'éxécution du planificateur.


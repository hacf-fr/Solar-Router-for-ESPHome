# Scheduler Forced Run / Planificateur marche forcée

## Description

Le *scheduler forced run* / planificateur marche forcée automatise l'arrêt du routeur solaire et la marche forcée à un niveau de puissance configuré pendant une fenêtre horaire.

Exemples d'utilisation :

- Permettre une marche forcée de la charge pendant les heures creuses (Router Level = 100 %)
- Désactiver le routeur et éteindre la charge afin de laisser la place à d'autres usages (Router Level = 0 %)

Ce *scheduler* expose des contrôles pour personnaliser l'automatisation depuis l'interface Home Assistant.

![HA](images/SchedulerForcedRunInHomeAssistant.png){ align=left }
!!! note ""
    **Contrôles**
    
    * ***Activer le planificateur***  
      Contrôle si le planificateur doit être activé ou non.
      Ceci permet de désactiver la planification selon vos propres critères (par exemple si votre chauffe-eau a déjà eu assez de puissance en journée, inutile de faire une marche forcée la nuit).
    * ***Heure de début***   
      De 0 h à 23 h. Heure à laquelle la marche forcée commence.
    * ***Minute de début***  
      De 0 minute à 55 minutes, avec un pas de 5 minutes.
      Si l'heure de début est 1 h et les minutes 15, alors la marche forcée débute à 1 h 15.
    * ***Seuil de vérification de fin***  
      De 0 minute à 720 minutes, avec un pas de 5 minutes.
      Cette option définit une marge de sécurité pour vérifier toutes les 5 minutes, entre la fin de la planification + X minutes, que le routeur a bien été remis en fonctionnement.
      Par exemple, si l'heure de fin est définie à 2 h 00 et le seuil de vérification à 60 minutes, toutes les 5 minutes entre 2 h et 3 h (inclus) le planificateur relance le routeur solaire s'il est arrêté.
      Ceci permet de s'assurer que la planification prend fin même en cas de plantage de l'ESP à l'heure de fin.
    * ***Heure de fin***   
      De 0 h à 23 h. Heure à laquelle la marche forcée s'arrête.
    * ***Minute de fin***  
      De 0 minute à 55 minutes, avec un pas de 5 minutes.
      Si l'heure de fin est 1 h et les minutes 15, alors la marche forcée se termine à 1 h 15.
    * ***Niveau du routeur***  
      De 0 % à 100 % avec un pas de 1 %.
      Définit le niveau cible auquel le routeur sera réglé pendant le fonctionnement du planificateur entre l'heure de début et de fin.

## Configuration

### Configuration basique

Pour utiliser une seule instance de ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  scheduler_forced_run:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/scheduler_forced_run.yaml
```

### Configuration multiple

Pour utiliser plusieurs instances de ce package, par exemple une marche forcée en journée et une autre la nuit, ajoutez les lignes suivantes à votre fichier de configuration :

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

### Configuration avancée (script personnalisé)

Ce package peut appeler un script personnalisé toutes les 5 minutes pendant l'exécution de la planification.

Par exemple, pour arrêter la planification avant l'heure de fin si un capteur de température atteint une valeur cible :

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
        - if:
            condition:
                - lambda: return id(myTemperatureSensor).state >= 80;
            then:
                # Le nom de l'interrupteur dépend de scheduler_unique_id (défaut : Forced) :
                # "${scheduler_unique_id}_scheduler_activate"
                - switch.turn_off: NightForced_scheduler_activate
```

### Variables

| Variable | Requis | Défaut | Description |
| --- | --- | --- | --- |
| `scheduler_unique_id` | non | `"Forced"` | Identifiant unique de cette instance. Requis en cas d'instances multiples. Ne doit pas contenir d'espaces ni de caractères spéciaux. |
| `custom_script` | non | `${scheduler_unique_id}_fake_script` | Nom d'un script appelé toutes les 5 minutes pendant l'exécution du planificateur |

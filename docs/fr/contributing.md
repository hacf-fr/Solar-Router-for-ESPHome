# Contribuer au développement

**Solar Router for [ESPHome](http://esphome.io)** est conçu de manière modulaire pour faciliter la personnalisation avec différents compteurs de puissance et différents régulateurs.  
Vous souhaitez contribuer ? Vous êtes les bienvenus et vous trouverez ci-dessous quelques recommandations pour le faire.

!!! Tip "Astuce : Inspirez vous du code déjà développé aller plus vite."


## Développer un **Hardware**

Vous pouvez proposer n'importe quel matériel selon vos besoins. Si ce nouveau matériel nécessite l'utilisation de GPIO, les broches utilisées par votre matériel doivent être configurées dans la section `vars` associée à votre package.

Une documentation doit être ajoutée décrivant ce nouveau matériel et ses contraintes (Ex : liste des GPIOs et utilisation). Voir le chapitre [mettre à jour la documentation](#mettre-a-jour-la-documentation) ci-dessous.

## Développer un **Package Logiciel**

### Configurer l'environnement de développement

Pour contribuer à **Solar Router for ESPHome**, développer une nouvelle fonctionnalité sur votre ordinateur et proposer une **pull request**, vous devez :

- Forker le [dépôt **Solar Router for ESPHome**](https://github.com/XavierBerger/Solar-Router-for-ESPHome) sur Github
- Cloner votre dépôt forké sur votre PC
- Créer une branche de développement à partir de **main**
- [Créer et activer un environnement virtuel Python](https://docs.python.org/3/library/venv.html)
    ```shell
    python -m venv venv
    source venv/bin/activate
    ```

    !!! Tip "Go faster with Linux"
        Add an alias to you venv :  
        `echo "alias venv='. ~/.virtualenvs/python3/bin/activate'" >> ~/.bash_aliases `  
        Reopen you console and call `venv` to activate you Python virtual environment.

- Installer ESPHome CLI et autres dépendances :
    ```shell
    pip install -r requirements.txt
    ```
- Installer et tester votre code sur votre appareil avec la commande `esphome` :
    ```shell
    esphome run my_configuration.yaml
    ```

    !!! Tip "Astuce pour developper en local"
        **Solar-Router-For-ESPHome** est conçu pour utilisé des fichier stocker sur GitHub.  
        Le répertoire `tools` contient le script `convert_to_local_source.py` qui permet de convertir un fichier `yaml` pointant vers GitHub vers un fichier source avec le même nom et préfixé par `local_` et pointant sur les fichiers située dans le sous-répertoire `solar-router`.  
        Ainsi, les modifications faites locallements seront prisent en compte immédiatement par la commande `esphome run local_<mon_fichier_yaml>`.

- Une fois stabilisé, pousser les modifications sur votre dépôt
- Et enfin, proposer une *pull request* depuis votre fork vers le dépôt officiel

### Développer un **Power Meter**

Un **Power Meter** est un composant conçu pour fournir et mettre à jour périodiquement un capteur nommé `real_power`.

```yaml linenums="1"
sensor:
  # Capteur montrant la consommation de puissance actuelle
  - id: real_power
    platform: template
    name: "Puissance Réelle"
    device_class: "power"
    unit_of_measurement: "W"
    update_interval: 1s
```

Ce capteur est utilisé par les **Moteurs** pour obtenir la valeur de la puissance échangée avec le réseau.

Si ce nouveau compteur de puissance nécessite une configuration spécifique, les paramètres requis doivent être ajoutés dans la section `vars` associée à votre package.

Une documentation doit être ajoutée décrivant le compteur de puissance et comment le configurer. Voir le chapitre [mettre à jour la documentation](#mettre-a-jour-la-documentation) ci-dessous.

### Développer des **Regulators**

Un **Regulator** doit gérer le pourcentage d'énergie envoyé à sa charge en fonction de son capteur de niveau de régulation (par exemple, `regulator_opening` pour TRIAC/SSR). Le niveau de chaque régulateur peut varier de 0 (où aucune énergie n'est envoyée à la charge) à 100 (où toute l'énergie possible est envoyée à la charge).

L'état global du système est géré par le capteur `router_level`, qui contrôle tous les régulateurs. Quand `router_level` est à 0, tous les régulateurs doivent être éteints, et quand il est à 100, tous les régulateurs doivent être au maximum. Pour les systèmes avec un seul régulateur, le niveau du régulateur reflète généralement le `router_level`, mais ils restent séparés car `router_level` est utilisé pour les indicateurs LED et la logique de comptage d'énergie.

Voici un exemple d'implémentation d'un régulateur (extrait de [regulator_triac.yaml](https://github.com/XavierBerger/Solar-Router-for-ESPHome/blob/main/solar_router/regulator_triac.yaml)) utilisant le composant `light` et sa `brightness` pour contrôler la dérivation d'énergie :

```yaml linenums="1"
script:
  # Appliquer la régulation sur le triac en utilisant le composant light
  - id: regulation_control
    mode: single
    then:
      # Appliquer router_level au triac en utilisant le composant light
      - light.turn_on:
          id: dimmer_controller
          brightness: !lambda return id(regulator_opening).state/100.0;
```

Vous pouvez développer un ou plusieurs régulateurs pour travailler ensemble dans le même système. Chaque régulateur doit :
- Avoir son propre capteur de niveau allant de 0 à 100
- Répondre aux changements du `router_level` global du système
- Gérer sa logique de contrôle matériel spécifique

Si ce nouveau compteur de puissance nécessite une configuration spécifique, les paramètres requis doivent être ajoutés dans la section `vars` associée à votre package.

Une documentation doit être ajoutée décrivant le compteur de puissance et comment le configurer. Voir le chapitre [mettre à jour la documentation](#mettre-a-jour-la-documentation) ci-dessous.

## Mettre à jour la **Documentation**

La documentation est écrite en utilisant [mkdocs](https://www.mkdocs.org/) et [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/).

Pour installer `mkdocs`, vous devez installer [Python](https://python.org) puis :

- Créer un environnement virtuel (voir la [documentation Python](https://docs.python.org/3/library/venv.html)).
- Installer les modules requis avec la commande suivante `pip install -r requirements.txt`.

La documentation est stockée dans le répertoire `docs`. Pour voir vos modifications en temps réel dans votre navigateur, exécutez la commande `mkdocs serve` et naviguez sur [http://127.0.0.1:8000](http://127.0.0.1:8000)

!!! note "Mise à jour du Changelog"
    Le Changelog n'est disponible que dans la [documentation](https://xavierberger.github.io/Solar-Router-for-ESPHome/changelog/) officiellement publiée.  
    Le Changelog est mis à jour manuellement après la publication d'une nouvelle version.

    Le Changelog est généré en utilisant `git-cliff`.  
    Les versions sont basées sur les tags.  
    Les lignes ajoutées dans le changelog sont basées sur les *messages de commit de fusion*.

    Le script `tools\update_documentation.sh` est conçu pour mettre à jour `changelog.md`, générer et publier la documentation `mkdocs` sur les [pages github](https://xavierberger.github.io/Solar-Router-for-ESPHome/).  
    **Le script de mise à jour de la documentation est destiné à être utilisé uniquement par le mainteneur du dépôt.**


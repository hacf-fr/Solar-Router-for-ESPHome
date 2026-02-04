# Installation et Configuration

Pour installer votre routeur solaire, vous devez définir l'architecture de votre solution entre une installation [autonome](firmware.md#configuration-autonome), une installation fonctionnant avec un [proxy](firmware.md#configuration-avec-proxy-de-compteur-denergie) ou une installation avec [plusieurs routeurs solaires](firmware.md#configuration-avec-plusieurs-routeurs-solaires).

### Étape 1 : Installer et configurer le firmware ESPHome

Installez [ESPHome](https://esphome.io) sur votre ESP comme décrit dans la documentation [Ready-Made Project](https://esphome.io/projects/).  
Sélectionnez **"Empty ESPHome device"**.

Adoptez-le dans [Home Assistant](https://home-assistant.io).

!!! important "Reconnexion Wifi"
    Supprimez `ap:` et `captive_portal:`.  
    *Cela pourrait empêcher le routeur solaire de se connecter au WiFi en cas de perte de connexion*

### Étape 2 : Sélectionner les packages

Un **routeur solaire** nécessite 3 packages : un **power meter**, un **regulator** et un **engine**.

Un **proxy** n'a besoin que d'un package **power meter**

#### Étape 2.1 : Sélectionner un power meter

* [Fronius](power_meter_fronius.md)  
    Pour obtenir les données de puissance de l'onduleur Fronius (Testé sur Gen24 Primo)
* [Home Assistant](power_meter_home_assistant.md)  
    Pour obtenir les données de puissance du capteur Home Assistant
* [Shelly EM](power_meter_shelly_em.md)  
    Pour obtenir les données de puissance d'un Shelly EM
* [Client Proxy](power_meter_proxy_client.md)  
    Pour obtenir les données de puissance de l'extérieur du routeur solaire

!!! abstract "Contribuer"
    Vous êtes développeur et votre power meter manque dans cette liste, référez-vous à la section [contribuer](contributing.md) pour voir comment contribuer à ce projet.

#### Étape 2.2 : Sélectionner un Regulator

* Pour les regulators pouvant être contrôlés de 0% à 100%
    * [Triac](regulator_triac.md)  
    Réguler l'énergie avec un gratateur
    * [Relais Statique](regulator_solid_state_relay.md)  
    Réguler l'énergie avec un relais statique
* Pour les regulators qui ne peuvent être que allumés/éteints
    * [Relais mécanique](regulator_mecanical_relay.md)  
    Réguler l'énergie avec un relais mécanique

!!! abstract "Contribuer"
    Vous êtes développeur et votre regulator manque dans cette liste, référez-vous à la section [contribuer](contributing.md) pour voir comment contribuer à ce projet.

#### Étape 2.3 : Ajouter un engine

* [Régulation progressive](engine_1dimmer.md)  
  Lit l'échange de puissance avec le réseau, déterminer et appliquer le pourcentage d'ouverture du regulator.

* [Régulation tout ou rien](engine_1switch.md)  
  Lit l'échange de puissance avec le réseau, et commencer à détourner l'énergie si un seuil est atteint et arrêter si un autre seuil est atteint.

#### Étape 2.4 : Ajouter un Compteur d'Énergie (*Optionnel*)

* [Compteur d'énergie théorique](energy_counter_theorical.md)  
  Calculer l'énergie économisée basée sur l'énergie détournée et la puissance de charge.

#### Étape 2.5 : Ajouter un Planificateur (*Optionnel*)

* [Planificateur de marche forcée](scheduler_forced_run.md)  
  Stop le routeur solaire et force la puissance de charge entre une heure de début et de fin.

### Étape 3 : Configurer votre routeur solaire

Chaque package nécessite une configuration qui se fait dans la section `substitution`.  
*Référez-vous à la documentation des packages sélectionnés et ajoutez la configuration à la fin de votre fichier yaml.*

Vous pouvez vous référer aux exemples pour voir comment configurer votre yaml pour une installation [autonome](example_standalone.md) ou une installation [basée sur un proxy](example_proxy.md).

!!! example "Plus d'exemples sont disponibles sur [github](https://github.com/hacf-fr/Solar-Router-for-ESPHome)"

### Étape 4 : Téléverser le firmware

Installez le Routeur Solaire sur votre ESP en utilisant OTA depuis Home Assistant.

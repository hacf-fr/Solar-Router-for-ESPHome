# Firmware

## Description

Le firmware est divisé en plusieurs *packages* que vous assemblez selon vos besoins.

![combinaison des packages](images/packages.drawio.png)

Les *packages* sont :

* **Power meter** : mesure l'énergie échangée avec le réseau.
* **Engine** : décide quelle quantité de surplus détourner vers la charge, et quand.
* **Regulator** : canalise le surplus d'énergie vers une charge désignée.
* **Energy counter** : rapporte la quantité d'énergie détournée vers la charge.
* **Temperature limiter** : arrête le détournement lorsqu'une limite de température est atteinte.
* **Scheduler** : planifie des fenêtres de marche forcée ou d'inhibition.

## Choisir une architecture

| Architecture | Cartes ESP | Cas d'usage typique | Avantages | Inconvénients |
| --- | --- | --- | --- | --- |
| [Autonome](#configuration-autonome) | 1 × ESP32 | Compteur et charge proches | Installation la plus simple, latence minimale | Tout le câblage sur une seule carte |
| [Proxy de compteur](#configuration-avec-proxy-de-compteur-denergie) | 1 × ESP compteur + 1 × ESP routeur | Compteur loin de la charge (ex. : tableau vs chauffe-eau) | Emplacement flexible ; le proxy peut tourner sur ESP8266/ESP8285 | Nécessite un réseau local fiable |
| [Plusieurs routeurs](#configuration-avec-plusieurs-routeurs-solaires) | 1 × routeur primaire + 1+ routeurs secondaires | Plusieurs charges à détourner en séquence | S'étend à davantage de charges | Ajuster soigneusement réactivité et cibles pour éviter les conflits |

**Recommandation :** commencez par une configuration **autonome** si le compteur et la charge peuvent partager le même ESP. Utilisez un **proxy** lorsque le TC/compteur est dans le tableau électrique et que le régulateur doit être près de la charge. Utilisez **plusieurs routeurs** uniquement lorsque vous devez détourner vers plus d'une charge.

## Packages

Les *packages* peuvent être combinés pour créer différentes configurations de routeurs solaires, comme dans les exemples suivants.

### Configuration autonome

Dans cette configuration autonome, un seul ESP32 exécute tous les *packages* requis (power meter + engine + régulateur).

![connexion matérielle](images/standalone.drawio.png){width=374}

### Configuration avec proxy de compteur d'énergie

Dans cette configuration avec proxy, deux ESP se partagent le travail. Le premier (par exemple dans le tableau électrique) recueille les informations du compteur. Le second (par exemple près du chauffe-eau) obtient ces informations via le réseau et effectue la régulation.

![connexion matérielle](images/with_proxy.drawio.png){width=535}

!!! note
    Un proxy de compteur d'énergie ne nécessite pas beaucoup de puissance CPU et peut tourner sur un ESP8285 ou ESP8266.

### Configuration avec plusieurs routeurs solaires

Dans cette configuration à plusieurs routeurs solaires, deux routeurs sont installés. Le premier lit la puissance échangée avec le réseau et détourne le surplus vers un chauffe-eau. Le second lit les informations d'échange depuis le premier via un proxy de compteur. Sur la base de ces informations, il détourne le surplus vers une autre charge (par exemple un système antigel).

![connexion matérielle](images/multiple_routers.drawio.png){width=756}

!!! note
    La `réactivité` et l'`échange cible avec le réseau` doivent être ajustés soigneusement sur les deux routeurs solaires pour éviter les conflits de régulation.

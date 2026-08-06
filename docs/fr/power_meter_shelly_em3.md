# Power meter Shelly EM3 Pro / Pro 3EM

Ce *power meter* est conçu pour obtenir la consommation d'énergie directement à partir d'un compteur d'énergie triphasé Shelly EM3 Pro / Pro 3EM via HTTP (API Gen2/Gen3 "RPC").

Pour utiliser ce package, ajoutez les lignes suivantes à votre fichier de configuration :

```yaml linenums="1"
packages:
  power_meter:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    file: solar_router/power_meter_shelly_em3.yaml
    vars:
      power_meter_ip_address: "192.168.1.21"
```

Ce package doit connaître l'adresse IP du Shelly EM3 Pro / Pro 3EM. L'adresse IP doit être définie par `power_meter_ip_address` dans la section `vars` de votre configuration, comme dans l'exemple ci-dessus.

!!! note "Capteurs par phase"
    Le package expose les trois puissances actives par phase en tant que capteurs internes (pour le réglage). Définissez `show_phase_power: "True"` dans `vars` pour les rendre visibles dans Home Assistant.

!!! note "En-tête d'authentification HTTP"
    Ce *power meter* permet de définir l'en-tête d'authentification HTTP avec la variable `power_meter_auth_header`.
    Cette variable peut être définie dans la section `vars`.

!!! note "Identifiant du composant EM"
    Si l'identifiant du composant EM du compteur diffère de la valeur par défaut, définissez `power_meter_emeter_id` dans `vars`.

## Somme triphasée

Sur un abonnement triphasé, le compteur additionne les trois phases et ne facture que la valeur **nette**. Lorsqu'une phase produit plus (photovoltaïque) que les deux autres ne consomment, c'est le bon moment pour détourner l'énergie.

Ce *power meter* utilise donc la *somme arithmétique* des trois puissances actives par phase comme signal d'échange avec le réseau :

```
S_grid = a_act_power + b_act_power + c_act_power  ==  total_act_power
```

* signe `+` : l'énergie est prélevée du réseau
* signe `-` : l'énergie est réinjectée sur le réseau

Avec le détournement sur la somme triphasée, le routeur solaire ne détourne l'énergie que lorsque toute l'installation est en surplus, sans jamais prélever du réseau pour alimenter la charge.

Ce package est activé/désactivé à l'aide d'une variable globale `power_meter_activated`. Par défaut, un compteur de puissance est désactivé au démarrage. L'interrupteur d'activation dans home assistant détermine si le compteur de puissance doit être démarré ou non.

Si ce compteur de puissance est utilisé à l'intérieur d'un proxy, il est nécessaire de l'activer au démarrage en définissant `power_meter_activated_at_start` à `1` dans votre fichier de configuration yaml, comme dans l'exemple ci-dessous :

```yaml linenums="1"
power_meter_activated_at_start: "1"
```

!!! warning "Dépendance réseau"
    Ce *power meter* nécessite le réseau pour recueillir des informations sur l'énergie échangée avec le réseau électrique.
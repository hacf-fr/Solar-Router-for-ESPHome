# Compteur de puissance - Enphase Envoy

Ce compteur de puissance lit la puissance d'importation/exportation du réseau à partir d'une passerelle Enphase Envoy en utilisant l'API HTTP locale. Il est compatible avec les anciens appareils Envoy et Envoy-S qui ne nécessitent pas d'authentification basée sur un token.

## Prérequis

- **Adresse IP ou nom d'hôte** : L'adresse IP ou le nom d'hôte de la passerelle Envoy (par exemple, `192.168.1.50` ou `envoy.local`).

## Configuration

Pour utiliser ce compteur de puissance, incluez ce qui suit dans votre fichier YAML principal :

```yaml
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome
    refresh: 1d
    files:
      - path: solar_router/common.yaml
      - path: solar_router/power_meter_enphase_envoy.yaml
        vars:
          power_meter_ip_address: "192.168.1.50"
```

## Détails de l'API

- **Endpoint** : `GET http://<envoy>/production.json`
- **Mesure** : La mesure `net-consumption` (`consumption[1].wNow`) représente la puissance échangée avec le réseau :
  - **Valeur positive** : L'énergie est tirée du réseau.
  - **Valeur négative** : L'énergie est poussée vers le réseau (surplus solaire).

## Remarques

- Ce compteur de puissance est conçu pour les appareils Enphase Envoy exécutant des versions de firmware antérieures à 7.x.
- Aucune authentification n'est requise pour cette configuration.

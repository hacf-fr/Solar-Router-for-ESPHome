# Compteur de puissance - Enphase IQ Gateway

Ce compteur de puissance lit la puissance d'importation/exportation du réseau à partir d'une passerelle Enphase IQ Gateway en utilisant l'API HTTPS locale avec authentification basée sur un token. Il est requis pour toutes les passerelles Enphase IQ Gateway modernes (anciennement "Envoy") exécutant le firmware 7.x et versions ultérieures.

## Prérequis

- **Adresse IP ou nom d'hôte** : L'adresse IP ou le nom d'hôte de la passerelle IQ Gateway (par exemple, `192.168.1.50` ou `envoy.local`).
- **JWT Token** : Un token JWT utilisé pour s'authentifier avec la passerelle IQ Gateway.

## Obtention du JWT Token

Pour obtenir le JWT token :

1. Connectez-vous à [https://enlighten.enphaseenergy.com](https://enlighten.enphaseenergy.com).
2. Accédez à votre système, puis ouvrez les outils de développement de votre navigateur (F12).
3. Allez dans **Application → Cookies** et copiez la valeur de `enlighten-4-token`.

Alternativement, utilisez l'outil communautaire : [https://entrez.enphaseenergy.com](https://entrez.enphaseenergy.com) (génère un token d'accès local).

**Note** : Les tokens sont valides pour 1 an. Renouvelez-les lorsqu'ils expirent.

## Configuration

Pour utiliser ce compteur de puissance, incluez ce qui suit dans votre fichier YAML principal :

```yaml
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome
    refresh: 1d
    files:
      - path: solar_router/common.yaml
      - path: solar_router/power_meter_enphase_iq_gateway.yaml
        vars:
          power_meter_ip_address: "192.168.1.50"
          enphase_token: "eyJhbGciOi..."
```

## Détails de l'API

- **Endpoint** : `GET https://<gateway>/production.json`
- **Authentification** : Le token JWT Bearer est envoyé dans l'en-tête `Authorization`.
- **Vérification SSL** : Désactivée (la passerelle IQ Gateway utilise un certificat auto-signé).
- **Mesure** : La mesure `net-consumption` (`consumption[1].wNow`) représente la puissance échangée avec le réseau :
  - **Valeur positive** : L'énergie est tirée du réseau.
  - **Valeur négative** : L'énergie est poussée vers le réseau (surplus solaire).

## Remarques

- Ce compteur de puissance est conçu pour les passerelles Enphase IQ Gateway exécutant le firmware 7.x et versions ultérieures.
- La vérification SSL est désactivée en raison de l'utilisation d'un certificat auto-signé par la passerelle IQ Gateway.

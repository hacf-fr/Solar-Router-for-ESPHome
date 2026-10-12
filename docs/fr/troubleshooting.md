# Dépannage

## Description

Cette page regroupe les problèmes courants du Solar Router for ESPHome et la façon de les diagnostiquer. Commencez par les LED, puis vérifiez le compteur de puissance et le comportement de régulation.

Pour l'installation, voir [Installation](installation.md). Pour le choix d'architecture, voir [Firmware](firmware.md).

## Checklist de diagnostic

1. L'ESP est-il en ligne dans Home Assistant ?
2. Que montrent les [LED d'état](engine.md#leds-de-retour-utilisateur) ?
3. L'interrupteur **Activate Solar Routing** est-il ON ?
4. `real_power` se met-il à jour environ une fois par seconde (pas bloqué / pas `unknown`) ?
5. Une [limite de sécurité température](temperature_limiter.md) est-elle active ?
6. Les valeurs `target_grid_exchange`, `up_reactivity` et `down_reactivity` sont-elles adaptées à votre installation ?

En option : activez les [capteurs de debug](debug_sensors.md) et vérifiez les [versions des modules](module_version.md).

## LED d'état

| LED | Motif | Signification |
| --- | --- | --- |
| Jaune | ÉTEINTE | Pas d'alimentation / carte non alimentée |
| Jaune | ALLUMÉE | Connectée au réseau |
| Jaune | CLIGNOTANTE | Tentative de reconnexion réseau |
| Jaune | CLIGNOTEMENT RAPIDE | Erreur de lecture de la puissance d'échange (`real_power` est NaN) |
| Verte | ÉTEINTE | Régulation automatique désactivée |
| Verte | ALLUMÉE | Régulation active, pas de détournement |
| Verte | CLIGNOTANTE | Détournement d'énergie en cours vers la charge |

Détails : [Aperçu des engines — LED de retour utilisateur](engine.md#leds-de-retour-utilisateur).

## Problèmes courants

### La LED jaune clignote rapidement / `real_power` est `unknown` ou NaN

**Cause :** le compteur de puissance ne lit pas une valeur valide.

**Vérifications :**

* Compteurs réseau (Fronius, Shelly, client proxy) : appareil joignable sur le LAN ? `power_meter_ip_address` correcte ?
* Compteur Home Assistant : identifiants d'entités corrects ? Capteur assez fréquent ? Voir [compteur Home Assistant](power_meter_home_assistant.md).
* Proxy : l'ESP proxy est-il en ligne et `power_meter_activated_at_start: "1"` est-il défini sur le proxy ?
* JSY-MK-194T : broches UART et débit corrects ? Voir [compteur JSY-MK-194T](power_meter_jsy-mk-194t.md).
* Essayez `power_sign: "-1"` si l'orientation du TC est inversée (valeurs miroir).

### Le routeur ne détourne jamais (LED verte reste ALLUMÉE)

**Vérifications :**

* **Activate Solar Routing** est ON.
* Un surplus est bien disponible : `real_power` doit être négatif (export) au-delà de `target_grid_exchange`.
* `safety_limit` n'est pas actif (limiteur de température).
* Pour le moteur ON/OFF : niveau de démarrage / tempos correctement réglés — voir [Engine 1 × switch](engine_1switch.md).

### Le routeur oscille ON/OFF ou le niveau chasse

**Vérifications :**

* Diminuez `up_reactivity` / `down_reactivity` (moins agressif).
* Moteur ON/OFF : le niveau de démarrage doit être supérieur à la puissance de la charge ; ajustez les tempos.
* Engines multi-canaux / bypass : augmentez le Bypass Tempo pour réduire le scintillement des relais.
* Plusieurs routeurs : décalez cibles et réactivités — voir [Configuration avec plusieurs routeurs](firmware.md#configuration-avec-plusieurs-routeurs-solaires).

### La charge fonctionne en manuel mais pas en automatique

**Vérifications :**

* Préférez ajuster `router_level` plutôt que `regulator_opening` seul (les LED et le compteur d'énergie suivent `router_level`).
* Vérifiez que le package engine correspond aux régulateurs câblés (ex. : les relais mécaniques exigent des `relay_unique_id` fixes pour les engines multi-canaux).

### Le WiFi coupe ou l'ESP ne se reconnecte pas

Supprimez `ap:` et `captive_portal:` de la configuration ESPHome. Voir [Installation — Étape 1](installation.md#etape-1-installer-et-configurer-le-firmware-esphome).

### La sécurité température ne se libère pas / détournement bloqué à 0 %

**Vérifications :**

* Capteur joignable ? Si la source de température manque, `safety_limit` reste actif.
* Hystérésis : attendre que la température repasse sous (ou au-dessus) le seuil de relâchement.
* Validez soigneusement avant de laisser sans surveillance — voir [Limiteur de température](temperature_limiter.md).

### La base Home Assistant grossit rapidement

`real_power` et les capteurs d'énergie se mettent à jour chaque seconde. Excluez les entités haute fréquence du recorder — voir [Configuration du recorder](recorder_configuration.md).

### Les versions de modules semblent incohérentes

Des modules différents peuvent avoir des versions différentes ; c'est normal. Voir [Versions des modules](module_version.md).

## FAQ

**Faut-il Home Assistant pour réguler ?**  
Non pour les compteurs natifs (Fronius, Shelly, JSY, proxy). Oui si vous utilisez le [compteur Home Assistant](power_meter_home_assistant.md) ou le limiteur de température HA. HA reste utile pour les tableaux de bord et l'interrupteur Activate.

**Autonome ou proxy ?**  
Voir [Choisir une architecture](firmware.md#choisir-une-architecture).

**`real_power` positif ou négatif ?**  
Par convention, positif = import depuis le réseau, négatif = export. Utilisez `power_sign` pour inverser si votre compteur est inversé.

**Où obtenir de l'aide ?**  
Ouvrez une issue ou une discussion sur le [dépôt GitHub](https://github.com/hacf-fr/Solar-Router-for-ESPHome).

# Cas d'utilisation du blueprint — Priorité au VE

Table de vérité illustrant la logique d'arbitrage implémentée par
[`blueprints/priority_to_ev.yaml`](blueprint_priority_to_ev.md).

Conventions :

- `surplus = max(0, -grid_power) + max(0, diverted_power)` (en W).
- Valeurs par défaut : `EV_Charging_Minimum_Surplus = 1400 W`,
  `cloud_import_threshold = 200 W`,
  `release_export_threshold = 200 W`,
  `surplus_duration_trigger = 60 s`,
  `EV_SoC_Target = 80 %`.
- **Tous les triggers de niveau** (Handoff / Nuage / Release)
  utilisent des template triggers HA avec `for:` — ils se déclenchent
  quand la condition passe de faux à vrai et reste vraie pendant
  `surplus_duration_trigger` secondes.

| #  | Routeur avant | VE branché       | SoC   | grid_power (W)   | diverted (W) | Trigger déclenché              | Action        | Raison                                            |
|:---|:--------------|:-----------------|:------|-----------------:|-------------:|:-------------------------------|:--------------|:--------------------------------------------------|
| 1  | ON            | non              | —     | −2000            | 1800         | aucun — Handoff bloqué (pas de VE) | reste ON  | VE absent — le routeur garde le surplus           |
| 2  | ON            | oui              | 40 %  | −1800            | 200          | Handoff (surplus 2000 > 1400)  | **éteint**    | priorité au VE                                    |
| 3  | ON            | oui              | 40 %  | −500             | 100          | aucun — surplus 600 < 1400     | reste ON      | surplus insuffisant                               |
| 4  | OFF           | oui (en charge)  | 45 %  | ≈ 0              | 0            | aucun — grid stable dans ±200  | **reste OFF** | régime établi — bug v1 corrigé                    |
| 5  | OFF           | oui (en charge)  | 45 %  | **+400**         | 0            | Nuage (grid > 200 pendant 60 s)| **allume**    | nuage arrivé — retour au routeur                  |
| 6  | OFF           | oui (en charge)  | 45 %  | +100 bref        | 0            | aucun — sous le seuil nuage    | reste OFF     | fluctuation bénigne                               |
| 7  | OFF           | oui              | 80 %  | ≈ 0              | 0            | SoC atteint la cible           | **allume**    | voiture pleine (garde SoC)                        |
| 8  | OFF           | oui (SoC inconnu)| —     | **−1500**        | 0            | Release (−grid > 200 pendant 60 s)| **allume** | VE plein / pausé — export détecté                 |
| 9  | OFF           | débranché à l'instant | 60 % | −1500       | 0            | ev_unplugged (état)            | **allume**    | VE parti                                          |
| 10 | ON            | oui              | 100 % | −3000            | 2500         | aucun — SoC ≥ cible            | reste ON      | jamais de surplus vers un VE plein                |
| 11 | ON            | oui              | 40 %  | +100 (transitoire)| 500         | aucun — Handoff bloqué         | reste ON      | surplus 500 < 1400                                |
| 12 | OFF           | oui              | 40 %  | oscille ±100     | 0            | aucun — jamais stable hors de ±200 | reste OFF | l'anti-rebond absorbe le jitter                   |
| 13 | OFF (post-reboot)| oui           | 45 %  | ≈ 0              | 0            | `homeassistant.start` rejoue l'action ; aucune raison de restaurer | **no-op** | bug redémarrage v1 corrigé |
| 14 | quelconque    | oui              | any   | `unavailable`    | any          | aucun — `has_value` bloque     | reste tel quel| capteur tombé n'est pas un signal                 |
| 15 | ON            | oui (branchement à l'instant) | 40 % | −1600 (stable depuis des heures) | 400 | Handoff après 60 s | **éteint** | le branchement respecte l'anti-rebond — bug v1 corrigé |

## Notes

- **Ligne 4** est le test de non-régression : routeur OFF et VE en
  charge normale, `grid_power ≈ 0` et `diverted = 0`, la vérification
  naïve "surplus < seuil" se déclencherait (bug v1) et arracherait la
  priorité. Le signal côté réseau ne fait rien, correctement.
- **Ligne 5 vs 6** : tout import qui reste au-dessus de
  `cloud_import_threshold` pendant tout l'anti-rebond est traité
  comme un nuage. Les baisses brèves en dessous du seuil
  réinitialisent le timer.
- **Ligne 8** est la nouvelle capacité de la v2 : même sans capteur
  SoC, le blueprint détecte que le VE a cessé de tirer (le surplus
  part vers le réseau) et rallume le routeur.
- **Ligne 10** : `soc_below_target` est une condition obligatoire du
  Handoff, une voiture déjà pleine n'obtient jamais la priorité.
- **Ligne 13** : un redémarrage HA ré-exécute l'action une fois. La
  branche de restauration requiert une raison de restauration
  *effective maintenant* — un handoff stable (grid ≈ 0, en charge)
  n'est pas une raison, donc rien ne se passe.
- **Ligne 14** : chaque trigger de niveau commence par
  `has_value(...)`. Si `grid_power` ou `diverted_power` est
  `unavailable`, aucun des trois ne peut se déclencher. Seuls les
  triggers d'état (`ev_unplugged`) et le template SoC restent actifs.
- **Ligne 15** : brancher le VE alors que le surplus est déjà haut
  n'éteint pas le routeur *immédiatement*. Le template Handoff passe
  de faux (VE non branché) à vrai, et le timer `for:` attend 60 s
  avant de tirer.

## Entrée SoC laissée vide

Sans capteur SoC, les lignes 7 et 10 deviennent indétectables via la
garde SoC — mais la ligne 8 (trigger Release) prend le relais. Quand
le VE arrête de tirer tout seul, le surplus part au réseau ; dès que
l'export dépasse `release_export_threshold` pendant l'anti-rebond, le
routeur est restauré. Le blueprint fonctionne correctement sans
capteur SoC ; on perd uniquement la garde Handoff contre une voiture
déjà pleine (une voiture amenée déjà pleine aura brièvement la
priorité avant que le trigger Release ne se déclenche 60 s plus tard).

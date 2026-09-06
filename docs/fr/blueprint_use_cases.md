# Cas d'utilisation du blueprint — Priorité au VE

Table de vérité illustrant la logique de priorisation implémentée par
[`blueprints/priority_to_ev.yaml`](blueprint_priority_to_ev.md).

Conventions :

- **Surplus** = `max(0, −grid_power) + max(0, diverted_power)`, en W.
- Valeurs par défaut : `EV_Charging_Minimum_Surplus = 1400 W`,
  `surplus_duration_trigger = 60 s`, `EV_SoC_Target = 80 %`.
- « Stable ≥ N s ? » — le surplus est-il resté du même côté du seuil
  depuis au moins `surplus_duration_trigger` secondes ?
- Les déclencheurs `numeric_state` de HA utilisent des inégalités
  **strictes** (`above:` = `>`, `below:` = `<`). Au seuil exact, rien
  ne se déclenche.

| # | VE branché  | SoC   | Surplus (W)      | Routeur avant | Stable ≥ N s ? | Action        | Raison |
|:--|:------------|:------|:-----------------|:--------------|:---------------|:--------------|:-------|
| 1 | Non         | —     | +2000            | On            | —              | reste On      | VE absent — le routeur garde le surplus |
| 2 | Non         | —     | −500 (import)    | On            | —              | reste On      | fonctionnement normal, pas de surplus |
| 3 | Oui         | 40 %  | 500 (< 1400)     | On            | oui            | reste On      | surplus insuffisant pour le VE |
| 4 | Oui         | 40 %  | 2000 (> 1400)    | On            | **non** (30 s) | reste On      | anti-rebond en cours |
| 5 | Oui         | 40 %  | 2000 (> 1400)    | On            | oui            | **éteint**    | priorité au VE |
| 6 | Oui (charge) | 45 % | 200 (< 1400)    | Off           | oui            | **allume**    | nuage — retour routeur |
| 7 | Oui (charge) | 45 % | 200 (< 1400)    | Off           | **non** (10 s) | reste Off     | nuage bref — on temporise |
| 8 | Oui (charge) | 80 % | 3000            | Off           | —              | **allume**    | SoC cible atteint (relâche) |
| 9 | Oui         | 90 %  | 3000             | On            | —              | reste On      | SoC déjà ≥ cible — jamais de surplus vers VE plein |
| 10 | Débranché à l'instant | 60 % | 3000 | Off           | —              | **allume**    | VE parti — routeur reprend |
| 11 | Oui         | 40 %  | exactement 1400  | On            | oui            | reste On      | `above:` strict — pas de trigger |
| 12 | Oui (charge) | 40 % | exactement 1400 | Off           | oui            | reste Off     | `below:` strict — pas de retour |
| 13 | Oui         | 40 %  | oscille autour de 1400 | On      | jamais stable  | reste On      | l'anti-rebond bloque le flap |
| 14 | Oui         | 40 %  | 2000 déjà stable | Off (obsolète après reboot HA) | `homeassistant.started` déclenche | **éteint** | resynchronisation après redémarrage |

## Notes

- Ligne 3 vs 4/5 : seul l'anti-rebond (`surplus_duration_trigger`)
  change. Tout ce qui est plus court est traité comme du bruit.
- Lignes 6 et 8 : les deux rallument le routeur, mais pour des raisons
  différentes (nuage vs voiture pleine). L'action est identique
  (`switch.turn_on`).
- Ligne 9 : `ev_soc_target` est vérifié avant le seuil de surplus. Une
  fois la voiture pleine, aucun surplus ne lui redonnera la priorité.
- Lignes 11–12 : illustrent le coin des inégalités strictes. Ceux qui
  veulent une hystérésis explicite autour du seuil peuvent définir
  deux seuils ou laisser `surplus_duration_trigger` à une valeur
  raisonnable.
- Ligne 14 : `automation_reloaded` et `homeassistant.started`
  ré-exécutent l'action une fois, pour que l'état s'aligne sur la
  réalité après un reboot.

## Entrée SoC laissée vide

Si `ev_soc` n'est pas renseigné, les lignes 8 et 9 deviennent
indétectables côté Home Assistant : le VE devra s'arrêter tout seul
quand il est plein. Le routeur ne sera *pas* rallumé automatiquement
au moment où la voiture est pleine — il attendra soit un débranchement
soit une chute de surplus sous le seuil (ce qui arrivera naturellement
quand le VE cesse de tirer et que le surplus repasse au-dessus du
seuil).

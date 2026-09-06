# Blueprint Home Assistant — Priorité au VE

## 1 – À quoi ça sert

Lorsqu'un véhicule électrique est branché sur un chargeur intelligent
(MyEnergi Zappi, OpenEVSE, Wallbox Quasar, …) capable de suivre le
surplus solaire, on veut généralement que la **voiture** récupère ce
surplus plutôt que le chauffe-eau piloté par le Solar Router. Ce
blueprint arbitre entre les deux :

- Lorsqu'un surplus *suffisant* est disponible *assez longtemps*, il
  éteint le Solar Router pour que le surplus soit relâché vers le
  réseau, où le chargeur du VE le capte.
- Lorsque le VE est débranché, qu'un nuage se met à tirer du courant
  du réseau, ou que le VE cesse effectivement de prendre le surplus
  (voiture pleine, en pause, fin de tapering), il rallume le Solar
  Router pour que le chauffe-eau récupère ce qui reste.

Le firmware du routeur ne communique **pas** avec le chargeur — le
blueprint se contente de manipuler l'interrupteur `Activate Solar
Routing`. Tout le reste reste à la charge du chargeur.

## 2 – Signaux

### 2a – Bascule (routeur ON → OFF)

```
surplus = max(0, -grid_power) + max(0, diverted_power)
```

- `grid_power` est signé : **positif à l'import**, **négatif à
  l'export**. C'est la convention par défaut du firmware Solar Router
  (`power_sign: "1"`).
- `diverted_power` est le capteur `Power divertion` du routeur —
  toujours positif, nul quand le routeur est éteint.

Le routeur passe en OFF quand `surplus > EV_Charging_Minimum_Surplus`
reste vrai en continu pendant `surplus_duration_trigger` secondes, à
condition que le VE soit branché et (si un capteur SoC est fourni)
encore sous la cible.

### 2b – Restauration (routeur OFF → ON)

Une fois le routeur éteint et le VE en charge sur le solaire, la
formule de surplus s'effondre à ~0 : `diverted_power = 0` (routeur
off) et `grid_power ≈ 0` (le VE mange ce que produit le PV). Le
blueprint ne saurait plus distinguer un nuage d'une charge ordinaire.
Il regarde donc `grid_power` directement :

- **`grid_power > cloud_import_threshold` pendant N s** → on importe →
  le PV ne suffit plus au VE → **nuage arrivé**.
- **`-grid_power > release_export_threshold` pendant N s** → on
  exporte → le VE ne prend pas le surplus → **VE plein, en pause ou
  bridé**.

Plus un signal immédiat sans anti-rebond :

- VE débranché (`ev_connected` → `off`)

La cible de SoC n'est délibérément **pas** un signal de restauration
immédiat. La plupart des voitures continuent à charger au-delà d'une
cible fixée par l'utilisateur en réduisant progressivement la
puissance, et rallumer le routeur à cet instant reviendrait à se
disputer avec le VE cette énergie de fin de charge. Le blueprint
attend `-grid_power > release_export_threshold` — c'est-à-dire que la
voiture a réellement cessé de consommer — pour restaurer le routeur.
La cible SoC continue de verrouiller les nouvelles bascules
(voir [3 – Comportement](#3--comportement)).

## 3 – Comportement

```text
BASCULE (routeur ON → OFF), quand ceci reste vrai pendant surplus_duration_trigger s :
  ev_connected == on
  ET solar_router == on
  ET ( ev_soc_entity est vide OU ev_soc < ev_soc_target )
  ET surplus > EV_Charging_Minimum_Surplus

RESTAURATION (routeur OFF → ON), sur l'un des cas suivants :
  ev_connected passe à off                                              [immédiat]
  grid_power > cloud_import_threshold      pendant surplus_duration_trigger s   [nuage]
  -grid_power > release_export_threshold   pendant surplus_duration_trigger s   [VE plein]
```

Les deux triggers de niveau utilisent des template triggers HA avec
`for:`, donc une pointe brève d'un côté ou l'autre est absorbée et ne
fait pas bouger le routeur. Franchir `ev_soc_target` gèle la bascule
(plus de nouveau routeur-OFF) mais ne rallume pas le routeur — le
seuil d'export s'en charge une fois que la voiture cesse réellement de
consommer.

## 4 – Entrées

| Entrée | Rôle | Défaut |
| --- | --- | ---: |
| `ev_connected` | Capteur binaire, ON quand le VE est branché | obligatoire |
| `ev_soc` | *(optionnel)* capteur d'état de charge, en % | vide |
| `ev_soc_target` | Au-delà de ce SoC : plus de nouvelle bascule — la restauration attend l'export réel | **80** |
| `grid_power` | Puissance réseau signée en W (+ import, − export) | obligatoire |
| `diverted_power` | Capteur `Power divertion` du Solar Router | obligatoire |
| `solar_router` | Interrupteur `Activate Solar Routing` à piloter | obligatoire |
| `ev_charging_minimum_surplus` | Seuil de surplus pour la bascule, en W | 1400 |
| `cloud_import_threshold` | Seuil d'import pour la détection nuage, en W | 200 |
| `release_export_threshold` | Seuil d'export pour la détection "VE plein", en W | 200 |
| `surplus_duration_trigger` | Anti-rebond appliqué aux 3 triggers de niveau, en s | 60 |

## 5 – Prérequis firmware : `Real Power` vivant même routeur éteint

Avant cette version, éteindre `Activate Solar Routing` stoppait aussi
le sondage du compteur et forçait `Real Power` à `NaN`. Le blueprint
devenait aveugle au moment où il en a le plus besoin — avec les
signaux de l'option 3, cela empêcherait autant la détection du nuage
que celle du VE plein. Le firmware livré avec ce blueprint conserve
le sondage des compteurs natifs en continu et n'écrit plus `NaN` à
l'arrêt. Aucune action n'est requise côté utilisateur si le firmware
assorti est flashé.

## 6 – Une journée dans la vie

Seuil de bascule 1400 W, seuils nuage & release 200 W chacun,
anti-rebond 60 s.

| Heure | Situation | grid_power | diverted | Routeur | Action |
| :--- | :--- | ---: | ---: | :--- | :--- |
| 06:00 | Fin de nuit, pas de PV | +300 (import) | 0 | ON idle | — |
| 09:00 | PV monte, VE branché, SoC 40 % | −1600 | 200 | ON diverting | — (anti-rebond) |
| 09:01 | Trigger Handoff stable > 60 s | −1650 | 200 | **OFF** | priorité au VE |
| 09:02 | VE charge, PV équilibré | ≈ 0 | 0 | OFF | — (grid stable) |
| 10:30 | Gros nuage, VE continue à tirer du réseau | **+800** | 0 | **ON** | nuage détecté — retour au routeur |
| 11:00 | Soleil de retour, surplus > 1400 pendant 60 s | −2500 | (monte) | **OFF** | VE à nouveau |
| 15:00 | SoC atteint la cible (80 %), voiture continue en tapering | ≈ 0 | 0 | OFF | — (bascule gelée, mais le VE consomme encore) |
| 15:30 | VE s'arrête réellement, export stable > 60 s | **−1500** | 0 | **ON** | export release — retour au routeur |
| 20:00 | VE débranché | −200 | 100 | ON | — |

## 7 – Détection de VE branché (exemple MyEnergi Zappi)

Si votre chargeur n'expose qu'un statut texte, encapsulez-le dans un
capteur binaire template :

```yaml
template:
  - binary_sensor:
      - name: EV plugged in
        device_class: plug
        state: >-
          {{ states('sensor.myenergi_zappi_plug_status')
             in ['EV Connected', 'Waiting for EV', 'Charging', 'Boosting', 'Complete'] }}
```

## 8 – Installation

Importer le blueprint dans Home Assistant :

- Paramètres → Automatisations & Scènes → Blueprints → *Importer un
  blueprint*
- Coller l'URL brute de `blueprints/priority_to_ev.yaml` dans ce dépôt.

Créer ensuite une automatisation depuis le blueprint importé et
remplir les entrées.

## 9 – Cas limites

- **Nuage bref (< `surplus_duration_trigger` s)** — le routeur reste
  éteint ; l'anti-rebond absorbe.
- **Redémarrage HA en pleine charge** — l'automation se réévalue sur
  `homeassistant.start`, mais la branche de restauration n'agit que
  si une vraie raison tient (débranchement / nuage / VE plein). Un
  redémarrage en pleine priorité VE stable est un no-op.
- **Capteur `unavailable`** — chaque trigger de niveau vérifie
  `has_value()` ; si `grid_power` ou `diverted_power` tombe, aucune
  restauration n'est déclenchée.
- **L'utilisateur rallume manuellement le routeur** alors que le VE
  est branché et le surplus élevé — le prochain cycle Handoff (60 s)
  le rééteindra. Pour désactiver temporairement, désactiver
  l'automation dans HA.
- **Chargeur avec une marge d'export** (certains laissent 100 W
  partir au réseau même à pleine charge) — remonter
  `release_export_threshold` au-dessus de cette marge (200–300 W).
- **Pointes de conso maison** (lave-vaisselle qui démarre) — un gros
  appareil pousse `grid_power` brièvement au positif ; les 60 s
  d'anti-rebond absorbent un cycle normal, mais une charge lourde
  soutenue *déclenchera* la branche nuage. Remonter
  `cloud_import_threshold` si c'est un souci récurrent.

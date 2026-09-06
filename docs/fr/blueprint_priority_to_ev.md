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
- Lorsque la voiture est pleine, débranchée, ou qu'un passage nuageux
  fait retomber le surplus sous le seuil, il rallume le Solar Router
  pour que le chauffe-eau récupère ce qui reste.

Le firmware du routeur ne communique **pas** avec le chargeur — le
blueprint se contente de manipuler l'interrupteur `Activate Solar
Routing`. Tout le reste reste à la charge du chargeur.

## 2 – Définition du surplus

```
surplus = max(0, -grid_power) + max(0, diverted_power)
```

- `grid_power` est signé : **positif à l'import**, **négatif à
  l'export**. C'est la convention par défaut du firmware Solar Router
  (`power_sign: "1"`).
- `diverted_power` est le capteur `Power divertion` du routeur —
  toujours positif, nul quand le routeur est éteint.

Les `max(0, …)` évitent qu'un import (positif) ou une lecture de
détournement transitoirement négative ne tirent artificiellement le
surplus vers le bas.

## 3 – Comportement

```text
SI ev_connected ET ev_soc < ev_soc_target
   ET surplus > EV_Charging_Minimum_Surplus  pendant > surplus_duration_trigger
   ET solar_router est ON
ALORS éteindre solar_router   (priorité au VE)

SI solar_router est OFF
   ET ( ev_non_branché
        OU ev_soc >= ev_soc_target
        OU surplus < EV_Charging_Minimum_Surplus  pendant > surplus_duration_trigger )
ALORS allumer solar_router    (retour au routage normal)
```

- Les inégalités `above:` et `below:` du déclencheur `numeric_state`
  sont **strictes** — au seuil exact, rien ne se déclenche. C'est ce
  qui empêche l'automation de vibrer sur un surplus marginal.
- La clause `for:` filtre les rebonds dans les deux sens.
- Si `ev_soc` est laissé vide, le garde-fou SoC est ignoré : c'est
  alors au VE de s'arrêter quand il est plein.

## 4 – Entrées

| Entrée | Rôle |
| --- | --- |
| `ev_connected` | Capteur binaire, ON quand le VE est branché |
| `ev_soc` | *(optionnel)* capteur d'état de charge, en % |
| `ev_soc_target` | SoC cible en % (défaut **80**) |
| `grid_power` | Puissance réseau signée en W (+ import, − export) |
| `diverted_power` | Capteur `Power divertion` du Solar Router |
| `solar_router` | Interrupteur `Activate Solar Routing` à piloter |
| `ev_charging_minimum_surplus` | Seuil en W (défaut 1400) |
| `surplus_duration_trigger` | Anti-rebond en s (défaut 60) |

## 5 – Prérequis firmware : `Real Power` vivant même routeur éteint

Avant cette version, éteindre `Activate Solar Routing` stoppait aussi
le sondage du compteur et forçait `Real Power` à `NaN` — le blueprint
devenait alors aveugle au moment où il en a le plus besoin. Le
firmware livré avec ce blueprint conserve le sondage des compteurs
natifs en continu et n'écrit plus `NaN` à l'arrêt, de sorte que la
détection de nuage fonctionne routeur allumé comme éteint. Aucune
action n'est requise côté utilisateur si le firmware assorti est
flashé.

## 6 – Une journée dans la vie

| Heure | Situation | Surplus | Routeur | Action |
| :--- | :--- | ---: | :--- | :--- |
| 06:00 | Fin de nuit, pas de PV | −300 W | ON idle | — |
| 09:00 | PV monte, VE branché, SoC 40 % | +1600 W | ON diverting | — (anti-rebond en cours) |
| 09:01 | Surplus stable > 1400 W pendant 60 s | +1650 W | **OFF** | priorité au VE |
| 09:02 | VE charge, surplus faible | +200 W | OFF | — (sous anti-rebond) |
| 10:30 | Gros nuage, surplus < 1400 pendant 60 s | +100 W | **ON** | nuage — retour au routeur |
| 11:00 | Soleil de retour, surplus > 1400 pendant 60 s | +2500 W | **OFF** | VE à nouveau |
| 15:00 | SoC atteint la cible (80 %) | +2200 W | **ON** | voiture pleine — relâche |
| 20:00 | VE débranché | −200 W | ON | — |

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
remplir les six entrées obligatoires.

## 9 – Cas limites

- **Nuage bref (< `surplus_duration_trigger` s)** — le routeur reste
  éteint ; l'anti-rebond absorbe.
- **Redémarrage HA en pleine charge** — l'automation se réévalue sur
  `homeassistant.started` et converge vers le bon état au prochain
  tick de surplus.
- **L'utilisateur éteint manuellement le routeur** alors qu'aucun VE
  n'est branché — le blueprint ne se bat pas ; il ne rallumera que si
  une de ses propres conditions le demande.
- **Surplus pile au seuil** — ni `above:` ni `below:` ne se déclenchent
  (inégalité stricte). Aucune action.

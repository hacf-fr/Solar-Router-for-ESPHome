#!/usr/bin/env python3
"""
Génère une illustration d'une journée type pour le blueprint Priority to EV.
Montre production PV, talon maison, VE, chauffe-eau (diverted), et échange réseau,
avec fonds colorés pour indiquer l'état du routeur.

Produit deux fichiers : docs/images/priority_to_ev_day_fr.png et _en.png.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Patch

# ============================================================
# Localisation - all user-facing strings live here.
# ============================================================
LABELS = {
    'fr': {
        'title':      'Priorité VE sur routeur solaire — une journée type',
        'subtitle':   'Bascule : surplus > {ev_min:.0f} W pendant 60 s   •   '
                      'Restauration : import > {cloud:.0f} W (nuage) OU '
                      'export > {release:.0f} W (VE plein) OU SoC ≥ cible OU VE débranché',
        'y_power':    'Puissance (W)',
        'y_grid':     'Réseau (W)\n− export  /  + import',
        'x_time':     'Heure de la journée',
        'xtick_fmt':  '{h:02d}h',
        'pv':         'Production PV',
        'conso':      'Consommation totale',
        'talon':      '  Talon (base maison)',
        'heater':     '  Chauffe-eau (routeur, max {r_max:.0f} W)',
        'ev':         '  VE (charge)',
        'router_off': 'Routeur OFF (priorité VE)',
        'grid_line':  'Grid (signé)',
        'surplus':    'Surplus',
        'import':     'Import (grid > 0)',
        'export':     'Export (grid < 0)',
        'th_cloud':   '+{v:.0f} W (seuil nuage)',
        'th_release': '−{v:.0f} W (seuil release)',
        'th_handoff': '−{v:.0f} W (seuil bascule — export)',
        'events': [
            '07:40  Le surplus commence à être rerouté',
            '08:52  Bascule → routeur OFF (surplus > {ev_min:.0f} W stable 60 s)',
            '11:30  Nuage → VE en pause → export → Release → routeur ON',
            '12:00  Soleil revient → Bascule → routeur OFF',
            '14:07  SoC {soc_target:.0f} % atteint → routeur ON (chauffe-eau reprend)',
            '16:30  Le chauffe-eau a atteint sa température max',
        ],
        'out_name':   'priority_to_ev_day_fr.png',
    },
    'en': {
        'title':      'EV priority over solar router — a typical day',
        'subtitle':   'Handoff: surplus > {ev_min:.0f} W for 60 s   •   '
                      'Restore: import > {cloud:.0f} W (cloud) OR '
                      'export > {release:.0f} W (EV done) OR SoC ≥ target OR EV unplugged',
        'y_power':    'Power (W)',
        'y_grid':     'Grid (W)\n− export  /  + import',
        'x_time':     'Time of day',
        'xtick_fmt':  '{h:02d}:00',
        'pv':         'PV production',
        'conso':      'Total consumption',
        'talon':      '  Baseline (household)',
        'heater':     '  Water heater (router, max {r_max:.0f} W)',
        'ev':         '  EV (charging)',
        'router_off': 'Router OFF (EV priority)',
        'grid_line':  'Grid (signed)',
        'surplus':    'Surplus',
        'import':     'Import (grid > 0)',
        'export':     'Export (grid < 0)',
        'th_cloud':   '+{v:.0f} W (cloud threshold)',
        'th_release': '−{v:.0f} W (release threshold)',
        'th_handoff': '−{v:.0f} W (handoff threshold — export)',
        'events': [
            '07:40  Surplus starts being diverted',
            '08:52  Handoff → router OFF (surplus > {ev_min:.0f} W stable 60 s)',
            '11:30  Cloud → EV pauses → export → Release → router ON',
            '12:00  Sun back → Handoff → router OFF',
            '14:07  SoC {soc_target:.0f} % reached → router ON (water heater resumes)',
            '16:30  Water heater reached its max temperature',
        ],
        'out_name':   'priority_to_ev_day_en.png',
    },
}

# ============================================================
# Timeline data - one point per minute for a full day
# ============================================================
minutes = np.arange(0, 1440)
hours = minutes / 60.0

# --- Production PV: sin² curve, sunrise 06:00, sunset 20:00, peak ~4.5 kW around 13:00, with a mid-day cloud
def pv_curve(h):
    # sin²((h-6)*pi/14) rises quickly from sunrise, peaks at 13, back to 0 at 20
    p = np.where(
        (h >= 6.0) & (h <= 20.0),
        4500.0 * np.sin(np.clip((h - 6.0) * np.pi / 14.0, 0, np.pi)) ** 2,
        0.0,
    )
    # Cloud between 11:30 and 12:00 - dip to ~700W
    cloud = (h >= 11.5) & (h < 12.0)
    p = np.where(cloud, np.minimum(p, 700.0), p)
    return p

# --- Talon: VMC (constant) + fridge crenels + morning / lunch / evening peaks
def talon_curve(h):
    vmc = 60.0
    cycle_h = 40.0 / 60.0        # 40-minute fridge cycle
    duty = 15.0 / 40.0           # ON 15 min, OFF 25 min
    phase = (h / cycle_h) % 1.0
    fridge = np.where(phase < duty, 120.0, 0.0)
    morning = 700 * np.exp(-((h - 7.0) / 1.1) ** 2)
    lunch = 350 * np.exp(-((h - 12.5) / 0.8) ** 2)
    evening = 1100 * np.exp(-((h - 19.0) / 1.4) ** 2)
    return vmc + fridge + morning + lunch + evening

pv = pv_curve(hours)
talon = talon_curve(hours)

# ============================================================
# Physical simulation of the blueprint state machine at 1-minute resolution
# ============================================================
# Zappi eco+ behavior: EV pauses when (pv - talon) < 1400 W; otherwise draws min(3300, pv - talon).
# Water heater / router: diverts when surplus available and router ON, capped at 3000 W.

EV_MIN = 1400.0        # minimum surplus for Zappi to start / keep charging (eco+)
EV_MAX = float('inf')  # EV absorbs 100 % of the surplus (no ceiling in this model)
ROUTER_MAX = 1000.0    # water-heater capacity (limited)
TANK_FULL_H = 16.5     # water heater thermostat cuts off at 16:30 (tank hot enough)
HANDOFF_TH = EV_MIN
CLOUD_TH = 200.0
RELEASE_TH = 200.0
DEBOUNCE = 1           # iterations at 1-min resolution → ~1 min (~60 s)

# EV plug window
EV_PLUGGED_FROM = 8.5   # 08:30
EV_PLUGGED_UNTIL = 20.0 # 20:00

# SoC model: 40% at start, target 80%, ~1% per (kWh * 100/battery_kWh) - approximate for the story
SOC_START = 40.0
SOC_TARGET = 80.0
BATTERY_KWH = 40.0     # small EV (Zoe)

router_on = np.ones(len(hours), dtype=bool)
ev = np.zeros(len(hours))
divert = np.zeros(len(hours))
soc = np.full(len(hours), SOC_START)

# state machine
in_priority = False
handoff_timer = cloud_timer = release_timer = 0
current_soc = SOC_START

for i in range(len(hours)):
    h = hours[i]
    ev_plugged = (h >= EV_PLUGGED_FROM) and (h < EV_PLUGGED_UNTIL)

    # Compute EV power (depends on priority window)
    if in_priority and ev_plugged and current_soc < SOC_TARGET:
        avail = pv[i] - talon[i]
        ev[i] = min(EV_MAX, avail) if avail >= EV_MIN else 0.0
    else:
        ev[i] = 0.0

    # Compute router diversion (router is ON when NOT in EV priority)
    if in_priority:
        divert[i] = 0.0
    else:
        if hours[i] < TANK_FULL_H:
            avail = pv[i] - talon[i] - ev[i]
            divert[i] = max(0.0, min(ROUTER_MAX, avail))
        else:
            divert[i] = 0.0

    # Grid exchange (positive = import)
    grid_i = talon[i] + ev[i] + divert[i] - pv[i]

    # Update SoC
    if ev[i] > 0:
        current_soc += (ev[i] / 1000.0) / 60.0 / BATTERY_KWH * 100.0
    soc[i] = current_soc

    # State-machine transitions
    if not in_priority:
        # We're in "router ON" state; check Handoff
        surplus = max(0.0, -grid_i) + max(0.0, divert[i])
        handoff_cond = (ev_plugged and current_soc < SOC_TARGET and surplus > HANDOFF_TH)
        handoff_timer = handoff_timer + 1 if handoff_cond else 0
        if handoff_timer >= DEBOUNCE:
            in_priority = True
            handoff_timer = 0
    else:
        # We're in "router OFF" state; check Restore
        # Immediate: unplug only. SoC target no longer restores by itself —
        # the release trigger picks up the actual export when the EV stops.
        if not ev_plugged:
            in_priority = False
            cloud_timer = release_timer = 0
        else:
            cloud_cond = grid_i > CLOUD_TH
            release_cond = -grid_i > RELEASE_TH
            cloud_timer = cloud_timer + 1 if cloud_cond else 0
            release_timer = release_timer + 1 if release_cond else 0
            if cloud_timer >= DEBOUNCE or release_timer >= DEBOUNCE:
                in_priority = False
                cloud_timer = release_timer = 0

    router_on[i] = not in_priority

# --- Grid exchange (signed: + = import, - = export) ---
grid = talon + ev + divert - pv

# Detect state-machine transitions to auto-place event markers
transitions = []
for i in range(1, len(hours)):
    if router_on[i] != router_on[i-1]:
        transitions.append((hours[i], 'OFF' if not router_on[i] else 'ON'))
print("Router transitions:")
for t, s in transitions:
    print(f"  {int(t)}:{int((t%1)*60):02d} → router {s}")

# SoC-target time
soc_hit_i = np.argmax(soc >= SOC_TARGET) if np.any(soc >= SOC_TARGET) else None
if soc_hit_i:
    print(f"SoC target crossed at {int(hours[soc_hit_i])}:{int((hours[soc_hit_i]%1)*60):02d}, final SoC = {soc[-1]:.1f}%")

# ============================================================
# Plot (called once per language)
# ============================================================
plt.rcParams.update({
    'font.family': 'DejaVu Sans',
    'font.size': 10,
    'axes.spines.top': False,
    'axes.spines.right': False,
})


def render(lang: str) -> str:
    L = LABELS[lang]

    # Palette - accessible, distinct in CVD
    COLOR_PV = '#e8a838'         # amber (sun)
    COLOR_TALON = '#6b7280'      # neutral gray
    COLOR_EV = '#3b7ea1'         # calm blue
    COLOR_DIVERT = '#c1436d'     # coral (water heater)
    COLOR_IMPORT = '#b23a48'     # red
    COLOR_EXPORT = '#4d7c3a'     # green
    COLOR_SURPLUS = '#557799'    # blue-gray
    COLOR_CONSO = '#1e6fd9'      # distinct strong blue
    BG_ROUTER_OFF = '#f3f3f3'    # very pale amber
    INK = '#1f2937'
    MUTED = '#9ca3af'

    fig, (axE, ax1, ax2) = plt.subplots(
        3, 1, figsize=(15, 10.5), sharex=True,
        gridspec_kw={'height_ratios': [0.5, 2, 1], 'hspace': 0.10}
    )
    fig.patch.set_facecolor('white')

    # --- Background shading for router state ---
    in_off = False
    off_start = 0
    off_ranges = []
    for i, on in enumerate(router_on):
        if not on and not in_off:
            in_off = True
            off_start = hours[i]
        elif on and in_off:
            in_off = False
            off_ranges.append((off_start, hours[i]))
    if in_off:
        off_ranges.append((off_start, hours[-1]))

    for ax in (axE, ax1, ax2):
        for s, e in off_ranges:
            ax.axvspan(s, e, color=BG_ROUTER_OFF, alpha=0.9, zorder=0)

    # --- Top panel: production vs total consumption breakdown ---
    consommation_totale = talon + divert + ev
    ax1.stackplot(hours, talon, divert, ev,
                  colors=[COLOR_TALON, COLOR_DIVERT, COLOR_EV],
                  alpha=0.55, zorder=2)
    ax1.fill_between(hours, 0, pv, color=COLOR_PV, alpha=0.18, zorder=1)
    ax1.plot(hours, pv, color=COLOR_PV, lw=2.5, zorder=6, label=L['pv'])
    ax1.plot(hours, consommation_totale, color=COLOR_CONSO, lw=2.6, zorder=10,
             label=L['conso'], solid_capstyle='round')

    ax1.set_ylabel(L['y_power'], color=INK)
    ax1.set_ylim(0, 5200)
    ax1.grid(True, axis='y', alpha=0.25, color=MUTED, linestyle='-', linewidth=0.5)
    ax1.set_axisbelow(True)

    handles = [
        plt.Line2D([], [], color=COLOR_PV, lw=2.5, label=L['pv']),
        plt.Line2D([], [], color=COLOR_CONSO, lw=2.6, label=L['conso']),
        Patch(facecolor=COLOR_TALON, alpha=0.55, label=L['talon']),
        Patch(facecolor=COLOR_DIVERT, alpha=0.55, label=L['heater'].format(r_max=ROUTER_MAX)),
        Patch(facecolor=COLOR_EV, alpha=0.55, label=L['ev']),
        Patch(facecolor=BG_ROUTER_OFF, edgecolor='none', label=L['router_off']),
    ]
    ax1.legend(handles=handles, loc='upper left', frameon=False, ncol=2, fontsize=9)

    # --- Bottom panel: grid exchange (signed) + surplus curve ---
    surplus_bp = np.maximum(0.0, -grid) + np.maximum(0.0, divert)

    ax2.axhline(0, color=MUTED, lw=1.0, alpha=0.7)
    ax2.fill_between(hours, 0, grid, where=(grid >= 0), color=COLOR_IMPORT, alpha=0.30, interpolate=True)
    ax2.fill_between(hours, 0, grid, where=(grid < 0), color=COLOR_EXPORT, alpha=0.30, interpolate=True)
    ax2.plot(hours, grid, color=INK, lw=1.5, zorder=3, label=L['grid_line'])
    # Surplus (dashed, no fill) on the export side of the axis
    ax2.plot(hours, -surplus_bp, color=COLOR_SURPLUS, lw=1.6, ls='--', zorder=4, label=L['surplus'])

    # Threshold reference lines
    ax2.axhline(CLOUD_TH, ls='--', color=COLOR_IMPORT, alpha=0.6, lw=1)
    ax2.axhline(-RELEASE_TH, ls='--', color=COLOR_EXPORT, alpha=0.6, lw=1)
    ax2.text(23.8, CLOUD_TH + 120, L['th_cloud'].format(v=CLOUD_TH),
             fontsize=8, ha='right', color=COLOR_IMPORT, alpha=0.95, weight='bold')
    ax2.text(23.8, -RELEASE_TH - 220, L['th_release'].format(v=RELEASE_TH),
             fontsize=8, ha='right', color=COLOR_EXPORT, alpha=0.95, weight='bold')

    ax2.axhline(-HANDOFF_TH, ls=':', color=INK, alpha=0.5, lw=1)
    ax2.text(23.8, -HANDOFF_TH - 220, L['th_handoff'].format(v=HANDOFF_TH),
             fontsize=8, ha='right', color=INK, alpha=0.75)

    ax2.set_ylabel(L['y_grid'], color=INK)
    ax2.set_ylim(-4200, 2200)
    ax2.set_xlabel(L['x_time'], color=INK)
    ax2.grid(True, axis='y', alpha=0.25, color=MUTED, linestyle='-', linewidth=0.5)
    ax2.set_axisbelow(True)

    handles2 = [
        plt.Line2D([], [], color=INK, lw=1.5, label=L['grid_line']),
        plt.Line2D([], [], color=COLOR_SURPLUS, lw=1.6, ls='--', label=L['surplus']),
        Patch(facecolor=COLOR_IMPORT, alpha=0.30, label=L['import']),
        Patch(facecolor=COLOR_EXPORT, alpha=0.30, label=L['export']),
    ]
    ax2.legend(handles=handles2, loc='lower left', frameon=False, fontsize=9, ncol=2)

    ax2.set_xticks(range(0, 25, 2))
    ax2.set_xticklabels([L['xtick_fmt'].format(h=h) for h in range(0, 25, 2)])
    ax2.set_xlim(0, 24)

    # --- Event markers ---
    ev_times = [7.6, 8 + 52/60, 11.5, 12.0, 14 + 7/60, 16.5]
    ev_labels = [
        L['events'][0],
        L['events'][1].format(ev_min=EV_MIN),
        L['events'][2],
        L['events'][3],
        L['events'][4].format(soc_target=SOC_TARGET),
        L['events'][5],
    ]
    events = list(zip(ev_times, [str(i+1) for i in range(6)], ev_labels))

    for h, _, _ in events:
        ax1.axvline(h, color=INK, ls=':', lw=0.9, alpha=0.55, zorder=1)
        ax2.axvline(h, color=INK, ls=':', lw=0.9, alpha=0.55, zorder=1)

    axE.set_ylim(0, 1)
    axE.set_yticks([])
    axE.tick_params(axis='x', labelbottom=False, bottom=False)
    for spine in ('top', 'right', 'left', 'bottom'):
        axE.spines[spine].set_visible(False)

    row_y = [0.75, 0.25, 0.75, 0.25, 0.75, 0.25]
    for (h, num, _), y in zip(events, row_y):
        axE.plot([h], [y], 'o', color=INK, markersize=20, zorder=5)
        axE.text(h, y, num, fontsize=10, ha='center', va='center',
                 color='white', weight='bold', zorder=6)
        axE.axvline(h, color=INK, ls=':', lw=0.9, alpha=0.55, zorder=1)

    # --- Title + subtitle ---
    fig.suptitle(L['title'], fontsize=15, weight='bold', y=0.995)
    fig.text(0.5, 0.955,
             L['subtitle'].format(ev_min=EV_MIN, cloud=CLOUD_TH, release=RELEASE_TH),
             fontsize=9.5, ha='center', color=MUTED, style='italic')

    # --- Event legend (numbered) below the figure ---
    CIRCLED = ['❶', '❷', '❸', '❹', '❺', '❻', '❼']
    lines = [
        '     '.join(f'{CIRCLED[i]} {events[i][2]}' for i in (0, 1, 2)),
        '     '.join(f'{CIRCLED[i]} {events[i][2]}' for i in (3, 4, 5)),
    ]
    fig.text(0.5, 0.045, lines[0], fontsize=9, ha='center', color=INK)
    fig.text(0.5, 0.020, lines[1], fontsize=9, ha='center', color=INK)

    plt.tight_layout(rect=[0, 0.06, 1, 0.94])

    out_path = f'/workspace/Solar-Router-for-ESPHome/docs/images/{L["out_name"]}'
    plt.savefig(out_path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    print(f"Wrote: {out_path}")
    return out_path


for lang in ('fr', 'en'):
    render(lang)

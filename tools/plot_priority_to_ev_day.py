#!/usr/bin/env python3
"""
Génère une illustration d'une journée type pour le blueprint Priority to EV.
Montre production PV, talon maison, VE, chauffe-eau (diverted), et échange réseau,
avec fonds colorés pour indiquer l'état du routeur.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Patch

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
HANDOFF_TH = 1400.0
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
        # Immediate: unplug, SoC target
        if not ev_plugged or current_soc >= SOC_TARGET:
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
    print(f"SoC target reached at {int(hours[soc_hit_i])}:{int((hours[soc_hit_i]%1)*60):02d}, final SoC = {soc[-1]:.1f}%")

# ============================================================
# Plot
# ============================================================
plt.rcParams.update({
    'font.family': 'DejaVu Sans',
    'font.size': 10,
    'axes.spines.top': False,
    'axes.spines.right': False,
})

# Palette - accessible, distinct in CVD
COLOR_PV = '#e8a838'         # amber (sun)
COLOR_TALON = '#6b7280'      # neutral gray
COLOR_EV = '#3b7ea1'         # calm blue
COLOR_DIVERT = '#c1436d'     # coral (water heater)
COLOR_IMPORT = '#b23a48'     # red
COLOR_EXPORT = '#4d7c3a'     # green
BG_ROUTER_OFF = '#f3f3f3'    # very pale amber
INK = '#1f2937'
MUTED = '#9ca3af'

fig, (axE, ax1, ax2) = plt.subplots(
    3, 1, figsize=(15, 10.5), sharex=True,
    gridspec_kw={'height_ratios': [0.5, 2, 1], 'hspace': 0.10}
)
fig.patch.set_facecolor('white')

# --- Background shading for router state ---
# Find contiguous OFF windows
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
# Stacked areas: talon (bottom), chauffe-eau, VE - sum = total consumption
consommation_totale = talon + divert + ev
ax1.stackplot(hours, talon, divert, ev,
              colors=[COLOR_TALON, COLOR_DIVERT, COLOR_EV],
              alpha=0.55, zorder=2)
# Production line + fill on top
ax1.fill_between(hours, 0, pv, color=COLOR_PV, alpha=0.18, zorder=1)
ax1.plot(hours, pv, color=COLOR_PV, lw=2.5, zorder=6, label='Production PV')
# Total consumption line in blue, overlaid on top of everything
COLOR_CONSO = '#1e6fd9'  # distinct strong blue
ax1.plot(hours, consommation_totale, color=COLOR_CONSO, lw=2.6, zorder=10,
         label='Consommation totale', solid_capstyle='round')

ax1.set_ylabel('Puissance (W)', color=INK)
ax1.set_ylim(0, 5200)
ax1.grid(True, axis='y', alpha=0.25, color=MUTED, linestyle='-', linewidth=0.5)
ax1.set_axisbelow(True)

# Legend
handles = [
    plt.Line2D([], [], color=COLOR_PV, lw=2.5, label='Production PV'),
    plt.Line2D([], [], color=COLOR_CONSO, lw=2.6, label='Consommation totale'),
    Patch(facecolor=COLOR_TALON, alpha=0.55, label='  Talon (base maison)'),
    Patch(facecolor=COLOR_DIVERT, alpha=0.55, label=f'  Chauffe-eau (routeur, max {ROUTER_MAX} W)'),
    Patch(facecolor=COLOR_EV, alpha=0.55, label='  VE (charge)'),
    Patch(facecolor=BG_ROUTER_OFF, edgecolor='none', label='Routeur OFF (priorité VE)'),
]
ax1.legend(handles=handles, loc='upper left', frameon=False, ncol=2, fontsize=9)

# --- Bottom panel: grid exchange (signed) ---
ax2.axhline(0, color=MUTED, lw=1.0, alpha=0.7)
ax2.fill_between(hours, 0, grid, where=(grid >= 0), color=COLOR_IMPORT, alpha=0.30, interpolate=True)
ax2.fill_between(hours, 0, grid, where=(grid < 0), color=COLOR_EXPORT, alpha=0.30, interpolate=True)
ax2.plot(hours, grid, color=INK, lw=1.5, zorder=3)

# Restoration thresholds
ax2.axhline(200, ls='--', color=COLOR_IMPORT, alpha=0.6, lw=1)
ax2.axhline(-200, ls='--', color=COLOR_EXPORT, alpha=0.6, lw=1)
ax2.text(23.8, 320, '+200 W (seuil nuage)', fontsize=8, ha='right',
         color=COLOR_IMPORT, alpha=0.95, weight='bold')
ax2.text(23.8, -420, '−200 W (seuil release)', fontsize=8, ha='right',
         color=COLOR_EXPORT, alpha=0.95, weight='bold')

# Handoff threshold reference on bottom panel
ax2.axhline(-1400, ls=':', color=INK, alpha=0.5, lw=1)
ax2.text(23.8, -1620, f'−{EV_MIN} W (seuil bascule - export)', fontsize=8, ha='right', color=INK, alpha=0.75)

ax2.set_ylabel('Réseau (W)\n- export  /  + import', color=INK)
ax2.set_ylim(-4200, 2200)
ax2.set_xlabel('Heure de la journée', color=INK)
ax2.grid(True, axis='y', alpha=0.25, color=MUTED, linestyle='-', linewidth=0.5)
ax2.set_axisbelow(True)

# Import/export legend
handles2 = [
    Patch(facecolor=COLOR_IMPORT, alpha=0.30, label='Import (grid > 0)'),
    Patch(facecolor=COLOR_EXPORT, alpha=0.30, label='Export (grid < 0)'),
]
ax2.legend(handles=handles2, loc='lower left', frameon=False, fontsize=9)

# --- X-axis ---
ax2.set_xticks(range(0, 25, 2))
ax2.set_xticklabels([f'{h:02d}h' for h in range(0, 25, 2)])
ax2.set_xlim(0, 24)

# --- Event markers on the top strip: numbered dots only, full labels in a bottom caption ---
# Times sourced from the simulation state-machine transitions (printed above).
events = [
    (7.6,           '1', '07:40  Le surplus commenc à être rerouté'),
    (8 + 52/60,     '2', f'08:52  Bascule → routeur OFF (surplus > {EV_MIN} W stable 60 s)'),
    (11.5,          '3', '11:30  Nuage → VE pause → export → Release → routeur ON'),
    (12.0,          '4', '12:00  Soleil revient → Bascule → routeur OFF'),
    (14 + 7/60,     '5', f'14:07  SoC {SOC_TARGET} % atteint → routeur ON (chauffe-eau reprend)'),
    (16.5,          '6', '16:30  le chauffe-eau a atteint sa température max'),
]

for h, _, _ in events:
    ax1.axvline(h, color=INK, ls=':', lw=0.9, alpha=0.55, zorder=1)
    ax2.axvline(h, color=INK, ls=':', lw=0.9, alpha=0.55, zorder=1)

# --- Event strip axis (axE) - numbered dots, staggered on two rows to prevent overlap ---
axE.set_ylim(0, 1)
axE.set_yticks([])
axE.tick_params(axis='x', labelbottom=False, bottom=False)
for spine in ('top', 'right', 'left', 'bottom'):
    axE.spines[spine].set_visible(False)

# Two-row stagger - 6 events, all well-spaced except ③/④ (11:30 / 12:00)
row_y = [0.75, 0.25, 0.75, 0.25, 0.75, 0.25]
for (h, num, _), y in zip(events, row_y):
    axE.plot([h], [y], 'o', color=INK, markersize=20, zorder=5)
    axE.text(h, y, num, fontsize=10, ha='center', va='center',
             color='white', weight='bold', zorder=6)
    axE.axvline(h, color=INK, ls=':', lw=0.9, alpha=0.55, zorder=1)

# --- Title + subtitle ---
fig.suptitle('Priorité VE sur routeur solaire - une journée type', fontsize=15, weight='bold', y=0.995)
fig.text(0.5, 0.955,
         f'Bascule : surplus > {EV_MIN} W pendant 60 s   •   '
         f'Restauration : import > {CLOUD_TH} W (nuage) OU export > {RELEASE_TH} W (VE plein) OU SoC ≥ cible OU VE débranché',
         fontsize=9.5, ha='center', color=MUTED, style='italic')

# --- Event legend (numbered) below the figure ---
CIRCLED = ['❶', '❷', '❸', '❹', '❺', '❻', '❼']
lines = [
    '     '.join(f'{CIRCLED[i]} {events[i][2]}' for i in (0, 1, 2)),
    '     '.join(f'{CIRCLED[i]} {events[i][2]}' for i in (3, 4, 5)),
]
fig.text(0.5, 0.045, lines[0], fontsize=9, ha='center', color=INK)
fig.text(0.5, 0.020, lines[1], fontsize=9, ha='center', color=INK)

# Reduce circled digits inside strip to plain numbers 1..7 already; convert here for display:
# (fig.text already uses circled UNICODE above ❶..❼)

plt.tight_layout(rect=[0, 0.06, 1, 0.94])

out_path = '/workspace/Solar-Router-for-ESPHome/docs/images/priority_to_ev_day.png'
plt.savefig(out_path, dpi=150, bbox_inches='tight', facecolor='white')
print(f"Wrote: {out_path}")

# Agent Collaboration & Development Guidelines

This document provides technical rules, architectural principles, and collaboration workflow guidelines for AI agents working in this repository.

---

## 1. What This Repository Is

**Solar Router for ESPHome** is a library of composable ESPHome YAML packages (`solar_router/`) plus example device configurations (`examples/*.yaml`) for DIY solar-surplus diverters, and a static documentation site (`docs/`) published to GitHub Pages via Material for MkDocs.

There is no compiled application source code in the repository: the deliverable is YAML that ESPHome compiles into ESP32/ESP8266/WT32-ETH01 firmware.

> [!CAUTION]
> **Public API Stability:**
> Users import packages *remotely* from GitHub (e.g. `ref: main`), so `solar_router/*.yaml` is effectively a public API. Renaming a file, an ESPHome `id:`, or a `vars` key breaks existing user configurations at their next package `refresh`.

---

## 2. Environment & CLI Commands

### Python Environment
Activate the pre-configured virtual environment:
```bash
source ~/.venv/bin/activate
# or use the user's alias:
venv
```

If setting up from scratch:
```bash
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt      # pinned esphome + mkdocs toolchain
```

### Validating & Building a Single Configuration
**Root configs in `examples/` fetch packages from GitHub `main`, so they never test local edits directly.**
Always convert to a local-source copy first:

```bash
cd examples                                                         # configs, secrets.yaml and .esphome/ all live here
python ../tools/convert_to_local_source.py esp32-standalone.yaml    # -> local_esp32-standalone.yaml (gitignored)
esphome config  local_esp32-standalone.yaml                         # fast syntax / substitution check
esphome compile local_esp32-standalone.yaml                         # full firmware compilation
esphome run     local_esp32-standalone.yaml                         # build + flash / OTA
```

### Pre-Commit Validation Matrix
Before proposing or committing any changes, run the relevant checks:

```bash
# Documentation checks:
mkdocs build --strict                    # Docs must build with zero warnings and zero broken links
./tools/check_documentation_coverage.sh  # Every non-*_common module needs docs/en/<module>.md

# Module structure and versioning:
./tools/check_module_version.sh          # Structural check & version bump verification against last release

# Automated test suite:
bats tests/tools/                        # Bats test suites for repository tools

# Full matrix firmware compilation (when modifying YAML packages):
./tools/compile_all_local_yaml.sh        # Convert + config + compile every root config against local packages
./tools/check_build_coverage.sh          # Every solar_router/*.yaml must be referenced by an example or package
```

### Utility Scripts in `tools/`
- `tools/update_documentation.sh`: Updates changelog via `git-cliff`, builds MkDocs, and deploys to GitHub Pages.  
  **Maintainer only:** AI agents must never run or modify this script.
- `tools/http_server_simulator.py`: Serves a simulated Shelly-EM HTTP JSON endpoint on port 8000 for local testing.

---

## 3. Package Architecture & Contracts

### Composition
A router requires at minimum: **one power meter** + **one engine** + **at least one regulator**.  
A *proxy* is a power meter alone, re-served over HTTP to other routers.

```yaml
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    ref: main
    refresh: 1d
    files:
      - path: solar_router/power_meter_fronius.yaml
        vars: { power_meter_ip_address: "192.168.1.21" }
```

### Module Roles

| Category | Responsibility |
| --- | --- |
| `power_meter_*` | Measures power exchanged with grid. Publishes `real_power` (W; positive = import) and `consumption`, polled every 1s while `power_meter_activated != 0`. `power_sign` flips polarity. |
| `engine_*` | Controls decision logic. Owns `activate` switch, `router_level` (0–100%), `energy_regulation` script, and LED status. Decides *how much* power to divert. |
| `regulator_*` | Controls physical actuator. Owns `regulation_control` script that turns `regulator_opening` into hardware action (Triac dimmer, SSR burst-fire, mechanical relay ON/OFF). |
| `energy_counter_*` | Integrates `power_divertion` into cumulative `energy_diverted` total. |
| `temperature_limiter_*` | Drives `safety_limit` global from `safety_temperature` with hysteresis; engines inhibit diversion when true. `temperature_fan_control.yaml` manages fan cooling. |
| `scheduler_*` | Forces or inhibits routing over defined time windows. |
| Shared | `common.yaml` (restart switch + uptime), `debug_sensors.yaml`, `jsy-mk-194t_common.yaml` (shared UART sensor block). |

### Regulation Loop
1. Power meter publishes `real_power`.
2. `engine_common.yaml` copy sensor `real_power_internal` triggers.
3. `energy_regulation` calculates:  
   `delta = -(real_power - target_grid_exchange) * reactivity / 1000`  
   and clamps `router_level` between 0% and 100%.
4. `router_level.on_value` updates `regulator_opening`.
5. `regulation_control` drives the physical regulator hardware.
6. Oscillation damping: `up_reactivity` / `down_reactivity`. Active `safety_limit` or NaN `real_power` forces level 0.

### Cross-Package Contract (Well-Known IDs)
ESPHome merges all package declarations into a flat namespace. All modules communicate **strictly** via well-known IDs:
- **Sensors:** `real_power`, `consumption`, `safety_temperature`, `power_divertion`, `energy_diverted`
- **Numbers:** `router_level`, `regulator_opening`, `target_grid_exchange`, `up_reactivity`, `down_reactivity`, `load_power`
- **Switches & Globals:** switch `activate`, globals `power_meter_activated`, `safety_limit`, `used_for_cooling`
- **Status LEDs:** `green_led`, `yellow_led`, output `red_led` (semantics documented in `docs/en/engine.md`)
- **Scripts:** `energy_regulation`, `regulation_control`, `power_meter_source`, `energy_diverted_counter`, `safety_limit_check`

### The Two Include Styles (Not Interchangeable!)
- `<<: !include <file>.yaml`: YAML anchor merge key. Used by power meters and temperature limiters to merge a common dictionary into the same YAML file.
- `packages: - !include <file>.yaml`: ESPHome package list merge. Used by engines to include common packages.

---

## 4. Critical Conventions & Gotchas

1. **Substitutions vs `<<:` Merge:**  
   A `substitutions:` block in a file that also merges a common file with `<<:` **replaces** the merged block wholesale instead of extending it. Always re-declare any defaults you need (see comment in `power_meter_shelly_em3.yaml`).
2. **Periodic Execution:**  
   Prefer `interval: - interval: 1s` over `time: - platform: sntp / on_time: ...`. Anonymous `sntp` blocks merge across packages and cause circular-dependency build failures when combined with named time components.
3. **Multi-Instance Parameterization:**  
   Packages that can be instantiated multiple times must parameterize entity IDs using a substitution (`${relay_unique_id}`, `${scheduler_unique_id}`).
4. **Quoted Booleans:**  
   Substitutions are plain strings in ESPHome. Always quote booleans (`"false"`, `"true"`) when used in fields like `internal:` or `inverted:`.
5. **GPIO Pins:**  
   Never hardcode GPIO pin numbers in packages. Always define them as package `vars`.
6. **Module Versioning Text Sensor:**  
   Every module in `solar_router/*.yaml` must end with a diagnostic `text_sensor`:
   - `id`: `version_<filename_without_ext_with_underscores>` (e.g. `version_regulator_mechanical_relay_${relay_unique_id}`)
   - `name`: `<filename_without_ext>` (e.g. `regulator_mechanical_relay_${relay_unique_id}`)
   - Literal version string returned in lambda with `static bool` single-publish guard.
7. **Release Version Rule (`tools/check_module_version.sh`):**  
   Versions are per-module. When any module is modified, its version must be **strictly greater than the last release tag** (e.g. `> 1.6.11`), and all modules modified within the same release must share the exact same version number.
8. **Secrets & CI Resolution:**  
   `examples/secrets.yaml` is gitignored. ESPHome resolves `!secret` in the directory of the root config (`examples/`), never at root. Only use secret keys registered in `.github/workflows/esphome-ci.yaml`.

---

## 5. Documentation Guidelines

### Bilingual Parity
- Documentation is fully bilingual: English (`docs/en/`) and French (`docs/fr/`).
- **English is the source of truth.**
- Parity is mandatory: any file created or modified in `docs/en/` must have its exact counterpart in `docs/fr/`.
- File names, relative image paths, and heading structures must remain identical between `docs/en/` and `docs/fr/`.

### Navigation & MkDocs
- When adding a page, register it in `mkdocs.yml` under `nav:`.
- Add French translations for all new navigation titles under `plugins -> i18n -> nav_translations`.
- Examples are inlined into docs using `--8<-- "examples/<file>.yaml"`.

### Component Documentation Standard
Every component page (regulator, power meter, engine) should follow this standard structure:
1. `# <Component Name>`
2. `## Description`: Clear explanation of the operating principle.
3. `## Diagram`: Visual flowchart or waveform diagram (`images/*.png`).
4. `## Hardware`: Photos, specs, and safety warnings.
5. `## Wiring Diagram`: Electrical connection schematic (`images/*.drawio.png`).
6. `## Configuration`: Minimal YAML configuration snippet.
7. `### Variables`: Markdown table listing `Variable`, `Required`, `Default`, and `Description`.

---

## 6. AI Agent Collaboration Workflow

### Atomic Commits
Every commit must be **atomic** — all changes related to a single issue or improvement are grouped into one commit, and unrelated changes are never mixed:
- Use Conventional Commits format:
  - `fix:` bug fixes, broken links, typos
  - `feat:` new packages, new components
  - `docs:` documentation improvements
  - `refactor:` code restructuring without feature change
  - `chore:` maintenance tasks, tool updates
- Use partial commits (`git add -p` or patch staging) when a file touches multiple separate concerns.

### Validation Before Commit (Strict Rule)
**Never create a commit without explicit user validation.**
1. Explain the proposed changes clearly.
2. Ensure automated validations pass (`mkdocs build --strict`, `check_module_version.sh`, etc.).
3. Wait for the user's explicit approval ("ok", "go", or similar).
4. Create the commit locally.
5. **NEVER push to remote.** The human reviewer will inspect and push.

### Accuracy & Integrity
- **Never invent or assume unverified information** (no fictitious links, channels, or hardware pinouts).
- When encountering an ambiguity, ask the user for clarification.
- If a command or check fails, acknowledge the failure, explain the root cause, propose a fix, and wait for confirmation.

---

## 7. Local Scratch Area

`wip/` is a gitignored scratch workspace for experimental or external elements (such as the Rust/WASM Solar Router Configurator). When working in `wip/`, consult `wip/AGENTS.md`, `wip/SKILL.md`, and `wip/PLAN.md`.

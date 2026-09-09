# AGENTS.md

This file provides guidance to AI agent when working with code in this repository.

## What this repository is

**Solar Router for ESPHome** is a library of composable ESPHome YAML packages (`solar_router/`) plus example device
configurations (root-level `*.yaml`) for DIY solar-surplus diverters, and an mkdocs site (`docs/`) published to GitHub
Pages. There is no application source code: the deliverable is YAML that ESPHome compiles into ESP32/ESP8266 firmware.

Users reference the packages *remotely* from GitHub, so `solar_router/*.yaml` is effectively a public API. Renaming a
file, an ESPHome `id:`, or a `vars` key breaks existing user configurations at their next package `refresh`.

## Commands

Setup:

```bash
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt      # pinned esphome + mkdocs toolchain
```

Validate/build a single config. **Root configs fetch packages from GitHub `main`, so they never test local edits** —
convert to a local-source copy first:

```bash
python tools/convert_to_local_source.py esp32-standalone.yaml   # -> local_esp32-standalone.yaml (gitignored)
esphome config  local_esp32-standalone.yaml    # fast syntax / substitution check
esphome compile local_esp32-standalone.yaml    # full firmware build
esphome run     local_esp32-standalone.yaml    # build + flash/OTA
```

Full-matrix checks (run these before proposing a change):

```bash
./tools/compile_all_local_yaml.sh        # convert + config + compile every root yaml against local packages
./tools/check_build_coverage.sh          # every solar_router/*.yaml must be referenced by a root yaml or another package
./tools/check_documentation_coverage.sh  # every non-*_common module needs docs/en/<module>.md
./tools/check_module_version.sh          # every module must announce a version. if a module has changed, the version should be grater than last release
mkdocs build --strict                    # docs must build with zero warnings/broken links
mkdocs serve                             # preview on 127.0.0.1:8000
```

Other tools:

- `tools/compile_all_remote_yaml.sh` builds against GitHub rather than local files. Its `-s github_branch` flag is a
  no-op (no config uses that substitution), so it always resolves `ref: main`. To exercise a branch remotely, edit
  `url:`/`ref:` temporarily the way CI does.
- `tools/http_server_simulator.py` serves a fake Shelly-EM-style JSON payload on `:8000` for power-meter work without
  hardware.
- `tools/update_documentation.sh` regenerates the changelog with `git cliff` and runs `mkdocs gh-deploy` —
  maintainer-only, don't run it.

## Package architecture

A root device config owns the hardware/network/API sections, then composes packages:

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

A router needs at minimum one **power meter** + one **engine** + at least one **regulator**; a *proxy* is a power meter
alone, re-served over HTTP to other routers.

| Category                | Responsibility                                                                                                                                                                     |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `power_meter_*`         | Publish `real_power` (grid exchange, W; positive = importing) and `consumption`, polled every second while global `power_meter_activated != 0`. `power_sign` flips meter polarity. |
| `engine_*`              | Own the `activate` switch, `router_level` (0–100 %), the `energy_regulation` script, and LED feedback. Decide *how much* to divert.                                                |
| `regulator_*`           | Own the `regulation_control` script that turns `regulator_opening` into hardware action (triac dimmer, SSR, relay).                                                                |
| `energy_counter_*`      | Integrate `power_divertion` into the `energy_diverted` total.                                                                                                                      |
| `temperature_limiter_*` | Drive the `safety_limit` global from `safety_temperature` with hysteresis; engines refuse to divert while it is true. `temperature_fan_control.yaml` adds cooling.                 |
| `scheduler_*`           | Force or inhibit routing over a time window.                                                                                                                                       |
| shared                  | `common.yaml` (restart switch + uptime), `debug_sensors.yaml`, `jsy-mk-194t_common.yaml` (UART sensor block shared by the JSY power meter and its energy counter).                 |

**Regulation loop:** power meter publishes `real_power` → `engine_common.yaml`'s `copy` sensor `real_power_internal`
fires → `energy_regulation` computes `delta = -(real_power - target_grid_exchange) * reactivity / 1000` and clamps
`router_level` to 0–100 → `router_level.on_value` writes `regulator_opening` → `regulation_control` drives the hardware.
`up_reactivity` / `down_reactivity` damp oscillation. A NaN `real_power` or an active `safety_limit` forces level 0.

**Cross-package contract.** ESPHome merges every package into one flat config, so packages communicate *only* through
well-known ids. New packages must honour them:

- sensors: `real_power`, `consumption`, `safety_temperature`, `power_divertion`, `energy_diverted`
- numbers: `router_level`, `regulator_opening`, `target_grid_exchange`, `up_reactivity`, `down_reactivity`, `load_power`
- switch: `activate`; globals: `power_meter_activated`, `safety_limit`, `used_for_cooling`
- lights `green_led` / `yellow_led`, output `red_led` (LED semantics are documented in `docs/en/engine.md`)
- scripts: `energy_regulation`, `regulation_control`, `power_meter_source`, `energy_diverted_counter`,
  `safety_limit_check`

**Two include styles, not interchangeable:**

- `<<: !include power_meter_common.yaml` — YAML merge key, used by power meters and temperature limiters to pull a
  shared block into the same package file.
- `packages: - !include engine_common.yaml` — ESPHome package merge (concatenates lists), used by engines.

## Conventions and traps

- A `substitutions:` block in a file that also merges a common file with `<<:` **replaces** the merged block wholesale
  instead of extending it. Re-declare every default you still need — see the explanatory comment in
  `power_meter_shelly_em3.yaml`.
- Prefer `interval: - interval: 1s` over `time: - platform: sntp / on_time: seconds: /1` for plain periodic work.
  Anonymous sntp blocks from several packages merge, and combining them with a package that owns a named time component
  (`jsy-mk-194t_common.yaml`'s `homeassistant_time_for_solar_router`) caused circular-dependency build failures;
  `esp32-JSY-MK-194T-circular-deps.yaml` exists as the regression case for that fix.
- Packages that could be instantiated twice parameterize their ids with a substitution (`relay_unique_id`,
  `scheduler_unique_id`) — keep that pattern for any new multi-instance package.
- Substitutions are strings: quote booleans (`"False"`, `"true"`) since they are interpolated into fields like
  `internal:` and `inverted:`.
- GPIO pins are always package `vars`, never hard-coded in a package.
- Every package ends with a `Module version` `text_sensor` publishing `<file>.yaml <version>` — a diagnostic
  entity that tells you which modules a device is built from. All modules share one version, the latest git
  tag; `tools/set_version.sh <x.y.z>` rewrites them all and must run before tagging a release. The version is
  a literal, never a substitution (a `substitutions:` block would shadow the merged common's). Multi-instance
  packages parameterize the `id`/`name` with their `*_unique_id`. `power_meter_common.yaml` and
  `temperature_limiter_common.yaml` are excluded: they are merged with `<<: !include`, so a `text_sensor` key
  in the leaf would replace theirs. For the same reason no package declares `esphome: on_boot:` for it — the
  lambda self-publishes once with a `static bool` guard.
- Keep `url:` and `ref: main` literal in root configs: CI `sed`-rewrites those exact strings to the PR head repo/ref so
  the matrix build tests the branch's packages.
- `secrets.yaml` and `local_*.yaml` are gitignored. CI generates its own `secrets.yaml`, so a root config may only use
  secret names listed in the `esphome-ci.yaml` workflow — add new ones there.

## CI

`.github/workflows/esphome-ci.yaml` runs four jobs: a matrix ESPHome build of every root `*.yaml` (note
`esp8266-proof-of-concept.yml` is skipped — `.yml` extension), build coverage, documentation coverage, and
`mkdocs build --strict`.

`pr-title-check.yaml` enforces conventional-commit PR titles. This matters beyond style: `cliff.toml` generates the
published changelog from *merge commit* subjects, so the PR title is what users read.

## Documentation

English is the source of truth; `docs/en/` and `docs/fr/` are kept file-for-file in parity (mkdocs-static-i18n, folder
structure). A new module needs `docs/en/<module>.md`, `docs/fr/<module>.md`, a `nav:` entry in `mkdocs.yml`, and a
`nav_translations` entry if its title is new. Example device configs are inlined into the site with
`--8<-- "esp32-standalone.yaml"`, so editing a root config changes the docs.

## Local scratch area

`wip/` is gitignored local scratch, not part of the repository — it holds design work for a separate Rust/WASM "Solar
Router Configurator" (a HACS Home Assistant dashboard element). When working in there, `wip/AGENTS.md` (engineering
rules), `wip/SKILL.md` (dev environment) and `wip/PLAN.md` (roadmap) are the governing documents.

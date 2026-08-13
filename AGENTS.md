# AGENTS.md - AI Development Guidelines for Solar Router for ESPHome

## Project Overview

**Solar Router for ESPHome** is a DIY project providing specialized hardware and software for optimizing solar energy utilization. It performs real-time monitoring and intelligent surplus energy management to channel excess solar energy to designated loads like water heaters or frost protection systems. The project integrates seamlessly with Home Assistant via ESPHome firmware.

## Role & Responsibilities

You are an AI assistant helping with the development of ESPHome firmware configurations for this project. Your primary responsibilities include:

- Maintaining and extending ESPHome YAML configurations
- Ensuring consistency across modular package system
- Validating YAML syntax and ESPHome compatibility
- Assisting with documentation updates
- Helping with testing and validation scripts

## Repository Structure

```
Solar-Router-for-ESPHome/
├── docs/                    # Documentation (English & French)
│   ├── en/                 # English documentation
│   └── fr/                 # French documentation
├── solar_router/           # Reusable ESPHome packages (core development area)
│   ├── common.yaml         # Common components (restart switch, uptime sensor)
│   ├── engine_*.yaml       # Engine configurations (1dimmer, 1switch, etc.)
│   ├── engine_common.yaml  # Common engine functionality
│   ├── power_meter_*.yaml  # Power meter integrations
│   ├── regulator_*.yaml    # Regulator types (triac, relay)
│   ├── energy_counter_*.yaml # Energy counting methods
│   ├── temperature_limiter_*.yaml # Temperature safety
│   └── scheduler_*.yaml    # Scheduling functionality
├── blueprints/            # Home Assistant blueprints (YAML)
├── *.yaml                 # Complete device configurations
├── tools/                 # Development and validation scripts
├── site/                  # Generated documentation site
├── .esphome/              # ESPHome build cache
└── mkdocs.yml             # Documentation configuration
```

## Development Guidelines

### 1. ESPHome YAML Standards

**ALWAYS:**
- Use consistent indentation (2 spaces)
- Follow existing naming conventions (snake_case for IDs, spaces in display names)
- Include comments for each major section
- Use substitutions for configurable parameters
- Maintain backward compatibility when possible
- Test configurations with `esphome validate` before committing

**NEVER:**
- Hardcode IP addresses or credentials (use secrets.yaml or variables)
- Remove existing functionality without discussion
- Break the modular package system
- Use tabs for indentation
- Commit API keys or passwords

### 2. Package Architecture Rules

The project uses a **modular package system** where:

- **`solar_router/`** contains reusable component packages
- **Root YAML files** are complete device configurations that reference packages
- **Packages must be self-contained** and declarative
- **Dependencies flow upward**: common → specialized packages → device configs

**Package Types:**
- **Common**: `common.yaml` - Base components for all devices
- **Power Meters**: Measure grid energy exchange (Fronius, HA API, Proxy, JSY-MK-194T, Shelly EM, Shelly EM3 Pro)
- **Engines**: Control logic for energy diversion (progressive or ON/OFF)
- **Regulators**: Physical control (Triac, SSR, Mechanical Relay)
- **Energy Counters**: Track diverted energy
- **Temperature Limiters**: Safety mechanisms
- **Schedulers**: Time-based automation

### 3. Configuration Patterns

**Required Structure for Device Configs:**
```yaml
# Hardware-specific configuration
esphome:
  name: device-name
  friendly_name: Display Name
  # Actual pin varies by target: see esp32-standalone.yaml (2026.1.0),
  # esp32-JSY-MK-194T.yaml (2025.9.0), etc. Update per feature use.
  min_version: 2026.1.0

# Hardware platform (esp32, esp8266, etc.)
# ...

# Standard components
logger:
api:
  encryption:
    key: !secret api_encryption_key
wifi:
  ssid: !secret wifi_ssid
  password: !secret wifi_password

# Package inclusion
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    ref: main
    files:
      - path: solar_router/common.yaml
      - path: solar_router/power_meter_*.yaml
        vars:
          parameter: value
      - path: solar_router/regulator_*.yaml
        vars:
          pin: GPIOxx
```

### 4. Variable and Substitution Conventions

**Global Variables:**
- Use `globals:` for runtime state
- Use `substitutions:` for compile-time configuration
- Prefix internal IDs with component name (e.g., `regulator_opening`, `real_power`)

**Common Substitutions:**
- `green_led_pin`, `yellow_led_pin` - LED GPIO pins (values are board-specific; see the target `.yaml` header)
- `regulator_gate_pin`, `regulator_zero_crossing_pin` - Regulator control pins
- `power_meter_ip_address` - Network addresses
- `hide_regulators`, `hide_leds` - Visibility toggles

### 5. Home Assistant Integration

**Sensor Standards:**
- Use appropriate `device_class` (power, energy, temperature, etc.)
- Set `unit_of_measurement` appropriately
- Use `internal: true` for debugging sensors
- Follow HA naming conventions for entity names

**Entity Types:**
- **Switches**: For ON/OFF controls (Activate Solar Routing, Restart)
- **Numbers**: For configurable parameters (Router Level, Reactivity, etc.)
- **Sensors**: For readings (Real Power, Consumption, Uptime)
- **Lights**: For LED indicators (Yellow Led, Green Led)

### 6. Documentation Requirements

**Every module in `solar_router/` MUST have:**
- Corresponding English documentation in `docs/en/`
- French translation in `docs/fr/`
- Diagram images in `docs/images/` where applicable

**Documentation Check:**
```bash
./tools/check_documentation_coverage.sh
```

### 7. Testing and Validation

**Before Committing:**
1. Validate YAML syntax: `esphome validate <config>.yaml`
2. Check documentation coverage: `./tools/check_documentation_coverage.sh`
3. Verify build compatibility: `./tools/compile_all_local_yaml.sh`

**Validation Tools:**
- Use `esphome config` / `esphome compile` for configuration validation
- Use `esphome run` for testing (with hardware or simulator)
- HTTP server simulator available in `tools/http_server_simulator.py`

### 8. Version Control Standards

**Commit Messages:**
- Follow [Conventional Commits](https://www.conventionalcommits.org/)
- Use prefixes: `feat:`, `fix:`, `doc:`, `refactor:`, `build:`, `chore:`
- Reference issues with `#number` when applicable

**Changelog:**
- Auto-generated using `git-cliff` (configured in `cliff.toml`)
- Update via: `./tools/update_documentation.sh`

**Branching:**
- Main branch: `main`
- Feature branches: `feat/description` or `feature/description`
- Releases are cut as `vX.Y.Z` tags on `main`; there is no long-lived `release/*` branch.

### 9. Security Considerations

**NEVER commit:**
- API encryption keys
- WiFi passwords
- OTA passwords
- IP addresses

**ALWAYS use:**
- `!secret` references for sensitive data
- Environment variables for local testing
- `.gitignore` for local configuration files

### 10. Hardware-Specific Notes

**Supported Platforms:**
- ESP32 (primary development target)
- ESP8266 (limited configurations)
- ESP8285 (proxy clients)
- WT32-ETH01 (Ethernet support)

**Common Hardware Configurations:**
- Triac-based regulators: Require zero-crossing detection
- Relay-based regulators: Simpler ON/OFF control
- Multiple regulator types supported in same firmware

**GPIO Usage:**
Actual pin numbers are board-specific. See the `substitutions:` block at
the top of the relevant device YAML (e.g. `esp32-standalone.yaml`,
`esp32-JSY-MK-194T.yaml`, `esp8266-proxy_client.yaml`) for authoritative
values.

Typical assignments (verify per board):
- LED indicators: exposed via `green_led_pin` / `yellow_led_pin` substitutions
- Triac gate: exposed via `regulator_gate_pin`
- Zero-crossing: exposed via `regulator_zero_crossing_pin` (inverted; on
  `esp32-standalone.yaml` this is GPIO23)
- Temperature sensor: exposed via `DS18B20_pin`

## Workflow Commands

### Development
```bash
# Validate a configuration
esphome config path/to/config.yaml

# Check all local configurations
./tools/check_build_coverage.sh

# Compile all local YAML files
./tools/compile_all_local_yaml.sh

# Check documentation completeness
./tools/check_documentation_coverage.sh
```

### Documentation
```bash
# Update changelog and publish docs
./tools/update_documentation.sh

# Build documentation locally
mkdocs build

# Serve documentation locally
mkdocs serve
```

## Common Tasks

### Adding a New Power Meter Integration
1. Create `solar_router/power_meter_<name>.yaml`
2. Include `power_meter_common.yaml` via a `packages:` block
3. Implement the `power_meter_source` script — this is the entry point
   the SNTP `on_time` handler in the package calls; the script must
   publish the grid-exchange power to `id(real_power)` (and, where
   applicable, house consumption to `id(consumption)`). See
   `power_meter_fronius.yaml` and `power_meter_shelly_em.yaml` for
   reference implementations.
4. Add documentation in `docs/en/power_meter_<name>.md`
5. Add French translation in `docs/fr/`
6. Update `mkdocs.yml` navigation

### Adding a New Engine Type
1. Create `solar_router/engine_<type>.yaml`
2. Include `engine_common.yaml` via a `packages:` block
3. Implement regulation logic in scripts
4. Add corresponding documentation
5. Ensure backward compatibility with existing regulators

### Adding a New Regulator Type
1. Create `solar_router/regulator_<type>.yaml`
2. Define output components and control scripts
3. Document hardware requirements
4. Add wiring diagrams to `docs/images/`

## Troubleshooting Guide

### Common Issues
- **YAML syntax errors**: Use `esphome config` with full path
- **Missing substitutions**: Ensure all variables are defined or passed via `vars:`
- **ESPHome version mismatch**: Update `min_version` in esphome section
- **Network connectivity**: Check WiFi credentials in secrets.yaml
- **API connection**: Verify encryption key and Home Assistant configuration

### Debugging
- Enable debug logging: Set `logger: level: DEBUG`
- Use serial monitor: `esphome logs <device>.yaml`
- Check LED indicators: Yellow LED shows WiFi status, Green LED shows routing status

## Resources

- **ESPHome Documentation**: https://esphome.io/
- **Home Assistant ESPHome Integration**: https://www.home-assistant.io/integrations/esphome/
- **Project Documentation**: https://hacf-fr.github.io/Solar-Router-for-ESPHome/
- **Issue Tracker**: https://github.com/hacf-fr/Solar-Router-for-ESPHome/issues

## AI-Specific Instructions

When assisting with this project:

1. **Always read the relevant documentation** before suggesting changes
2. **Test your suggestions** with validation tools when possible
3. **Maintain consistency** with existing patterns and conventions
4. **Ask for clarification** if requirements are ambiguous
5. **Provide complete examples** when showing how to implement features
6. **Reference existing code** when proposing new functionality
7. **Respect the modular architecture** - don't suggest changes that would break the package system

**For YAML modifications:**
- Always show the complete section being modified
- Include proper indentation
- Maintain comment formatting
- Use existing variable names when possible

**For documentation:**
- Follow existing markdown style
- Include code examples with proper YAML formatting
- Reference related components and dependencies
- Maintain both English and French versions

---

*Project: Solar Router for ESPHome*
*Maintainer: hacf-fr*

# Troubleshooting

## Description

This page lists common issues with Solar Router for ESPHome and how to diagnose them. Start with the LED indicators, then check the power meter and regulation behaviour.

For installation steps, see [Installation](installation.md). For architecture choices, see [Firmware](firmware.md).

## Diagnostic checklist

1. Is the ESP online in Home Assistant?
2. What do the [status LEDs](engine.md#user-feedback-leds) show?
3. Is **Activate Solar Routing** turned ON?
4. Is `real_power` updating about once per second (not stuck / not `unknown`)?
5. Is a [temperature safety limit](temperature_limiter.md) active?
6. Are `target_grid_exchange`, `up_reactivity`, and `down_reactivity` sensible for your install?

Optional: enable [debug sensors](debug_sensors.md) and check [module versions](module_version.md).

## Status LEDs

| LED | Pattern | Meaning |
| --- | --- | --- |
| Yellow | OFF | No power / board not powered |
| Yellow | ON | Connected to the network |
| Yellow | Blink | Trying to reconnect to the network |
| Yellow | Fast blink | Error reading grid exchange power (`real_power` is NaN) |
| Green | OFF | Automatic regulation deactivated |
| Green | ON | Regulation active, not diverting |
| Green | Blink | Currently diverting energy to the load |

Full details: [Engine overview — User feedback LEDs](engine.md#user-feedback-leds).

## Common problems

### Yellow LED blinks fast / `real_power` is `unknown` or NaN

**Cause:** the power meter cannot read a valid value.

**Checks:**

* Network power meters (Fronius, Shelly, proxy client): device reachable on the LAN? Correct `power_meter_ip_address`?
* Home Assistant power meter: entity IDs correct? Sensor updating often enough? See [Home Assistant power meter](power_meter_home_assistant.md).
* Proxy: is the proxy ESP online and is `power_meter_activated_at_start: "1"` set on the proxy?
* JSY-MK-194T: UART pins and baud rate correct? See [JSY-MK-194T power meter](power_meter_jsy-mk-194t.md).
* Try `power_sign: "-1"` if the CT orientation is inverted (values look mirrored).

### Router never diverts (green LED stays ON)

**Checks:**

* **Activate Solar Routing** is ON.
* Surplus is actually available: `real_power` should be negative (export) beyond `target_grid_exchange`.
* `safety_limit` is not active (temperature limiter).
* For ON/OFF engine: start level / tempos correctly set — see [Engine 1 × switch](engine_1switch.md).

### Router oscillates ON/OFF or level hunts

**Checks:**

* Lower `up_reactivity` / `down_reactivity` (less aggressive).
* ON/OFF engine: start level must be greater than the load power; adjust start/stop tempos.
* Multi-channel / bypass engines: increase Bypass Tempo to reduce relay flicker.
* Multiple routers: stagger targets and reactivity — see [Multiple Solar Router configuration](firmware.md#multiple-solar-router-configuration).

### Load works in manual mode but not automatically

**Checks:**

* Prefer adjusting `router_level` rather than `regulator_opening` alone (LEDs and energy counter follow `router_level`).
* Confirm the engine package matches the regulators wired (e.g. mechanical relays need fixed `relay_unique_id` values for multi-channel engines).

### WiFi drops or ESP does not reconnect

Remove `ap:` and `captive_portal:` from the ESPHome config. See [Installation — Step 1](installation.md#step-1-install-and-configure-esphome-firmware).

### Temperature safety will not clear / diversion stuck at 0 %

**Checks:**

* Sensor reachable? If the temperature source is missing, `safety_limit` stays active.
* Hysteresis: wait until temperature returns past the release threshold.
* Validate carefully before leaving unattended — see [Temperature limiter](temperature_limiter.md).

### Home Assistant database grows quickly

`real_power` and energy sensors update every second. Exclude high-frequency entities from the recorder — see [Recorder configuration](recorder_configuration.md).

### Module version sensors look inconsistent

Different modules can have different versions; that is normal. See [Module versions](module_version.md).

## FAQ

**Do I need Home Assistant for regulation?**  
No for native power meters (Fronius, Shelly, JSY, proxy). Yes if you use the [Home Assistant power meter](power_meter_home_assistant.md) or HA temperature limiter. HA is still useful for dashboards and the Activate switch.

**Standalone or proxy?**  
See [Choosing an architecture](firmware.md#choosing-an-architecture).

**Positive vs negative `real_power`?**  
By convention, positive means import from the grid, negative means export. Use `power_sign` to flip if your meter is inverted.

**Where can I get help?**  
Open an issue or discussion on the [GitHub repository](https://github.com/hacf-fr/Solar-Router-for-ESPHome).

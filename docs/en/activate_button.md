# Activation push button

This package adds a **physical push button** to the solar router, wired to a GPIO of the ESP32. Each press toggles solar routing activation, without requiring any network, Home Assistant or web browser.

The button is a shortcut to the *Activate Solar Routing* switch: it holds no state of its own, it simply toggles the one of the `activate` switch.

## Prerequisites

This package is not standalone. It relies on a symbol provided by another package that must be included in your configuration:

- an `engine_*` package (e.g. `engine_1dimmer.yaml`) that provides the `activate` switch.

!!! warning "Not to be combined with an activation switch"
    If [activate_switch](activate_switch.md) or [activate_switch_3positions](activate_switch_3positions.md) is also included with its default strict behaviour, the physical switch continuously enforces its own position and the button has no lasting effect. Use one **or** the other, or set `activate_switch_strict` to `"false"` so both can drive the router.

## Behaviour at boot

The button changes nothing at start-up: `activate` keeps the state restored from flash by the engine (`restore_mode: RESTORE_DEFAULT_OFF`). If you need the state of the router to be unambiguously readable on the front panel after a power cut, use [activate_switch](activate_switch.md) instead.

## Wiring

The button is a simple normally-open dry contact between the GPIO and the ground. No external resistor is needed: the internal pull-up of the ESP32 is enabled by the package.

![](../images/activate_button.drawio.png)

With this wiring, the contact is **closed** while the button is pressed, which is the default polarity of the package (`activate_button_inverted: "True"`). If you use a normally-closed button, set `activate_button_inverted` to `"False"`.

!!! danger "Choose a usable GPIO"
    GPIO6 to GPIO11 are wired to the internal SPI flash of the ESP32 and cannot be used. GPIO34 to GPIO39 are input-only and have **no internal pull-up**, so they are not suitable either unless you add an external pull-up resistor. GPIO32 and GPIO33 are a safe choice.

## Configuration

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  activate_button:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/activate_button.yaml
        vars:
          activate_button_pin: GPIO33
```

### Variables

| Variable                   | Required | Default  | Description                                                                                                     |
| -------------------------- | -------- | -------- | --------------------------------------------------------------------------------------------------------------- |
| `activate_button_pin`      | yes      | —        | GPIO pin the button is connected to. The internal pull-up is enabled.                                           |
| `activate_button_inverted` | no       | `"True"` | Set to `"False"` if the contact is **open** while the button is pressed (normally-closed button).               |
| `activate_button_debounce` | no       | `50ms`   | Debounce time of the mechanical contact. Increase it if a single press toggles the router several times.        |
| `hide_activate_button`     | no       | `"True"` | Set to `"False"` to expose the raw state of the contact in Home Assistant, which is handy to check your wiring. |

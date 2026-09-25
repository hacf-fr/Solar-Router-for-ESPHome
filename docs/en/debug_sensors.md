# Debug Sensors

## Description

The debug sensors package exposes ESPHome diagnostic information in Home Assistant for monitoring and troubleshooting (heap, loop time, reset reason, and related values).

This page is part of the [Home Assistant integration](home_assistant.md) guide.

![Debug Sensors](images/diagnostics.png){ align=center }

## Configuration

To use this package, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    refresh: 1d
    files: 
      - path: solar_router/debug_sensors.yaml
```

### Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| — | — | — | This package has no configuration variables. |

!!! note "Hardware"
    The package enables ESPHome `debug` sensors and declares a PSRAM block. Use it on boards that support these features (typically ESP32).

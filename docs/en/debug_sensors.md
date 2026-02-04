# Debug Sensors

Allows retrieving certain information in Home Assistant for debugging and monitoring purposes.

![Debug Sensors](images/diagnostics.png){ align=center }
 
To use this package, add the following lines to your configuration file:

```yaml
packages:
  solar\_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    refresh: 1d
    files: 
      - path: solar\_router/debug\_sensors.yaml
```

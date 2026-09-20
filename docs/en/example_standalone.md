# Standalone Solar Router

This configuration implements a **Solar Router** with a progressive regulation. It uses [Fronuis power meter](power_meter_fronius.md), [Triac regulator](regulator_triac.md), [Progressive engine](engine_1dimmer.md).

GPIO pins have been defined to match hardware configuration described [here](hardware.md)


```yaml linenums="1"
--8<-- "examples/esp32-standalone.yaml"
```
# Routeur Solaire Autonome

Cette configuration implémente un **Routeur Solaire** avec une régulation progressive. Il utilise le [Power Meter Fronius](power_meter_fronius.md), le [régulateur Triac](regulator_triac.md), et le [progressive engine](engine_1dimmer.md).

Les broches GPIO ont été définies pour correspondre à la configuration matérielle décrite [ici](hardware.md)

```yaml linenums="1"
--8<-- "examples/esp32-standalone.yaml"
```
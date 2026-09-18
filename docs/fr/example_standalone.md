# Routeur Solaire Autonome

Cette configuration  implement un **Routeur Solaire** avec une régulation profressive. Il utilise le [powermeter Fronius](power_meter_fronius.md), le [regulator Triac](regulator_triac.md), et le [progressive engine](engine_1dimmer.md).

Les broches GPIO ont été définies pour correspondre à la configuration matérielle décrite [ici](hardware.md)

```yaml linenums="1"
--8<-- "examples/esp32-standalone.yaml"
```
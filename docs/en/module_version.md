# Module versions

Every package of the solar router publishes its own version to Home Assistant, so a device says
which modules it is built from and which version of each one it runs.

A solar router is assembled from packages, and once compiled they leave no trace of that assembly:
two routers with very different capabilities look alike from Home Assistant. These entities close
that gap.

## Where to find them

They are **diagnostic** entities, so Home Assistant groups them in the *Diagnostic* section of the
device page. Each one is named after the package file it comes from, and its state is the version:

| Entity                                      | State   |
| ------------------------------------------- | ------- |
| `sensor.solarrouter_common`                 | `1.1.1` |
| `sensor.solarrouter_power_meter_fronius`    | `1.6.3` |
| `sensor.solarrouter_regulator_triac`        | `1.6.3` |
| `sensor.solarrouter_engine_1dimmer`         | `1.6.6` |

The list you see *is* the composition of your router. A package that is not loaded publishes
nothing, so the regulator, the power meter and the engine can all be told apart at a glance — which
matters most for the regulators, since `regulator_triac`, `regulator_solid_state_relay` and
`regulator_mecanical_relay` publish no other entity at all.

## Reading the versions

!!! note "Different versions across modules is normal"
    A release only raises the version of the modules it actually changed, so a healthy router shows
    a spread of versions — `common` may sit at `1.1.1` while `temperature_fan_control` is at
    `1.6.7`, both from the same release.

    It follows that the highest version on a device is a **lower bound** on the release it was
    built from, not the release itself. A router built at `v1.6.7` whose packages were untouched by
    that release will show nothing above `1.6.6`.

To check whether a module is behind, compare it with the same file in the
[repository](https://github.com/hacf-fr/Solar-Router-for-ESPHome/tree/main/solar_router) rather than
with the release number.

## When they are published

The value is sent **once, about ten seconds after the device boots**, and then never again — it
cannot change while the device is running. Two consequences worth knowing:

* right after a restart the entities are briefly `unknown`, which is expected;
* the value you see is the one compiled into the firmware, not something read live. Updating your
  packages requires recompiling and uploading before the versions change.

## Packages loaded more than once

`regulator_mecanical_relay` and `scheduler_forced_run` can be loaded several times, so their entity
name carries their unique id. With three mechanical relays you get
`regulator_mecanical_relay_1`, `_2` and `_3`; with the default scheduler you get
`scheduler_forced_run_Forced`.

!!! warning "One module is invisible"
    `power_meter_home_assistant` overrides the sensors of `power_meter_common`, and that override
    also replaces the common's version entity. On a router using the Home Assistant power meter,
    `power_meter_common` therefore publishes no version even though it is loaded. Its absence tells
    you nothing.

## Turning them off

These entities are harmless — they hold one short string and never update — but they can be
disabled in Home Assistant like any other entity if you would rather not see them. Doing so hides
your router's composition from anything that reads it, so keep them on if you may ever ask for
support.

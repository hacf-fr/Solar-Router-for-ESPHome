# Firmware

## Description

The firmware is split into several packages that you assemble according to your needs.

![packages combination](images/packages.drawio.png)

Packages are:

* **Power meter**: measures the energy exchanged with the grid.
* **Engine**: decides how much surplus energy to divert to the load, and when.
* **Regulator**: channels the surplus energy to a designated load.
* **Energy counter**: reports the amount of energy diverted to the load.
* **Temperature limiter**: stops diversion when a temperature limit is reached.
* **Scheduler**: schedules forced run or inhibition windows.

## Choosing an architecture

| Architecture | ESP boards | Typical use | Pros | Cons |
| --- | --- | --- | --- | --- |
| [Standalone](#standalone-configuration) | 1 × ESP32 | Meter and load are close | Simplest setup, lowest latency | All wiring on one board |
| [Power meter proxy](#power-meter-proxy-configuration) | 1 × meter ESP + 1 × router ESP | Meter far from the load (e.g. panel vs water heater) | Flexible placement; proxy can run on ESP8266/ESP8285 | Needs a reliable local network |
| [Multiple routers](#multiple-solar-router-configuration) | 1 × primary router + 1+ secondary routers | Several loads to divert in sequence | Scales to more loads | Tune reactivity and targets carefully to avoid conflicts |

**Recommendation:** start with **standalone** if the power meter and the load can share the same ESP. Use a **proxy** when the CT/meter is in the electrical panel and the regulator must sit next to the load. Use **multiple routers** only when you need to divert to more than one load.

## Packages

Packages can be combined to create different solar router setups, as in the following examples.

### Standalone configuration

In this standalone configuration, a single ESP32 runs all required packages (power meter + engine + regulator).

![hardware connection](images/standalone.drawio.png){width=374}

### Power Meter Proxy configuration

In this proxy configuration, two ESPs share the work. The first one (for example in the electrical panel) gathers power meter information. The second one (for example next to the water heater) gets that information over the network and performs regulation.

![hardware connection](images/with_proxy.drawio.png){width=535}

!!! note
    A power meter proxy does not need much CPU power and can run on an ESP8285 or ESP8266.

### Multiple Solar Router configuration

In this multiple solar router configuration, two solar routers are installed. The first one reads the power exchanged with the grid and diverts surplus to a water heater. The second one reads power exchange information from the first one using a proxy power meter. Based on that information, it diverts surplus energy to another load (for example an anti-frost system).

![hardware connection](images/multiple_routers.drawio.png){width=756}

!!! note
    `reactivity` and `target grid exchange` must be adjusted carefully on both solar routers to avoid regulation conflicts.

# Hardware

The hardware used for development is the one proposed by [F1ATB.fr](https://f1atb.fr/fr/routeur-photovoltaique-realisation-materielle/) ![fr](images/france.png).

On the photos below; as the heat sink provided by RobotDyn is under-dimensioned, the triac has been unsoldered from the board and screwed into a big heat sink. Wires have been added to link the triac into the board.

A 12V power supply is used in addition with a buck converter to power the system. The 12V may be used to power a fan in an event of an over heating.

![SolarRouteOpen](images/SolarRouterOpen.png){ width=360 }
![SolarRouteClose](images/SolarRouterClosed.png){ width=300 }

The router has been built to be connected to a frost protection system and then provide standard electrical sockets.

## Using a regulator base on a triac

![triac connection](images/hardware_triac.drawio.png)

Bill of material:

* 1 x ESP32-dev board (Wroom-32U with external antenna)
* 1 x Green LED
* 1 x Yellow LED
* 1 x Triac from RobotDyn 24A
* 2 x resistor 470 Ohms for LEDs

## Using a regulator base on a relay

![relays connection](images/hardware_relais.drawio.png)

Bill of material:

* 1 x ESP32-dev board (Wroom-32U with external antenna)
* 1 x Green LED
* 1 x Yellow LED
* 1 x Solid state relay
* 2 x resistor 470 Ohms for LEDs

## The smallest Solar Router

![small solar router](images/micro_power_router.png){ width=200 }

Bill of material:

* 1 x ESP01 relay module board
* 1 x ESP8266 (or equivalent)

!!! Note "This router has some limitation"
    * It has to be used with ON/OFF regulation (engine_1switch.yaml) and is not compatible with variable engine
    * Due to the small space of memory, it doesn't support OTA update
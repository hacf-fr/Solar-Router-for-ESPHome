Permet l'utilisation d'un capteur de puissance JSY-MK-194T

Plusieurs configurations sont possibles :
  - standalone, on utilise les deux capteur du JSY-MK-194T (Ch1 : capteur sur la charge, Ch2 capteur de puissance de la mainson au niveau du compteur EDF)
  - hybride (exemple home assistant pour la mesure real_power + jsy-mk-194t pour l'energie dérivée) => utile si le routeur est loin du point de mesure, ou si contrat en 0 injection (il faudra creer dans HA un capteur virtuelle de simulation d'injection en estimant l'energie potentielle non produite cf par exemple le projet   https://github.com/M3c4tr0x/ESP-PowerSunSensor)


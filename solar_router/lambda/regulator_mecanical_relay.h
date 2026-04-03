#pragma once
#include "esphome.h"

namespace regulator_mecanical_relay {

// Version efficace utilisant des pointeurs vers les composants ESPHome
template <class BS, class S> void regulation_control(BS *sensor, S *relay) {

  if (sensor == nullptr || relay == nullptr)
    return; // Sécurité

  if (sensor->state) {
    relay->turn_on();
  } else {
    relay->turn_off();
  }
}
} // namespace regulator_mecanical_relay
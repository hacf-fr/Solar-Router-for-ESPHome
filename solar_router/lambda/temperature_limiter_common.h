#pragma once

#include "esphome.h"
#include <string>

namespace temperature_limiter_common {
void safety_limit_check() {
  if (isnan(id(safety_temperature).state)) {
    // Can't read temperature. Activatinf safety limit.
    id(safety_limit) = true;
    id(red_led).turn_on();
    return;
  }
  if (id(safety_limit)) {
    if (id(used_for_cooling)) {
      // Temperature is increasing until we can restart the cooling system
      if (id(safety_temperature).state >= id(restart_temperature).state) {
        // Limit is no more reached, regulation can restart
        id(safety_limit) = false;
      }
    } else {
      // Temperature is decreasing until we can restart the heating system
      if (id(safety_temperature).state <= id(restart_temperature).state) {
        // Limit is no more reached, regulation can restart
        id(safety_limit) = false;
      }
    }
  } else {
    if (id(used_for_cooling)) {
      // Temperature has enough decreased we stop the cooling system
      if (id(safety_temperature).state <= id(stop_temperature).state) {
        // Limit is reached, stop regulation
        id(safety_limit) = true;
      }
    } else {
      // Temperature has enough increased we stop the heating system
      if (id(safety_temperature).state >= id(stop_temperature).state) {
        // Limit is reached, stop regulation
        id(safety_limit) = true;
      }
    }
  }
  if (id(safety_limit)) {
    id(red_led).turn_on();
  } else {
    id(red_led).turn_off();
  }
}
}  // namespace temperature_limiter_common
#pragma once

#include "esphome.h"

namespace energy_counter_theorical {
void energy_diverted_counter() {
  double diverted_energy = id(load_power).state * id(router_level).state / 100;
  if (id(consumption).state >= diverted_energy or isnan(id(consumption).state)) {
    // Power diverted is consumed (or we don't know the consumption)
    id(power_divertion).publish_state(diverted_energy);
  } else {
    // Power diverted is not consumed
    id(power_divertion).publish_state(0.0);
  }
}
}  // namespace energy_counter_theorical
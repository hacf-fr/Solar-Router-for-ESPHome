#pragma once

#include "esphome.h"

namespace engine_1dimmer {
void energy_regulation() {
  if (isnan(id(real_power).state) or id(safety_limit)) {
    // If we can have information about grid exchange or if safety_limit is active, do not divert any energy
    id(router_level).publish_state(0);
    return;
  }

  // Calculate the power difference and adjust the regulator opening percentage
  double real_power_state = id(real_power).state;
  double target_grid_exchange_state = id(target_grid_exchange).state;
  double reactivity_state = NAN;
  if (real_power_state >= target_grid_exchange_state) {
    reactivity_state = id(down_reactivity).state;
  } else {
    reactivity_state = id(up_reactivity).state;
  }

  double delta = -1 * (real_power_state - target_grid_exchange_state) * reactivity_state / 1000;
  // Determine the new regulator status
  double new_router_level = id(router_level).state + delta;
  new_router_level = std::max(0.0, std::min(100.0, new_router_level));
  id(router_level).publish_state(new_router_level);
}
}  // namespace engine_1dimmer
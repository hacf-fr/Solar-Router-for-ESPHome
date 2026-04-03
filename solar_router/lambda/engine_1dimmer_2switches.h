#pragma once

#include "esphome.h"

namespace engine_1dimmer_2switches {
void energy_regulation() {
  // Safety check: Disable regulation if power readings are invalid or safety is triggered
  if (isnan(id(real_power).state) or id(safety_limit)){
    id(router_level).publish_state(0);
    id(relay1_tempo_counter).publish_state(id(full_power_duration).state);
    id(relay2_tempo_counter).publish_state(id(full_power_duration).state);
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
  
  double delta = -1*(real_power_state-target_grid_exchange_state)*reactivity_state/3000;
  
  // Determine the new regulator status
  double new_router_level = id(router_level).state + delta;
  new_router_level = std::max(0.0, std::min(100.0, new_router_level));

  if (new_router_level >= 100.0) {
    id(relay2_tempo_counter).publish_state(0);
    id(relay1_tempo_counter).publish_state(0);
  } else if (new_router_level >= 66.66666666) {
    if (id(relay2_tempo_counter).state > 0) {
      new_router_level = 66.66666666;
    }

    id(relay2_tempo_counter).publish_state(id(relay2_tempo_counter).state - 1);
    id(relay1_tempo_counter).publish_state(0);
  } else if (new_router_level >= 33.33333333) {
    if (id(relay1_tempo_counter).state > 0) {
      new_router_level = 33.33333333;
    }

    id(relay2_tempo_counter).publish_state(id(full_power_duration).state);
    id(relay1_tempo_counter).publish_state(id(relay1_tempo_counter).state - 1);
  } else {
    id(relay2_tempo_counter).publish_state(id(full_power_duration).state);
    id(relay1_tempo_counter).publish_state(id(full_power_duration).state);
  }

  id(router_level).publish_state(new_router_level);
}
}  // namespace engine_1dimmer_2switches
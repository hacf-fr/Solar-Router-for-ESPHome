#pragma once

#include "esphome.h"

namespace engine_1dimmer_1bypass {
void energy_regulation() {
  // Safety check: Disable automatic regulation if power readings are invalid or
  // safety is triggered
  if ((id(power_meter_activated) == 1) and (isnan(id(real_power).state)) or
      id(safety_limit)) {
    id(router_level).publish_state(0);
    id(bypass_tempo_counter).publish_state(NAN);
    return;
  }

  // If router is activated, calculate the power difference and adjust the
  // regulator opening percentage
  if ((id(power_meter_activated) == 1)) {
    // Calculate the power difference and adjust the regulator opening
    // percentage
    double real_power_state = id(real_power).state;
    double target_grid_exchange_state = id(target_grid_exchange).state;
    double reactivity_state = NAN;
    if (real_power_state >= target_grid_exchange_state) {
      reactivity_state = id(down_reactivity).state;
    } else {
      reactivity_state = id(up_reactivity).state;
    }

    double delta = -1 * (real_power_state - target_grid_exchange_state) *
                   reactivity_state / 1000;

    // Determine the new regulator status
    double new_router_level = id(router_level).state + delta;
    new_router_level = std::max(0.0, std::min(100.0, new_router_level));
    id(router_level).publish_state(new_router_level);

    if (new_router_level >= 100.0) {
      if (isnan(id(bypass_tempo_counter).state)) {
        id(bypass_tempo_counter).publish_state(id(full_power_duration).state);
      } else {
        if (id(bypass_tempo_counter).state > 0) {
          id(bypass_tempo_counter)
              .publish_state(id(bypass_tempo_counter).state - 1);
        }
      }
    } else {
      id(bypass_tempo_counter).publish_state(NAN);
    }
  } else {
    // If automatic regulation is off, do not manage bypass tempo
    id(bypass_tempo_counter).publish_state(0);
  }

  if ((id(router_level).state >= 100.0) &&
      (id(bypass_tempo_counter).state == 0)) {
    id(energy_divertion).turn_on();
  } else {
    id(energy_divertion).turn_off();
    id(regulator_opening).publish_state(id(router_level).state);
  }
}
} // namespace engine_1dimmer_1bypass

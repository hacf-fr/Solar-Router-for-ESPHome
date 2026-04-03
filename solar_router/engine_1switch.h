#pragma once

#include "esphome.h"

namespace engine_1switch {
void energy_regulation() {
  if (isnan(id(real_power).state) or id(safety_limit)) {
    // If we can have information about grid exchange or if safety_limit is
    // active, do not divert any energy
    id(router_level).publish_state(0);
    return;
  }
  if (id(real_power).state < -id(start_power_level).state) {
    // Energy divertion is needed
    if (id(router_level).state >= 100) {
      // Energy divertion is already done
      id(start_tempo_counter).publish_state(NAN);
      return;
    }

    id(stop_tempo_counter).publish_state(NAN);
    if (isnan(id(start_tempo_counter).raw_state)) {
      id(start_tempo_counter).publish_state(id(start_tempo).state);
    }

    id(start_tempo_counter).publish_state(id(start_tempo_counter).state - 1);
    if (id(start_tempo_counter).state <= 0) {
      id(router_level).publish_state(100);
      id(start_tempo_counter).publish_state(NAN);
    }
    return;
  }
  if (id(real_power).state > -id(stop_power_level).state) {
    // If energy divertion need to be stopped
    if (id(router_level).state <= 0) {
      // Energy divertion is already stopped
      id(stop_tempo_counter).publish_state(NAN);
      return;
    }

    id(start_tempo_counter).publish_state(NAN);
    if (isnan(id(stop_tempo_counter).raw_state)) {
      id(stop_tempo_counter).publish_state(id(stop_tempo).state);
    }

    id(stop_tempo_counter).publish_state(id(stop_tempo_counter).state - 1);
    if (id(stop_tempo_counter).state <= 0) {
      id(router_level).publish_state(0);
      id(stop_tempo_counter).publish_state(NAN);
    }
    return;
  }

  id(start_tempo_counter).publish_state(NAN);
  id(stop_tempo_counter).publish_state(NAN);
}
} // namespace engine_1switch
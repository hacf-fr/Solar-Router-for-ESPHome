#pragma once

#include "esphome.h"

namespace jsy_mk_194t {
void energy_diverted_counter() {
  // Ensure that consumption is a valid float
  float consumption_state = id(consumption).state;

  // Check if consumption is greater than AP_Ch1 or is unknown
  if (consumption_state >= id(AP_Ch1).state || isnan(consumption_state)) {
    // Power diverted is consumed (or we don't know the consumption)
    id(power_divertion).publish_state(id(AP_Ch1).state);
  } else {
    // Power diverted is not consumed
    id(power_divertion).publish_state(0.0);
  }
}

void read_real_power(int power_sign) {
  float value = id(AP_Ch2).state;
  float direction = id(PD_Ch2).state;

  if (!isnan(value)) {
    // Apply direction from meter
    if (!isnan(direction) && direction == 1) {
      value = -value;
    }

    // Apply user-defined polarity (CT orientation)
    value *= power_sign;

    id(real_power).publish_state(value);
  } else {
    id(real_power).publish_state(NAN);
  }
}
}  // namespace jsy_mk_194t
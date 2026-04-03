#pragma once

#include "esphome.h"
#include <string>

namespace fronius {
void real_power_on_response(int status_code, const std::string &body) {
  if (status_code != 200) {
    ESP_LOGW("custom", "HTTP Request failed with status: %d", status_code);
    id(real_power).publish_state(NAN);
    return;
  }

  bool parse_success = json::parse_json(body, [](JsonObject root) -> bool {
    if (!root["Body"].is<JsonObject>()) {
      ESP_LOGW("custom", "Invalid JSON structure");
      return false;
    }

    id(real_power)
        .publish_state(
            root["Body"]["Data"]["0"]["PowerReal_P_Sum"].as<float>());
    return true;
  });

  if (!parse_success) {
    ESP_LOGW("custom", "JSON Parsing failed");
    id(real_power).publish_state(NAN);
  }
}

void real_power_on_error() {
  ESP_LOGW("custom", "HTTP Request failed or timeout occurred");
  id(real_power).publish_state(NAN);
}

void consumption_on_response(int status_code, const std::string &body) {
  if (status_code != 200) {
    ESP_LOGW("custom", "HTTP Request failed with status: %d", status_code);
    id(consumption).publish_state(NAN);
  } else {
    bool parse_success = json::parse_json(body, [](JsonObject root) -> bool {
      if (!root["Body"].is<JsonObject>()) {
        ESP_LOGW("custom", "Invalid JSON structure");
        id(consumption).publish_state(NAN);
        return false;
      }
      id(consumption)
          .publish_state(root["Body"]["Data"]["Site"]["P_Grid"].as<float>() +
                         root["Body"]["Data"]["Site"]["P_PV"].as<float>());
      return true;
    });

    if (!parse_success) {
      ESP_LOGW("custom", "JSON Parsing failed");
      id(consumption).publish_state(NAN);
    }
  }
}

void consumption_on_error() {
  ESP_LOGW("custom", "HTTP Request failed or timeout occurred");
  id(consumption).publish_state(NAN);
}
} // namespace fronius
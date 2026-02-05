#pragma once

#include "esphome.h"

namespace proxy_client {

void power_meter_source_real_power_on_response(int status_code,
                                               const std::string &body) {
  if (status_code != 200) {
    ESP_LOGW("custom", "HTTP Request failed with status: %d", status_code);
    id(real_power).publish_state(NAN);
  } else {
    bool parse_success = json::parse_json(body, [](JsonObject root) -> bool {
      if (!root["value"].is<JsonObject>()) {
        ESP_LOGW("custom", "Invalid JSON structure");
        return false;
      }
      id(real_power).publish_state(root["value"].as<float>());
      return true;
    });

    if (!parse_success) {
      ESP_LOGW("custom", "JSON Parsing failed");
      id(real_power).publish_state(NAN);
    }
  }
}
void power_meter_source_real_power_on_error() {
  ESP_LOGW("custom", "HTTP Request failed or timeout occurred");
  id(real_power).publish_state(NAN);
}
void power_meter_source_consumption_on_response(int status_code,
                                                const std::string &body) {
  if (status_code != 200) {
    ESP_LOGW("custom", "HTTP Request failed with status: %d", status_code);
    id(consumption).publish_state(NAN);
  } else {
    bool parse_success = json::parse_json(body, [](JsonObject root) -> bool {
      if (!root["value"].is<JsonObject>()) {
        ESP_LOGW("custom", "Invalid JSON structure");
        return false;
      }
      id(consumption).publish_state(root["value"].as<float>());
      return true;
    });

    if (!parse_success) {
      ESP_LOGW("custom", "JSON Parsing failed");
      id(consumption).publish_state(NAN);
    }
  }
}
void power_meter_source_consumption_on_error() {
  ESP_LOGW("custom", "HTTP Request failed or timeout occurred");
  id(consumption).publish_state(NAN);
}
} // namespace proxy_client

#pragma once

#include "esphome.h"

namespace scheduler_forced_run {
template<class S, class N> auto func1(S sntp, N hour, N min) {
  // We are between begin (included) and end (excluded) hour and minutes
  int beginTotalMinutes = id(hour).state * 60 + id(min).state;
  int endTotalMinutes = id(hour).state * 60 + id(min).state;
  int checkTotalMinutes = id(sntp).now().hour * 60 + id(sntp).now().minute;

  if (beginTotalMinutes <= endTotalMinutes) {
    return checkTotalMinutes >= beginTotalMinutes && checkTotalMinutes < endTotalMinutes;
  } else {
    return checkTotalMinutes >= beginTotalMinutes || checkTotalMinutes < endTotalMinutes;
  }
}
template<class S, class N, class T> auto func2(S sntp, N hour, N min, T threshold) {
  // End Hour and minutes are reached
  if (id(hour).state == id(sntp).now().hour && id(min).state == id(sntp).now().minute) {
    return true;
  }

  // Or we are between end hour and minutes and scheduler_checking_end_threshold
  // It's a failsafe to check that router have been activated even if we lost the moment of end hour and minutes
  int beginTotalMinutes = id(hour).state * 60 + id(min).state;
  int endTotalMinutes = beginTotalMinutes + id(threshold).state;
  int checkTotalMinutes = id(sntp).now().hour * 60 + id(sntp).now().minute;

  if (beginTotalMinutes <= endTotalMinutes) {
    return checkTotalMinutes >= beginTotalMinutes && checkTotalMinutes <= endTotalMinutes;
  } else {
    return checkTotalMinutes >= beginTotalMinutes || checkTotalMinutes <= endTotalMinutes;
  }
}
}  // namespace scheduler_forced_run
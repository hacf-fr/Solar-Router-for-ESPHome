# Scheduler Forced Run

The *scheduler forced run* is designed to automate solar router shutdown and forced run at a certain load power.

Examples of use:

- Enable forced run of load during off-peak hours (Router Level=100%)
- Deactivate the router and switch off the load to make room for other uses (Router Level=0%).

This *scheduler* exposes controls for customizing automation to your needs from the HomeAssistant interface.

![HA](images/SchedulerForcedRunInHomeAssistant.png){ align=left }
!!! note ""
    **Controls**
    
    * ***Activate scheduler*** 
        Controls whether the scheduler should be activated or not.
        This allows you to deactivate the scheduler according to your own criteria (e.g. if your water heater has already had enough power during the day, there's no need to force it to run at night).
    * ***Begin Hour*** 
        From 0:00 to 23:00. Time at which forced operation starts.
    * ***Begin Minute*** 
        From 0 minutes to 55 minutes, in 5-minute steps.
      If the start time is 1h and the minutes are 15 minutes, then forced operation starts at 1h15.
    * ***Checking End Threshold*** 
        From 0 minutes to 720 minutes, in 5-minute steps.
        This option lets you define a safety margin to check every 5 minutes between the end of the schedule + X minutes that the router has returned to operation.
        For example, if the end time is set to 2:00 and the verification threshold to 60 minutes, every 5 minutes between 2:00 and 3:00 (inclusive) the scheduler will restart the solar router if it is stopped.
        This ensures that the schedule ends even if the ESP crashes at the end time.
    * ***End Hour*** 
        From 0:00 to 23:00. Time at which forced operation stops.
    * ***End Minute*** 
        From 0 minutes to 55 minutes, in 5-minute steps.
        If the end time is 1h and the minutes are 15 minutes, then the forced walk schedule ends at 1h15.
    * ***Router level*** 
        From 0% to 100% in 1% steps.
        Defines the target level at which the router will be set while the scheduler is running between the start and end times.


## Simple Configuration

To use more than one of these packages, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  scheduler_forced_run:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/scheduler_forced_run.yaml
```

## Multiple Configuration

If you want to use several instances of this package, for example to program one forced operation during the day and another at night, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  scheduler_forced_run:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/scheduler_forced_run.yaml
        vars:
          scheduler_unique_id: "NightForced"
      - path: solar_router/scheduler_forced_run.yaml
        vars:
          scheduler_unique_id: "DayForced"
```

It is necessary to define `scheduler_unique_id` in the `vars` section, as shown in the example above. This variable must not contain spaces or special characters, and must be unique for each *scheduler forced run*. It allows you to have as many instances as you need without any conflicts.

## Advanced Configuration (script)


This package provides the option of calling a custom script every 5 minutes during schedule execution.

For example, to stop scheduling before the end time if a temperature sensor reaches a target value, add the following lines to your configuration file:

```yaml linenums="1"
packages:
  scheduler_forced_run:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome/
    files:
      - path: solar_router/scheduler_forced_run.yaml
        vars:
          scheduler_unique_id: "NightForced"
          custom_script: check_temperature_for_NightForcedScheduler
          
script:
  # ...
  - id: check_temperature_for_NightForcedScheduler
    mode: single
    then:
        -if:
            condition:
                - lambda: return id(myTemperatureSensor).state >= 80;
            then:
                # Name of the switch is different for every scheduler, it depend of the scheduler_unique_id (default value: forced) : "${scheduler_unique_id}_scheduler_activate"
                - switch.turn_off: NightForced_scheduler_activate
```

It is necessary to define `custom_script` in the `vars` section, as shown in the example above. This variable is used to pass the name of the script that will be called every 5 minutes when the scheduler is run.
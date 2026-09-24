# Scheduler

## Description

A *scheduler* runs automation directly on ESPHome so the solar router remains robust even if the connection to Home Assistant is lost.

Each *scheduler* exposes controls so you can customize the automation from the Home Assistant interface.

### Available schedulers

| Scheduler | Use case |
| --- | --- |
| [`scheduler_forced_run`](scheduler_forced_run.md) | Force the load on or off during a configured time window (e.g. off-peak hours). |

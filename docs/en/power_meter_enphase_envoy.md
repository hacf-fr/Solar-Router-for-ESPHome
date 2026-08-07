# Power Meter - Enphase Envoy

This power meter reads the grid import/export power from an Enphase Envoy gateway using the local HTTP API. It is compatible with older Envoy and Envoy-S devices that do not require token-based authentication.

## Requirements

- **IP Address or Hostname**: The IP address or hostname of the Envoy gateway (e.g., `192.168.1.50` or `envoy.local`).

## Configuration

To use this power meter, include the following in your main YAML file:

```yaml
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome
    refresh: 1d
    files:
      - path: solar_router/common.yaml
      - path: solar_router/power_meter_enphase_envoy.yaml
        vars:
          power_meter_ip_address: "192.168.1.50"
```

## API Details

- **Endpoint**: `GET http://<envoy>/production.json`
- **Measurement**: The `net-consumption` measurement (`consumption[1].wNow`) represents the power exchanged with the grid:
  - **Positive value**: Energy is drawn from the grid.
  - **Negative value**: Energy is pushed to the grid (solar surplus).

## Notes

- This power meter is designed for Enphase Envoy devices running firmware versions older than 7.x.
- No authentication is required for this configuration.

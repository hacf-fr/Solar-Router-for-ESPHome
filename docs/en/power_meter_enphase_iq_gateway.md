# Power Meter - Enphase IQ Gateway

This power meter reads the grid import/export power from an Enphase IQ Gateway using the local HTTPS API with token-based authentication. It is required for all modern Enphase IQ Gateways (formerly "Envoy") running firmware 7.x and above.

## Requirements

- **IP Address or Hostname**: The IP address or hostname of the IQ Gateway (e.g., `192.168.1.50` or `envoy.local`).
- **JWT Token**: A JWT token used to authenticate with the IQ Gateway.

## Obtaining the JWT Token

To obtain the JWT token:

1. Log in to [https://enlighten.enphaseenergy.com](https://enlighten.enphaseenergy.com).
2. Navigate to your system, then open your browser developer tools (F12).
3. Go to **Application → Cookies** and copy the value of `enlighten-4-token`.

Alternatively, use the community tool: [https://entrez.enphaseenergy.com](https://entrez.enphaseenergy.com) (generates a local-access token).

**Note**: Tokens are valid for 1 year. Renew when expired.

## Configuration

To use this power meter, include the following in your main YAML file:

```yaml
packages:
  solar_router:
    url: https://github.com/hacf-fr/Solar-Router-for-ESPHome
    refresh: 1d
    files:
      - path: solar_router/common.yaml
      - path: solar_router/power_meter_enphase_iq_gateway.yaml
        vars:
          power_meter_ip_address: "192.168.1.50"
          enphase_token: "eyJhbGciOi..."
```

## API Details

- **Endpoint**: `GET https://<gateway>/production.json`
- **Authentication**: JWT Bearer token sent in the `Authorization` header.
- **SSL Verification**: Disabled (IQ Gateway uses a self-signed certificate).
- **Measurement**: The `net-consumption` measurement (`consumption[1].wNow`) represents the power exchanged with the grid:
  - **Positive value**: Energy is drawn from the grid.
  - **Negative value**: Energy is pushed to the grid (solar surplus).

## Notes

- This power meter is designed for Enphase IQ Gateways running firmware 7.x and above.
- SSL verification is disabled due to the use of a self-signed certificate by the IQ Gateway.

# Security

- Never commit `deploy/.env` or provider API keys.
- Pin an exact Honcho image tag for deployments.
- Keep PostgreSQL and Redis unexposed; this Compose file publishes only the Honcho API.
- Bind the API to a trusted LAN address or place it behind an authenticated reverse proxy before wider exposure.
- `AUTH_USE_AUTH=false` is suitable only for trusted networks.
- Treat backups as sensitive because they contain conversation and memory data.

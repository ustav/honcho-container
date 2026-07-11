# Synology deployment

## Recommended layout

```text
/volume2/docker/honcho/
├── postgres/
├── redis/
├── backups/
└── logs/
```

Keep the repository/project files separately, for example:

```text
/volume2/docker-projects/honcho-container/deploy/
```

This prevents repository updates from touching application data.

## Container Manager

1. Copy `deploy/.env.example` to `deploy/.env`.
2. Set `HONCHO_IMAGE`, `DATA_ROOT`, a strong database password, and LLM keys.
3. Run `scripts/init-directories.sh` once, or create the directories manually.
4. In **Container Manager → Project → Create**, select `deploy/compose.yml`.
5. Build/start the project. The NAS pulls the prebuilt GHCR image; it does not compile Honcho.

## Private GHCR package

For a private package, authenticate Docker on the NAS with a GitHub Personal Access Token that has `read:packages`. A public package can be pulled without registry credentials.

## Backups

Schedule `scripts/backup.sh daily` in DSM Task Scheduler. Run it as a user allowed to access Docker and the backup directory.

Suggested schedule: daily before Hyper Backup. Include `${DATA_ROOT}/backups` and the deployment `.env` in Hyper Backup. The `.env` contains secrets, so protect backup encryption and access.

Do not rely solely on copying the live PostgreSQL directory. The documented portable restore path uses the `.dump` files.

# Honcho Container

Community build and deployment package for self-hosting [Honcho](https://github.com/plastic-labs/honcho), with a focus on repeatable GitHub builds, Synology Container Manager, persistent data, backups, and controlled upgrades.

> This is an independent project, not an official Plastic Labs image.

## What this repository provides

- GitHub Actions build from an exact upstream Honcho tag or commit
- Multi-architecture publication to GitHub Container Registry (GHCR)
- Versioned and commit-addressable image tags
- Docker Compose stack for API, deriver, PostgreSQL/pgvector, and Redis
- Persistent data outside the application image
- Verified PostgreSQL backups and destructive restore protection
- Controlled update workflow with a pre-upgrade backup

## Design principles

1. The application image is disposable.
2. PostgreSQL is the authoritative persistent store.
3. An upgrade never replaces the database directory.
4. Deployments pin a specific image tag, never only `latest`.
5. Database backups are created before upgrades.
6. Builds use the official upstream Dockerfile without maintaining a Honcho fork.

## 1. Create your GitHub repository

Create a repository such as `honcho-container`, then upload all files from this package and commit them.

Recommended visibility:

- **Public** when you want others to pull the image easily and inspect its build source.
- **Private** for initial experimentation; the NAS then needs GHCR authentication.

## 2. Build an image

Open **Actions → Build Honcho image → Run workflow**.

Enter an upstream Honcho release tag or, preferably, an exact commit SHA. `main` is included only for initial testing and is not reproducible over time.

The workflow publishes:

```text
ghcr.io/<your-github-user>/honcho:<upstream-ref>
ghcr.io/<your-github-user>/honcho:sha-<upstream-commit>
```

Use the `sha-...` tag for the strongest reproducibility.

After the first build, open the package settings and make the package public if you intend to share it.

## 3. Configure deployment

```bash
cp deploy/.env.example deploy/.env
```

Edit at least:

```env
HONCHO_IMAGE=ghcr.io/your-user/honcho:sha-0123456789ab
DATA_ROOT=/volume2/docker/honcho
POSTGRES_PASSWORD=long-random-password
LLM_GEMINI_API_KEY=...
```

Use only the LLM keys required by your Honcho configuration. For advanced model settings, consult the `.env.template` from the exact upstream version you built; Honcho's configuration evolves.

## 4. Start

```bash
./scripts/init-directories.sh
docker compose --env-file deploy/.env -f deploy/compose.yml up -d
./scripts/status.sh
```

The API is available at `http://<host>:8000` by default. PostgreSQL and Redis are internal only.

For DSM instructions, see [docs/SYNOLOGY.md](docs/SYNOLOGY.md).

## Back up

```bash
./scripts/backup.sh daily
```

The script creates a PostgreSQL custom-format dump, verifies it with `pg_restore --list`, and deletes daily dumps older than `RETENTION_DAYS` (default 30).

Pre-upgrade backups are not automatically expired:

```bash
./scripts/backup.sh pre-upgrade
```

## Update

1. Build the new upstream version in GitHub Actions.
2. Change `HONCHO_IMAGE` in `deploy/.env` to the exact new tag.
3. Run:

```bash
./scripts/update.sh
```

The script creates a pre-upgrade dump, pulls the new image, recreates services, and waits for API health.

Image rollback is simple, but database schema rollback may not be. Keep the pre-upgrade dump until the new version has been validated.

## Restore

First create a current backup when possible. Then:

```bash
CONFIRM_RESTORE=YES ./scripts/restore.sh /volume2/docker/honcho/backups/pre-upgrade/file.dump
```

Restore is deliberately destructive and requires explicit confirmation.

## Sharing and licensing

Honcho is AGPL-3.0. Images built by this repository contain Honcho and must preserve the upstream license obligations. The workflow labels images with the upstream repository and exact source revision. Review [NOTICE.md](NOTICE.md) before publishing.

## Initial limitations

- Automated unattended upgrades are intentionally excluded.
- The workflow does not automatically discover or approve upstream releases.
- Restore testing against every upstream release is not yet automated.
- `main` builds are convenient but should not be treated as stable releases.

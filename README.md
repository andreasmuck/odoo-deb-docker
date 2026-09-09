# Dockerized Odoo from official .deb packages

This project builds a local Docker image from **any compatible Odoo `.deb`** you place in `./deb/`. 

It is a personal project I use to quickly spin up Odoo test installations. It is not meant for production use. Different ports and project names can be used to install different versions side by side.

This repo does not distribute Odoo or Odoo Enterprise. Obtain the appropriate `.deb` package directly from Odoo. Odoo Enterprise requires a valid Odoo Enterprise subscription.

It has been tested with Odoo 18 and Odoo 19, both Community and Enterprise editions.

## Files

```text
.
├── Dockerfile
├── compose.yml
├── .env.example
├── .dockerignore
├── config/
│   └── odoo.conf
└── deb/
    └── <your Odoo .deb>
```

## Basic usage

1. Copy your Odoo `.deb` into `deb/`.

2. Create `.env`:

```bash
cp .env.example .env
```

3. Edit `.env`, for example:

```env
COMPOSE_PROJECT_NAME=odoo18e
ODOO_DEB=odoo_18.0+e.latest_all.deb
ODOO_VERSION=18
ODOO_PORT=8069
```

4. Build:

```bash
docker compose build
```

5. Start:

```bash
docker compose up -d
```

6. Watch logs:

```bash
docker compose logs -f odoo
```

7. Open:

```text
http://localhost:8069
```

The database manager is:

```text
http://localhost:8069/web/database/manager
```

## Alternative port

Set:

```env
ODOO_PORT=8079
```

Then open:

```text
http://localhost:8079
```

The container still listens internally on port 8069, only the host port changes.

## Running Odoo 18 and 19 side by side

The easiest method is to use **two copies of this project**, or two environment files with different Compose project names.

Example Odoo 18:

```env
COMPOSE_PROJECT_NAME=odoo18-test
ODOO_DEB=odoo_18.0+e.latest_all.deb
ODOO_VERSION=18
ODOO_PORT=8069
```

Example Odoo 19:

```env
COMPOSE_PROJECT_NAME=odoo19-test
ODOO_DEB=odoo_19.0+e.latest_all.deb
ODOO_VERSION=19
ODOO_PORT=8079
```

Start each from its own project directory:

```bash
docker compose up -d
```

Because `COMPOSE_PROJECT_NAME` differs, Docker automatically creates separate project-scoped resources such as:

```text
odoo18-test_postgres-data
odoo18-test_odoo-filestore

odoo19-test_postgres-data
odoo19-test_odoo-filestore
```

So Odoo 18 and 19 do not share PostgreSQL data or filestore contents.

## Persistence

Stopping/removing containers does not delete data:

```bash
docker compose down
```

Persistent data remains in:

```text
postgres-data
odoo-filestore
odoo-config
```

scoped by the Compose project name.

The `odoo-config` volume is initialized from `config/odoo.conf` when first created. Later changes to the repository copy of `config/odoo.conf` do not overwrite an existing persistent configuration volume.

## Updating Odoo

To update Odoo within the same major version, download a newer `.deb` package and place it in `deb/`.

Update the corresponding `.env` file, for example:

```env
COMPOSE_PROJECT_NAME=odoo18-test
ODOO_DEB=odoo_18.0+e.20260920_all.deb
ODOO_VERSION=18-20260920
ODOO_PORT=8069
```

Keep `COMPOSE_PROJECT_NAME` unchanged. It identifies the Docker Compose environment and therefore preserves the existing PostgreSQL, filestore, and Odoo configuration volumes.

Rebuild the Odoo image:

```bash
docker compose build --no-cache
```

Then recreate/start the containers:

```bash
docker compose up -d
```

The application image is replaced, while the persistent volumes remain intact.

Do not use:

```bash
docker compose down -v
```

during an update, because `-v` removes the persistent volumes.

Changing to a new Odoo major version, such as Odoo 18 to Odoo 19, requires a database upgrade. Do not start a newer major Odoo version directly against an older-version database.

## Destructive reset

This deletes the PostgreSQL database, Odoo filestore, and persistent Odoo configuration for the current Compose project:

```bash
docker compose down -v
```

Use it only when you intentionally want a completely fresh environment.

## Restore an Odoo Online backup

Open:

```text
http://localhost:${ODOO_PORT}/web/database/manager
```

Choose **Restore Database**, upload the Odoo Online ZIP as-is, give it a test database name, and enable **Neutralize**.

Do not point a newer major Odoo version directly at an older-version database. Upgrade the database first.

## Useful commands

PostgreSQL shell:

```bash
docker compose exec db psql -U odoo -d postgres
```

List databases:

```bash
docker compose exec db psql -U odoo -d postgres -c '\l'
```

Enter the Odoo container:

```bash
docker compose exec odoo bash
```

Enter the Odoo shell:

```bash
docker compose exec odoo odoo shell -c /etc/odoo/odoo.conf -d your_database
```

Reset all users passwords for testing:


```python
cat scripts/reset_passwords.py | docker compose exec -T odoo odoo shell -c /etc/odoo/odoo.conf -d your_database
```

Inspect installed Odoo package:

```bash
docker compose exec odoo dpkg -l | grep odoo
```

Check Odoo executable:

```bash
docker compose exec odoo sh -c 'ls -l /usr/bin/odoo*'
```

## Notes

- PostgreSQL runs in Docker too.
- PostgreSQL is not published to the host.
- The default PostgreSQL password is intentionally simple because PostgreSQL is not published outside the private Docker Compose network. If you expose the database service or use this setup as the basis for a hardened deployment, change the PostgreSQL password and the corresponding `db_password` in `odoo.conf`.
- Odoo is exposed only on `127.0.0.1`.
- Do not deploy this configuration unchanged to production.
- Odoo is a trademark of Odoo S.A. This project is independent and is not affiliated with or endorsed by Odoo S.A.

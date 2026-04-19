# Kordbooks ERP

Kordbooks ERP is a custom bookkeeping app built on the Frappe Framework and ERPNext for a UK accountancy practice and its small-business clients.

The goal is to reuse ERPNext’s accounting engine while delivering a simpler Kordbooks-specific user experience, workflows, branding, and UK-focused bookkeeping features.

Client portal is the SPA for clients which will have basic functionality for clients. 


## Purpose

This app is intended for UK small limited companies managed by an accountancy practice, including sectors such as:

- Hospitality
- Trades
- Property SPVs
- Other service-based small businesses

## Architecture

- Multi-tenant deployment: each client runs on its own Frappe site for logical data separation.
- Runtime stack: Frappe + ERPNext + `kordbooks_erp`
- Hosting model: Docker-based deployment on DigitalOcean
- Database: MariaDB, with persistent data stored in Docker volumes rather than in Git

## Development Principles

To reduce upgrade risk and keep the app maintainable, follow these rules:

1. Do not modify code inside the `frappe` or `erpnext` apps. All custom code should live in `kordbooks_erp`.
2. Do not edit core database schema directly.
3. Extend standard DocTypes using Custom Fields where appropriate.
4. Export Custom Fields and other supported customizations as Fixtures so they are version-controlled in the app repository.
5. Prefer Hooks for server-side extension.
6. Prefer Client Scripts or bundled frontend assets for browser-side behavior.
7. Pin Frappe, ERPNext, and custom app versions in Docker build and deployment configuration so production builds are reproducible.

## Developer Mode

Developer mode should be enabled on the development site when creating standard records such as:

- DocTypes
- Reports
- Pages
- Workspaces
- Print Formats
- Other app-owned artifacts that need to write JSON files into the app repository

Developer mode is a site-level setting in `site_config.json`.

Example:

```json
{
  "developer_mode": 1
}
```

Typical path:

```text
frappe-bench/sites/development.localhost/site_config.json
```

## Local Development

The app is developed inside a Frappe bench created in the Docker-based development environment.

Start the local development server with:

```bash
cd /workspace/development/frappe-bench
bench start
```

Custom app code lives in:

```text
/workspace/development/frappe-bench/apps/kordbooks_erp
```

## Installation on a Bench

To install this app on a bench from GitHub:

```bash
cd $PATH_TO_YOUR_BENCH
bench get-app https://github.com/pnumerus/kordbooks-erp.git --branch main
bench --site <site_name> install-app kordbooks_erp
```

Example:

```bash
cd /home/frappe/frappe-bench
bench get-app https://github.com/pnumerus/kordbooks-erp.git --branch main
bench --site development.localhost install-app kordbooks_erp
```

## Fixtures

When using Custom Fields, Property Setters, Client Scripts, or other supported customizations that should persist across environments, export them as Fixtures from the app so they can be committed to Git and deployed consistently.

Example `hooks.py` entry:

```python
fixtures = ["Custom Field", "Property Setter", "Client Script"]
```

Then export fixtures with:

```bash
bench --site development.localhost export-fixtures
```

This will create a `fixtures` folder inside the app.

## Production Packaging

For production, this app should be added to the Frappe Docker custom image build using `apps.json` so the final image contains:

- Frappe
- ERPNext
- `kordbooks_erp`

Example `apps.json` structure:

```json
[
  {
    "url": "https://github.com/frappe/erpnext",
    "branch": "version-16"
  },
  {
    "url": "https://github.com/pnumerus/kordbooks-erp.git",
    "branch": "main"
  }
]
```

## Upgrade Strategy

The app is intended to survive framework and ERP upgrades by:

- avoiding core code edits
- keeping customizations inside the custom app
- using fixtures for reproducible metadata
- using pinned, reproducible Docker image builds

## Git Strategy

Use separate repositories for:

1. The development/deployment environment
2. The custom app code

The main business logic should live in the custom app repository:

```text
apps/kordbooks_erp
```

Push custom app changes from that folder.

### Contributing

This app uses `pre-commit` for code formatting and linting. Please [install pre-commit](https://pre-commit.com/#installation) and enable it for this repository:

```bash
cd apps/kordbooks_erp
pre-commit install
```

Pre-commit is configured to use the following tools for checking and formatting your code:

- ruff
- eslint
- prettier
- pyupgrade

### github - run from the kordbooks_erp folder for the custom app

cd /workspace/development/frappe-bench

cd /workspace/development/frappe-bench/apps/kordbooks_erp

git status
git add .
git commit -m "xxx"
git push

## custom pages

Use website pages (kordbooks_erp/www) for client pages and desk pages (kordbooks_erp/page) for staff pages

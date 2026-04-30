# Kordbooks ERP

Kordbooks ERP is a custom bookkeeping app built on the Frappe Framework and ERPNext for a UK accountancy practice and its small-business clients.

The goal is to reuse ERPNext’s accounting engine while delivering a simpler Kordbooks-specific user experience, workflows, branding, and UK-focused bookkeeping features.

Client portal is the SPA for clients which will have basic functionality for clients.

For accountancy practice, they will continue to use desk but will have custom desk pages

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

When using Custom Fields (such as needed to add additional columns to existing doctype mariaDB database), Property Setters, Client Scripts, or other supported customizations that should persist across environments, export them as Fixtures from the app so they can be committed to Git and deployed consistently. 

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

### to run the frontend client_portal

cd /workspace/development/frappe-bench/apps/kordbooks_erp/client_portal

pnpm dev

### to run the backend kordbooks_erp (this includes the open source ERPnext frappe as well)


cd /workspace/development/frappe-bench

bench start

bench --site development.localhost migrate
bench --site development.localhost clear-cache


bench --site development.localhost list-apps
bench --site development.localhost console


http://development.localhost:8000
Username: Administrator
pw: admin


## custom pages

Use spa for client portal and desk pages (kordbooks_erp/page) for staff pages

Build custom Desk pages for practice staff that provide a simpler, lighter workflow than the standard ERPNext interface, while continuing to use standard ERPNext DocTypes as the underlying data model and extending them through Custom Fields, Property Setters, Client Scripts, and other Frappe-supported customizations rather than modifying core code.

### Folder roles

- `apps/kordbooks_erp/`  
  The root folder of the custom app repository. It contains the app’s source package, the client portal frontend, project config files, package files, and the main README. This is the main project folder that is committed to Git. 

- `apps/kordbooks_erp/client_portal/`  
  The frontend SPA for the client portal (clients of the accountancy practice). This folder contains the Vue/Vite application, including views, components, routing, styles, and frontend build configuration. It is mainly for browser-side UI code, while backend and business logic should live in the Frappe app package.

- `apps/kordbooks_erp/kordbooks_erp/`  
  The main Python package for the Frappe app. This is where app-level backend code and configuration live, including `hooks.py`, `modules.txt`, `public`, `templates`, and `www`. 

- `apps/kordbooks_erp/kordbooks_erp/kordbooks_practice/`  
  The Frappe module folder for the `Kordbooks Practice` module which is mainly focused for the accountancy practice. This is where module-specific business features should live, such as custom Desk pages, DocTypes, reports, and other code grouped under that module. 


  ### Bookkeeping process

  It will be a Bank-statement-led accrual bookkeeping workflow, so payments vouchers and entries will be created based on the bank transactions. 

  in ERPnext, what is the process for Bank-statement-led accrual bookkeeping workflow? Provide me step by step and what doctypes need to be used for each step
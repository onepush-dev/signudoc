# SignuDoc on Railway

[SignuDoc](https://github.com/NYLLON-SOFTWARE/SignuDoc) (MIT) — a self-hosted, open-source DocuSign alternative: upload a PDF, add signers and fields, send, collect signatures and get a sealed PDF with an audit trail. Deploy it on Railway with one click.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/VYzQLS)

## What this template runs

- **signudoc**: `ghcr.io/onepush-dev/signudoc:0.5.2`, upstream `NYLLON-SOFTWARE/SignuDoc` built from source at commit `24ecc5d` (code unmodified). It listens on 8080, applies database migrations on every boot, stores PDFs on a volume at `/data` and calls the daily retention cleanup (`/api/internal/retention`) from inside the container.
- **postgres**: `postgres:17-alpine` with a volume, private network only.

## Variables

| Service | Variable | Value | Notes |
|---|---|---|---|
| signudoc | `DATABASE_URL` | reference to postgres | Connection string built from the bundled Postgres. |
| signudoc | `APP_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public HTTPS address for links, auth callbacks and emails. |
| signudoc | `BETTER_AUTH_SECRET` | generated secret | Signs sessions and encrypts the seal key; keep it stable. |
| signudoc | `SETUP_TOKEN` | generated secret | The first-run setup page asks for it so nobody else can claim the install. |
| signudoc | `RETENTION_JOB_SECRET` | generated secret | Closes the retention route to everyone but the in-container scheduler. |
| postgres | `POSTGRES_PASSWORD` | generated secret | Postgres superuser password. |

Optional (add yourself): `RESEND_API_KEY` to send signing emails, `RESEND_FROM_EMAIL`, `SUPPORT_EMAIL`. `EMAIL_DRIVER` is intentionally unset.

## How to use

1. Deploy, then open `https://<domain>/setup`. Enter the `SETUP_TOKEN` value from the signudoc variables, name your organization and create the first (administrator) account.
2. Upload a PDF, add signers and send it. Without `RESEND_API_KEY` emails are not delivered; add the key to enable them.

Not affiliated with SignuDoc.

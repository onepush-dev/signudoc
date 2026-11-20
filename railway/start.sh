#!/bin/sh
set -e
cd /app
mkdir -p "${STORAGE_LOCAL_DIR:-/data/storage}"

echo "[railway] applying database migrations"
n=0
until node db/migrate.mjs; do
  n=$((n+1))
  if [ "$n" -ge 20 ]; then echo "[railway] migrations failed"; exit 1; fi
  echo "[railway] database not ready, retry $n"; sleep 3
done

# Daily retention cleanup (drafts, expired links, reminders). The route is safe to call
# repeatedly (runs at most once an hour); we call it ~2 min after boot, then every 24 h.
(
  sleep 120
  while true; do
    curl -fsS -m 120 -X POST ${RETENTION_JOB_SECRET:+-H "Authorization: Bearer $RETENTION_JOB_SECRET"} "http://127.0.0.1:8080/api/internal/retention" >/dev/null 2>&1 \
      && echo "[railway] retention job ok" || echo "[railway] retention job failed"
    sleep 86400
  done
) &

(
  sleep 10
  for p in / /api/auth/ok /accessibility /login; do
    echo "[debug] $p -> $(curl -s -m 20 -o /dev/null -w '%{http_code} %{redirect_url}' -H 'Host: healthcheck.railway.app' http://127.0.0.1:8080$p) | via ipv6: $(curl -s -m 20 -o /dev/null -w '%{http_code}' 'http://[::1]:8080'$p)"
  done
) &
exec node node_modules/next/dist/bin/next start -p 8080 -H ::

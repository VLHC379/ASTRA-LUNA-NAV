#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

if [ ! -x .venv/bin/python ]; then
  if command -v python3 >/dev/null 2>&1; then
    python3 -m venv .venv
  else
    python -m venv .venv
  fi
  . .venv/bin/activate
  pip install --quiet --upgrade pip
  pip install --quiet -r requirements.txt
else
  . .venv/bin/activate
fi

if [ ! -f data/cache/catalog.json ]; then
  python scripts/fetch_data.py
  python -m lunanav.build --all
fi

python -m uvicorn lunanav.api:app --host 127.0.0.1 --port 8010 &
server=$!
ready=0
for i in $(seq 1 80); do
  if curl -fsS http://127.0.0.1:8010/api/health >/dev/null 2>&1; then ready=1; break; fi
  sleep 0.5
done
if [ "$ready" = "1" ]; then
  echo "LUNA NAV - http://127.0.0.1:8010"
  if command -v xdg-open >/dev/null 2>&1; then xdg-open http://127.0.0.1:8010 >/dev/null 2>&1 || true
  elif command -v open >/dev/null 2>&1; then open http://127.0.0.1:8010
  fi
else
  echo "Server did not answer on port 8010."
fi
wait $server

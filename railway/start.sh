#!/bin/bash
# Start Pinry on Railway: migrate, create the admin once, then nginx + gunicorn.
set -euo pipefail

PORT="${PORT:-8080}"
cd /pinry

mkdir -p /data/static/media

# nginx listens on $PORT and proxies /api and /admin to gunicorn on 127.0.0.1:8000.
sed "s/__PORT__/${PORT}/g" /etc/nginx/pinry-site.template > /etc/nginx/sites-enabled/default

python manage.py collectstatic --noinput -v 0
python manage.py migrate --noinput

# Create the admin account on first start only. Changing the variables later
# does not change an existing account: use the admin panel (/admin/) instead.
if [ -n "${PINRY_ADMIN_USERNAME:-}" ] && [ -n "${PINRY_ADMIN_PASSWORD:-}" ]; then
  python manage.py shell -c '
import os
from users.models import User
name = os.environ["PINRY_ADMIN_USERNAME"]
if User.objects.filter(username=name).exists():
    print("Pinry: admin account %r already exists, leaving it unchanged" % name)
else:
    User.objects.create_superuser(name, os.environ.get("PINRY_ADMIN_EMAIL", ""), os.environ["PINRY_ADMIN_PASSWORD"])
    print("Pinry: created admin account %r" % name)
'
else
  echo "Pinry: PINRY_ADMIN_USERNAME or PINRY_ADMIN_PASSWORD not set, no admin account created"
fi

chown -R www-data:www-data /data

nginx

exec gunicorn pinry.wsgi -b 127.0.0.1:8000 -w "${GUNICORN_WORKERS:-2}" \
  --capture-output --timeout 120 \
  --user www-data --group www-data \
  --env DJANGO_SETTINGS_MODULE=pinry.settings.docker

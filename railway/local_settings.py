# Pinry settings for Railway. Values come from environment variables, and
# everything that must persist (SQLite database, uploads, secret key) is in /data.
import os
import secrets


def _bool(name, default):
    value = os.environ.get(name)
    if value is None or value.strip() == "":
        return default
    return value.strip().lower() in ("1", "true", "yes", "on")


def _secret_key():
    key = os.environ.get("SECRET_KEY", "").strip()
    if key:
        return key
    path = "/data/production_secret_key.txt"
    if os.path.exists(path):
        with open(path) as fh:
            return fh.read().strip()
    key = secrets.token_urlsafe(50)
    with open(path, "w") as fh:
        fh.write(key)
    return key


STATIC_ROOT = "/data/static"
MEDIA_ROOT = os.path.join(STATIC_ROOT, "media")

SECRET_KEY = _secret_key()

DEBUG = False
TEMPLATE_DEBUG = DEBUG

ALLOWED_HOSTS = ["*"]

# Railway terminates TLS at its edge; nginx passes the original scheme on.
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": "/data/production.db",
    }
}

# Self sign-up is off by default; the admin account is created at first start.
ALLOW_NEW_REGISTRATIONS = _bool("PINRY_ALLOW_NEW_REGISTRATIONS", False)

# Whether visitors can see non-private pins without logging in.
PUBLIC = _bool("PINRY_PUBLIC", True)

# Delete image files when their pin is removed.
IMAGE_AUTO_DELETE = True

IMAGE_SIZES = {
    "thumbnail": {"size": [240, 0]},
    "standard": {"size": [600, 0]},
    "square": {"crop": True, "size": [125, 125]},
}

ENABLED_PLUGINS = [
    "pinry_plugins.batteries.plugin_example.Plugin",
]

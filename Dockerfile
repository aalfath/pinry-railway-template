# Pinry 2.1.13, the latest upstream release (official image, linux/amd64).
FROM getpinry/pinry:2.1.13@sha256:9a619749ec5246e04694adc479a135e654a7ac5f34c15d6d134d917a62b4889b

# Security fixes merged upstream after the 2.1.13 image was built
# (pinry/pinry#388: private pins of other users could be added to a board,
# and non-image content fetched from a URL was accepted). Files are taken
# unchanged from upstream commit 05476b1.
COPY patches/models.py /pinry/core/models.py
COPY patches/serializers.py /pinry/core/serializers.py

# Settings read from environment variables; all state lives in /data.
COPY railway/local_settings.py /pinry/pinry/settings/local_settings.py
COPY railway/nginx-site.conf /etc/nginx/pinry-site.template
COPY railway/start.sh /railway-start.sh
RUN chmod 755 /railway-start.sh && rm -f /etc/nginx/sites-enabled/default

ENV DJANGO_SETTINGS_MODULE=pinry.settings.docker \
    PORT=8080
EXPOSE 8080
VOLUME ["/data"]
CMD ["/railway-start.sh"]

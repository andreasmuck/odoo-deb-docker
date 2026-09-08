FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

ARG ODOO_DEB

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

COPY deb/${ODOO_DEB} /tmp/odoo.deb

RUN apt-get update \
    && (dpkg -i /tmp/odoo.deb || true) \
    && apt-get install -f -y \
    && apt-get install -y --no-install-recommends vim-tiny \
    && rm -f /tmp/odoo.deb \
    && rm -rf /var/lib/apt/lists/*

COPY config/odoo.conf /etc/odoo/odoo.conf

EXPOSE 8069

CMD ["/usr/bin/odoo", "-c", "/etc/odoo/odoo.conf"]

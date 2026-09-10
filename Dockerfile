FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

ARG ODOO_DEB

COPY deb/${ODOO_DEB} /tmp/odoo.deb

RUN apt-get update \
    && (dpkg -i /tmp/odoo.deb || true) \
    && apt-get install -f -y \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        postgresql-client \
        vim-tiny \
        python3-pip \
        wget \
        xfonts-75dpi \
        xfonts-base \
        libfontconfig1 \
        libfreetype6 \
        libx11-6 \
        libxext6 \
        libxrender1 \
        fonts-urw-base35 \
    && wget -O /tmp/wkhtmltox.deb \
        https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb \
    && apt-get install -y /tmp/wkhtmltox.deb \
    && pip3 install --break-system-packages \
        pdf417gen==0.7.1 \
        pdfminer.six \
    && rm -f /tmp/wkhtmltox.deb /tmp/odoo.deb \
    && rm -rf /var/lib/apt/lists/*

COPY config/odoo.conf /etc/odoo/odoo.conf

EXPOSE 8069

CMD ["/usr/bin/odoo", "-c", "/etc/odoo/odoo.conf"]

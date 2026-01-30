FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

    # Repo bullseye SOLO para libssl1.1
RUN echo "deb http://deb.debian.org/debian bullseye main" \
    > /etc/apt/sources.list.d/bullseye.list
# -----------------------------
# 1) Dependencias del sistema
# -----------------------------
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    build-essential \
    libxml2-dev \
    libxslt1-dev \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    libjpeg-dev \
    zlib1g-dev \
    libpq-dev \
    libffi-dev \
    libfreetype6 \
    libxrender1 \
    libxext6 \
    libfontconfig1 \
    git \
    curl \
    ca-certificates \
    postgresql-client \
    nano \
    wget \
    && wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb \
    && apt install -y ./wkhtmltox_0.12.6-1.buster_amd64.deb \
    && rm wkhtmltox_0.12.6-1.buster_amd64.deb \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# 2) Usuario odoo
# -----------------------------
RUN useradd -m -d /var/lib/odoo -U -r -s /bin/bash odoo

# -----------------------------
# 3) Directorios estándar
# -----------------------------
RUN mkdir -p \
    /var/lib/odoo \
    /mnt/extra-addons \
    /etc/odoo \
    /opt/odoo \
    && chown -R odoo:odoo \
       /var/lib/odoo \
       /mnt/extra-addons \
       /etc/odoo \
       /opt/odoo

# -----------------------------
# 4) Python deps (requirements)
# -----------------------------
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir --break-system-packages \
    -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt

# Copiar entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Variables DB (las usa el script)
ENV DB_HOST=db \
    DB_PORT=5432 \
    DB_USER=odoo \
    DB_PASSWORD=odoo

ENTRYPOINT ["/entrypoint.sh"]

# -----------------------------
# 5) Volúmenes
# -----------------------------
VOLUME ["/var/lib/odoo", "/mnt/extra-addons", "/etc/odoo", "/opt/odoo"]

# -----------------------------
# 6) Usuario final
# -----------------------------
USER odoo
WORKDIR /opt/odoo

# -----------------------------
# 7) Puerto
# -----------------------------
EXPOSE 8069

# -----------------------------
# 8) Comando de arranque
# -----------------------------
CMD ["python3", "/opt/odoo/odoo-bin", "-c", "/etc/odoo/odoo.conf"]

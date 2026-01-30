#!/bin/bash
set -e

DB_NAME="odoo"

echo "⏳ Esperando a PostgreSQL en $DB_HOST:$DB_PORT..."
export PGPASSWORD="$DB_PASSWORD"

until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER"; do
  sleep 2
done

echo "✅ PostgreSQL disponible"

echo "🔍 Verificando si la DB está inicializada..."

TABLE_EXISTS=$(psql \
  -h "$DB_HOST" \
  -p "$DB_PORT" \
  -U "$DB_USER" \
  -d "$DB_NAME" \
  -tAc "SELECT 1 FROM information_schema.tables WHERE table_name='ir_module_module';" || true)

if [ "$TABLE_EXISTS" != "1" ]; then
  echo "🚀 DB no inicializada → instalando base"

  python3 /opt/odoo/odoo-bin \
    -d "$DB_NAME" \
    -i base \
    --stop-after-init \
    --db_host="$DB_HOST" \
    --db_port="$DB_PORT" \
    --db_user="$DB_USER" \
    --db_password="$DB_PASSWORD"

else
  echo "✅ DB ya inicializada"
fi

echo "▶ Iniciando Odoo"
exec python3 /opt/odoo/odoo-bin -c /etc/odoo/odoo.conf

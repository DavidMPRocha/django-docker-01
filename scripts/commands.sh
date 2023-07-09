#!/bin/sh

# O shell irá encerrar a execução do script quando um comando falhar
set -e

# Fica esperado pelo Postgresql iniciar
while ! nc -z $POSTGRES_HOST $POSTGRES_PORT; do
  echo "🟡 Esperado que a Base de dados Postgres inicie ($POSTGRES_HOST $POSTGRES_PORT) ..."
  sleep 2
done

echo "✅ Base de dados Postgres iniciou com sucesso ($POSTGRES_HOST:$POSTGRES_PORT)"

# Apos Postgresql iniciar executa 
python manage.py collectstatic --noinput
python manage.py makemigrations --noinput
python manage.py migrate --noinput
# Iniciar server
python manage.py runserver 0.0.0.0:8000
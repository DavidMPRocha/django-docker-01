# Configuração de projeto Django Rest Framework com Docker
### Configurar .gitignore
https://djangowaves.com/tips-tricks/gitignore-for-a-django-project/
### Configurar .dockerignore 
https://github.com/edoburu/django-project-template/blob/master/.dockerignore
#### Iniciar configurações python

##### Criar ambiente de python e  Executar ambiente de pytho
python -m venv venv
venv\Scripts\activate
##### Instalar depedências
###### Atualizar pip antes de iniciar
pip install pip --upgrade
###### Intalar Django e DjangoFramwork
pip install django
pip install djangorestframework
###### Para dar suporte a codigo djangorestframework (We'll be using this for the code highlighting)
pip install pygments  

##### Criar pasta djangoapp (Esta é a pasta do projeto)
mkdir djangoapp

##### Setar localização de projeto 
cd djangoapp
django-admin startproject project .

##### Criar arquivo requirements.txt "Este arquivo serve para o docker saber tudo oque tem que instalar"
requirements.txt
###### Para saber o que colocar no requirements.txt usar pip freee
pip freeze
##### As 3 depedencias que foram instaladas
Django>=4.2.3,<4.3
djangorestframework>=3.14.0,<3.15
Pygments>=2.15.1,<2.16
// PostgresSQL
psycopg2-binary>=2.9.6,<2.10

#### Configurar .env
#### os ficheiros .env são criados dentro de uma pasta na raiz com o nome /dontenv_files, existe sem um .env-example este será o arquivo que será partilhado, e a partir deste cria-se o .env
/dotenv_files/
/.env-example
/.env

#### Exemplo do arquivo .env-example
```
SECRET_KEY="CHANGE-ME"

# 0 False, 1 True
DEBUG="1"

# Separados por virgulas
ALLOWED_HOSTS="127.0.0.1, localhost"

DB_ENGINE="django.db.backends.postgresql"
POSTGRES_DB="CHANGE-ME"
POSTGRES_USER="CHANGE-ME"
POSTGRES_PASSWORD="CHANGE-ME"
POSTGRES_HOST="psql"
POSTGRES_PORT="5432"
```

#### Agora o .env
#### Para gerarmos uma SECRET_KEY "A Secret_key do Django serve para encriptografar e desencriptografar alguns dados, que vamos usar na app, basicamente o objetivo é segurança", retirar aspas na string
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

#### DEBUG precisa de ser 1 quando é desenvolvimentp

#### ALLOWED_HOSTS como o nome indica, será os ips permmitidos a acessar a app

#### DB_ENGINE o engine de Base de Dados, que será o Postgresql
#### E por im as informações de conexão à DB
#### EXEMPLO .env
```
SECRET_KEY="a4djqf^2+3upx(cha5z+rgob*&vlvihr-wy=14i9%cbd&8^8w+"

# 0 False, 1 True
DEBUG="1"

# Separados por virgulas
ALLOWED_HOSTS="127.0.0.1, localhost"

DB_ENGINE="django.db.backends.postgresql"
POSTGRES_DB="uartronic"
POSTGRES_USER="root"
POSTGRES_PASSWORD="root"
POSTGRES_HOST="psql"
POSTGRES_PORT="5432"
```


### Implemtar as Variaveis de Ambiente no djangoapp/project/setthings.py
```
import os 
from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.getenv('SECRET_KEY')

DEBUG = bool(int(os.getenv('DEBUG', 0)))

ALLOWED_HOSTS = [
    h.strip() for h in os.getenv('ALLOWED_HOSTS', '').split(',')
    if h.strip()
]

DATABASES = {
    'default': {
        'ENGINE': os.getenv('DB_ENGINE', 'change-me'),
        'NAME': os.getenv('POSTGRES_DB', 'change-me'),
        'USER': os.getenv('POSTGRES_USER', 'change-me'),
        'PASSWORD': os.getenv('POSTGRES_PASSWORD', 'change-me'),
        'HOST': os.getenv('POSTGRES_HOST', 'change-me'),
        'PORT': os.getenv('POSTGRES_PORT', 'change-me'),
    }
}
```

#### Outras cofigurações
```
BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR.parent / 'data' / 'web'

LANGUAGE_CODE = 'pt-pt'

TIME_ZONE = 'Europe/Lisbon

# Arquivos estáticos /data/web/static
STATIC_URL = 'static/'
STATIC_ROOT = DATA_DIR / 'static'

# Arquivos media /data/web/media
MEDIA_URL = 'media/'
MEDIA_ROOT = DATA_DIR / 'media' 
```

#### Configuração em urls.py (para conseguir aceder a media)
```
from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path

urlpatterns = [
    path('admin/', admin.site.urls),
]

if settings.DEBUG:
    urlpatterns += static(
        settings.MEDIA_URL,
        document_root= settings.MEDIA_ROOT
    )

```

#### Configurar o ficheiros Dockerfile para Djangoapp na raiz, O Dockerfile "é para gerar um imagem ao nosso gosto"
```
# Versão a usar no container
FROM python:3.11-alpine3.18
LABEL matainer="davidmprocha@gmail.com"

# Esta variável de ambiente é usada para controlar se o python deve
# gravar arquivos bytecode (.pyc) no dico. 1 = Não, 0 = Sim
ENV PYTHONDONTWRITEBYTECODE 1

# Define que a saida do Python será exibida imidiatamente no console
# para ver os outputs do Python em tempo real
ENV PYTHONUNBUFFERED 1

# Dão as pastas que queremos copiar para o container
# Copia a pasta "djangoapp" e "scripts" para dentro do container
COPY djangoapp /djangoapp
COPY scripts /scripts

# Entra na pasta djangoapp no container "Para trabalhar com esta pasta"
WORKDIR /djangoapp

# Permitir que conexões externas acesses ao container, por exemplo a nossa máquina fisica
# Usar a porta 8000
EXPOSE 8000

# RUN executa comandos em um shell dentro do container para construir a imagem. 
# O resultado da execução do comando é armazenado no sistema de arquivos da 
# imagem como uma nova camada.
# Agrupar os comandos em um único RUN pode reduzir a quantidade de camadas da 
# imagem e torná-la mais eficiente.
RUN python -m venv /venv && \
  /venv/bin/pip install --upgrade pip && \
  /venv/bin/pip install -r /djangoapp/requirements.txt && \
  adduser --disabled-password --no-create-home duser && \
  mkdir -p /data/web/static && \
  mkdir -p /data/web/media && \
  chown -R duser:duser /venv && \
  chown -R duser:duser /data/web/static && \
  chown -R duser:duser /data/web/media && \
  chmod -R 755 /data/web/static && \
  chmod -R 755 /data/web/media && \
  chmod -R +x /scripts

# Adiciona a pasta scripts e venv/bin 
# no $PATH do container.
ENV PATH="/scripts:/venv/bin:$PATH"

# Muda o usuário para duser
USER duser

# Executa o arquivo scripts/commands.sh
CMD ["commands.sh"]
```

Criar commands.sh "Este ficheiro é executado depois do container Dockerfile ser executaado"

na raiz criar 
/scripts/commaands.sh

```
#!/bin/sh

# O shell irá encerrar a execução do script quando um comando falhar
set -e

# Fica esperado pelo Postgresql iniciar
while ! nc -z $POSTGRES_HOST $POSTGRES_PORT; do
  echo "🟡 Waiting for Postgres Database Startup ($POSTGRES_HOST $POSTGRES_PORT) ..."
  sleep 2
done

echo "✅ Postgres Database Started Successfully ($POSTGRES_HOST:$POSTGRES_PORT)"

# Apos Postgresql iniciar executa 
python manage.py collectstatic --noinput
python manage.py makemigrations --noinput
python manage.py migrate --noinput
# Iniciar server
python manage.py runserver 0.0.0.0:8000
```

#### Criar ficheiro docker-compose.yml na raiz "Mapear" "Quando forem alterados os ficheiros o docker automaticamente faz as alterações"
Vamos criar tambem o container para o Postgresql
Porque é que o container de Postgresql não tem um Dockerfile? Porque vamos usar já uma imagem precriada no docker images: postgres:13-alpine" "https://hub.docker.com/_/postgres"
```
version: '3.9'

services:
  djangoapp:
    container_name: djangoapp
    build:
      context: .
      dockerfile: ./Dockerfile
    ports:
      - 8000:8000
    volumes:
      - ./djangoapp:/djangoapp
      - ./data/web/static:/data/web/static/
      - ./data/web/media:/data/web/media/
    env_file:
      - ./dotenv_files/.env
    depends_on:
      - psql
  psql:
    container_name: psql
    image: postgres:13-alpine
    volumes:
      - ./data/postgres/data:/var/lib/postgresql/data/
    env_file:
      - ./dotenv_files/.env
```

####Finalmente criar as imagens no docker
docker-compose up --build
caso corra mal 
docker-compose up --build --force-recreate

so para ligar  "-d para naao ver logs"
docker-compose up -d

#### Por fim
127.0.0.1:8000

#### Agora vamos criar o projeto principal
venv\Scripts\activate
cd djangoapp
python manage.py startapp uartronic

#### Adicionar o projeto e o restframework ao INSTALLED_APPS no settings.py
INSTALLED_APPS = [
    ...
    'uartronic'
    'rest_framework',
]

#### Seguir os paços em https://www.django-rest-framework.org/#installation
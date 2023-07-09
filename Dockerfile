# O Dockerfile "é para gerar um imagem ao nosso gosto"
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
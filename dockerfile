FROM ghcr.io/linuxserver/baseimage-alpine:3.16

# Install build and runtime dependencies
RUN apk add --no-cache --upgrade --virtual=build-dependencies \
    cargo \
    gcc \
    git \
    jpeg-dev \
    libffi-dev \
    libxslt-dev \
    libxml2-dev \
    musl-dev \
    openssl-dev \
    postgresql-dev \
    python3-dev \
    zlib-dev && \
  apk add --no-cache --upgrade \
    tiff \
    postgresql-client \
    py3-setuptools \
    python3 \
    uwsgi \
    uwsgi-python \
    sshpass \
    nano \
    curl \
    jq

# Python3.10
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools

# Install pip packages
RUN python3 -m ensurepip && \
    rm -rf /usr/lib/python*/ensurepip && \
    pip3 install --no-cache-dir -U pip wheel pipenv \
    pipenv install

COPY requirements.txt /app/requirements.txt
RUN pip3 install -r /app/requirements.txt

# Créer le répertoire de travail
WORKDIR /app

# Clone TPDBCollectionMaker repository
RUN git clone https://github.com/PierreDurrr/TPDbCollectionMaker.git /app/TPDBCollectionMaker

# Copier le script Python et les autres fichiers nécessaires dans le conteneur
COPY script.py /app/script.py

# Installer le module watchdog
RUN pip3 install watchdog

# Définir le point d'entrée du conteneur
ENTRYPOINT ["python3", "/app/script.py"]

#RUN cd /app/TPDBCollectionMaker && pipenv install --system --deploy

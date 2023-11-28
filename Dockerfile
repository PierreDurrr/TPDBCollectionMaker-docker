# Set base image for running TCM
FROM python:3.11-slim
LABEL maintainer="PierreDurrr" \
      description="Docker version - Quickly make Plex-Meta-Manager poster entries from ThePosterDatabase sets"

# Créer le répertoire de travail
WORKDIR /app

# Install gcc for building python dependencies; install TPDBCollectionMaker dependencies
FROM python:3.11-slim
RUN apt-get update
RUN apt-get -y install gcc curl git

# Clone TPDBCollectionMaker repository
RUN git clone https://github.com/CollinHeist/TPDbCollectionMaker.git /app/TPDBCollectionMaker
RUN rm /app/TPDBCollectionMaker/Pipfile*

COPY requirements.txt /app/requirements.txt
RUN pip3 install --no-cache --upgrade pip setuptools

# Python3.x
ENV PYTHONUNBUFFERED=1
RUN ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools

# Install pip packages
RUN python3 -m ensurepip && \
    rm -rf /usr/lib/python*/ensurepip && \
    pip3 install --no-cache-dir -U pip wheel

RUN pip3 install -r /app/requirements.txt

# Copier le script Python et les autres fichiers nécessaires dans le conteneur
COPY script.py /app/script.py

# Installer le module watchdog
RUN pip3 install watchdog PyYAML
RUN pip install watchdog
WORKDIR /app

# FOLDER_PATH VARIABLE
ENV FOLDER_PATH /app/data

# Définir le point d'entrée du conteneur
ENTRYPOINT ["python3", "/app/script.py"]

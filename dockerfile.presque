# Create pipenv image to convert Pipfile to requirements.txt
FROM python:3.11-slim as pipenv

# Copy Pipfile and Pipfile.lock
COPY Pipfile Pipfile.lock ./
RUN PIPENV_VENV_IN_PROJECT=1 pipenv install --dev --system --deploy

# Install pipenv and convert to requirements.txt
RUN pip3 install --no-cache-dir --upgrade pipenv; \
    pipenv requirements > requirements.txt

FROM python:3.11-slim as python-reqs

# Install gcc for building python dependencies
RUN apt-get update \
RUN apt-get install software-properties-common \
RUN add-apt-repository ppa:ubuntu-toolchain-r/test \
RUN apt-get update \
RUN apt-get install -y gcc

# Set base image for running TPDBCollectionMaker
FROM python:3.11-slim
LABEL description="Quickly make Plex Meta Manager poster entries from ThePosterDatabase sets"

# Delete setup files
# Create user and group to run the container
# Clean up apt cache
RUN set -eux; \
    rm -f Pipfile Pipfile.lock; \
    groupadd -g 99 tpdbcollectionmaker; \
    useradd -u 100 -g 99 tpdbcollectionmaker; \
    apt-get update; \
    apt-get install -y --no-install-recommends nano curl pipenv gcc

# Set working directory, copy source into container
WORKDIR /app

# Copier le script watchdog et les autres fichiers nécessaires dans le conteneur
COPY watchdog-service.py /app/watchdog-service.py

# Copier le script Python et les autres fichiers nécessaires dans le conteneur
COPY main.py /app/main.py

# Installer le module watchdog
RUN pip3 install watchdog

# Définir le point d'entrée du conteneur
ENTRYPOINT ["python3", "/app/watchdog-service.py"]

# NEED pipenv shell

# Installer le module watchdog
RUN pip3 install watchdog

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
LABEL maintainer="PierreDurrr" \
      description="Quickly make Plex Meta Manager poster entries from ThePosterDatabase sets"

# Copy python packages from python-reqs
#COPY --from=python-reqs /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
#COPY /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Script environment variables
#ENV TCM_PREFERENCES=/config/preferences.yml \
#    TCM_IS_DOCKER=TRUE

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

FROM python:3.11-slim AS python-deps

# Install pipenv and compilation dependencies
RUN pip install pipenv
RUN apt-get update && apt-get install -y --no-install-recommends gcc

# Install python dependencies in /.venv
COPY Pipfile .
COPY Pipfile.lock .
RUN PIPENV_VENV_IN_PROJECT=1 pipenv install --deploy


FROM python:3.11-slim AS runtime

# Copy virtual env from python-deps stage
COPY --from=python-deps /.venv /.venv
ENV PATH="/.venv/bin:$PATH"


# Définir le point d'entrée du conteneur
ENTRYPOINT ["python3", "/app/watchdog-service.py"]

# Copy crontab file
COPY crontab /etc/crontabs/root

# Start cron daemon
CMD ["crond", "-f", "-l", "2"]

# Entrypoint
#CMD ["python3", "main.py", "--run", "--no-color"]
#ENTRYPOINT ["bash", "./start.sh"]

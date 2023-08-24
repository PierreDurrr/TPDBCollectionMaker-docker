# Create pipenv image to convert Pipfile to requirements.txt
FROM python:3.11-slim as pipenv

# Copy Pipfile and Pipfile.lock
COPY Pipfile Pipfile.lock ./

# Install pipenv and convert to requirements.txt
RUN pip3 install --no-cache-dir --upgrade pipenv; \
    pipenv requirements > requirements.txt

FROM python:3.11-slim as python-reqs

# Install gcc for building python dependencies
RUN sudo apt install software-properties-common; \
RUN sudo add-apt-repository ppa:ubuntu-toolchain-r/test; \
RUN apt-get update; \
RUN /bin/bash -c apt-get install -y gcc; \
#    apt-get install -y git; \

# Set base image for running TPDBCollectionMaker
FROM python:3.11-slim
LABEL maintainer="PierreDurrr" \
      description="Quickly make Plex Meta Manager poster entries from ThePosterDatabase sets"

# Set working directory, copy source into container
WORKDIR /app

# Copy python packages from python-reqs
#COPY --from=python-reqs /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Script environment variables
#ENV TCM_PREFERENCES=/config/preferences.yml \
#    TCM_IS_DOCKER=TRUE

# Delete setup files
# Create user and group to run the container
# Install imagemagick
# Clean up apt cache
# Override default ImageMagick policy XML file
RUN set -eux; \
    rm -f Pipfile Pipfile.lock; \
    groupadd -g 99 tpdbcollectionmaker; \
    useradd -u 100 -g 99 tpdbcollectionmaker; \
    apt-get update; \
    apt-get install -y --no-install-recommends nano; \

# Clone TPDBCollectionMaker repository
RUN git clone https://github.com/PierreDurrr/TPDbCollectionMaker.git /app/TPDBCollectionMaker

# Copier le script set-pipen.sh et les autres fichiers nécessaires dans le conteneur
COPY set-pipenv.py /app/set-pipenv.py

# Set executable permissions for scripts
#RUN chmod +x /app/set-pipenv.sh

# Installer le module watchdog
RUN pip3 install watchdog

# Définir le point d'entrée du conteneur
ENTRYPOINT ["python3", "/app/script.py"]
  
# Entrypoint
#CMD ["python3", "main.py", "--run", "--no-color"]
#ENTRYPOINT ["bash", "./start.sh"]

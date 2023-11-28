# Set base image for running TCM
FROM python:3.11-slim

LABEL maintainer="PierreDurrr" \
      description="Docker version - Quickly make Plex-Meta-Manager poster entries from ThePosterDatabase sets with Flask UI"

# Créer le répertoire de travail
WORKDIR /app

# Install required dependencies
RUN apt-get update && \
    apt-get -y install gcc curl git && \
    rm -rf /var/lib/apt/lists/*

# Clone TPDBCollectionMaker repository
RUN git clone https://github.com/CollinHeist/TPDbCollectionMaker.git /app/TPDBCollectionMaker
RUN rm /app/TPDBCollectionMaker/Pipfile*

# Copy requirements.txt and install pip packages
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Install Flask
RUN pip install flask requests

# Copy the updated script.py and app.py
COPY script.py /app/script.py
COPY app.py /app/app.py

# Create a folder for data and templates
RUN mkdir /app/data
RUN mkdir /app/templates

# Copy index.html to the templates folder
COPY templates/index.html /app/templates/index.html

# Expose the Flask port
EXPOSE 5000

# Set the folder path as an environment variable
ENV FOLDER_PATH /app/data

# Set the working directory
WORKDIR /app

# Define the command to run the application
CMD ["python", "app.py"]

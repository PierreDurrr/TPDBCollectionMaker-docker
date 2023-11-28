# Set base image for running TCM
FROM python:3.11-slim

LABEL maintainer="PierreDurrr" \
      description="Docker version - Quickly make Plex-Meta-Manager poster entries from ThePosterDatabase sets with Flask UI"

WORKDIR /app

RUN apt-get update && \
    apt-get -y install gcc curl git nano && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/CollinHeist/TPDbCollectionMaker.git /app/TPDBCollectionMaker
RUN rm /app/TPDBCollectionMaker/Pipfile*

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

RUN pip install flask requests watchdog

COPY script.py /app/script.py
COPY app.py /app/app.py

RUN mkdir /app/data
RUN mkdir /app/templates

COPY templates/index.html /app/templates/index.html

EXPOSE 5000

ENV FOLDER_PATH /app/data

WORKDIR /app

CMD python app.py & python /app/script.py

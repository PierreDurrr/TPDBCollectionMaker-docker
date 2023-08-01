#!/usr/bin/env python3

import os
import sys
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# Chemin du dossier à surveiller
folder_path = '/app/data'

# La commande à exécuter pour chaque nouveau fichier
#command_to_execute = "echo New file detected: {}"
command_to_execute = "pipenv run python /app/TPDBCollectionMaker/main.py /app/TPDBCollectionMaker/in.html --always-quote >> /app/TPDBCollectionMaker/mymetadatafile.yml"

class NewFileHandler(FileSystemEventHandler):
    def on_created(self, event):
        if event.is_directory:
            return

        file_path = event.src_path
        print(command_to_execute.format(file_path))
        # Insérer ici votre code pour exécuter la commande sur le fichier

if __name__ == '__main__':
    print("Monitoring folder for new files...")
    try:
        # Créer le dossier s'il n'existe pas
        os.makedirs(folder_path, exist_ok=True)

        # Créer l'objet watchdog pour surveiller les événements du dossier
        event_handler = NewFileHandler()
        observer = Observer()
        observer.schedule(event_handler, folder_path, recursive=False)
        observer.start()

        # Garder le script en cours d'exécution pour continuer à surveiller
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            observer.stop()
        observer.join()

    except KeyboardInterrupt:
        print("Monitoring stopped.")
        sys.exit(0)

import subprocess

# Commande à exécuter
command = "pipenv run python /app/TPDBCollectionMaker/main.py"

# Exécution de la commande
try:
    subprocess.run(command, shell=True, check=True, cwd="/app")
except subprocess.CalledProcessError as e:
    print(f"Une erreur s'est produite : {e}")

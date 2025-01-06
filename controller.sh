#!/bin/bash

# Afficher l'utilisation si aucun paramètre n'est fourni
usage() {
  echo "Usage: $0 -t <max_threads>"
  echo "  -t       Nombre maximum de threads (processus) simultanés"
  exit 1
}

# Valeur par défaut
MAX_THREADS=1
TIMEOUT_LIMIT=10  # Limite de timeout en secondes (30 minutes)
LOG_FILE="thread_kill.log"

# Lire les arguments de la ligne de commande
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -t)
      MAX_THREADS="$2"
      shift 2
      ;;
    *)
      echo "Option inconnue : $1"
      usage
      ;;
  esac
done

# Vérifier que le nombre de threads est fourni
if [[ -z "$MAX_THREADS" ]]; then
  echo "Erreur : Le nombre maximum de threads doit être spécifié avec -t."
  usage
fi

# Vérifier si ip.txt existe
if [[ ! -f "ip.txt" ]]; then
  echo "Erreur : Le fichier ip.txt n'existe pas dans le répertoire courant."
  exit 1
fi

# Fonction pour exécuter indexing.sh sur une adresse IP donnée
process_ip() {
  local ip="$1"
  echo "Démarrage de l'exploration pour $ip..."
  
  # Exécuter le script indexing.sh avec timeout de 30 minutes
  timeout "$TIMEOUT_LIMIT" ./indexing.sh -h "$ip" -p 21
  
  # Si le processus dépasse le temps limite, enregistrer dans le log
  if [[ $? -eq 124 ]]; then
    echo "$(date) - Le processus pour $ip a été tué après avoir dépassé la limite de $TIMEOUT_LIMIT secondes." >> "$LOG_FILE"
  fi
  
  echo "Exploration terminée pour $ip."
}

# Gestion des threads
THREADS=0
while read -r ip; do
  # Ignore les lignes vides
  if [[ -z "$ip" ]]; then
    continue
  fi

  # Démarrer un nouveau thread avec timeout
  process_ip "$ip" &

  # Incrémenter le compteur de threads
  ((THREADS++))

  # Si on atteint le nombre maximum de threads, attendre qu'ils se terminent
  if [[ "$THREADS" -ge "$MAX_THREADS" ]]; then
    wait -n  # Attendre qu'au moins un thread se termine
    ((THREADS--))  # Décrémenter le compteur de threads
  fi
done < ip.txt

# Attendre que tous les threads restants se terminent
wait

echo "Tous les travaux sont terminés."


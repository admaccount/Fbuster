#!/bin/bash

# Afficher l'utilisation si aucun paramètre n'est fourni
usage() {
  echo "Usage: $0 -h <IP> [-p <port>]"
  echo "  -h       Adresse IP du serveur FTP à explorer"
  echo "  -p       Port du serveur FTP (optionnel, défaut : 21)"
  exit 1
}

# Valeurs par défaut
PORT=21
IP=""
TIMEOUT=10  # Temps maximum en secondes pour la connexion

# Lire les arguments de la ligne de commande
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -h)
      IP="$2"
      shift 2
      ;;
    -p)
      PORT="$2"
      shift 2
      ;;
    *)
      echo "Option inconnue : $1"
      usage
      ;;
  esac
done

# Vérifier que l'IP est fournie
if [[ -z "$IP" ]]; then
  echo "Erreur : L'adresse IP doit être spécifiée avec -h."
  usage
fi

# Affiche les paramètres reçus
echo "Exploration du serveur FTP à l'adresse : $IP sur le port $PORT"

# Tester la connexion avant d'exécuter l'exploration
echo "Test de la connexion au serveur FTP..."
nc -z -w "$TIMEOUT" "$IP" "$PORT" 2>/dev/null
if [[ $? -ne 0 ]]; then
  echo "Impossible de se connecter à $IP:$PORT dans un délai de $TIMEOUT secondes."
  exit 1
fi
echo "Connexion réussie. Démarrage de l'exploration..."

# Commande principale (lftp)
OUTPUT_FILE="${IP}.txt"
lftp -e "set ftp:list-options -a; find . > ${OUTPUT_FILE}; bye" -u anonymous,password ftp://"$IP":"$PORT"
#lftp -e "set ftp:list-options -a; ls . > ${OUTPUT_FILE}; bye" -u anonymous,password ftp://"$IP":"$PORT"
# Vérifie si lftp a réussi
if [[ $? -eq 0 ]]; then
  echo "Résultats enregistrés dans ${OUTPUT_FILE}"

  # Compression du fichier en .zip
#  zip "${OUTPUT_FILE}.zip" "$OUTPUT_FILE" && rm "$OUTPUT_FILE"

  if [[ $? -eq 0 ]]; then
    echo "Fichier compressé en ${OUTPUT_FILE}.zip et original supprimé."
  else
    echo "Erreur lors de la compression du fichier."
  fi
else
  echo "Échec de la connexion ou de l'exploration pour $IP:$PORT"
fi

       

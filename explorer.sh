#!/bin/bash

# Initialiser les fichiers de log
> list.log
> listerr.log

# Parcourir les fichiers dans le dossier actuel
for file in *.txt; do
  if [[ -f "$file" ]]; then
    # Compter le nombre de lignes dans le fichier
    line_count=$(wc -l < "$file")
    
    if (( line_count > 3 )); then
      echo "$file" >> list.log
    else
      echo "$file" >> listerr.log
    fi
  fi
done

# Lire list.log et exécuter la commande pour chaque fichier
while IFS= read -r file; do
  # Extraire l'IP du nom du fichier (en supposant qu'il est au format ip.txt)
  ip="${file%.txt}"

  # Lancer la commande avec l'IP
  timeout 3600  ./indexing.sh -h "$ip" -p 21 &
done < list.log


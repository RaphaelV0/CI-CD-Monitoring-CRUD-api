#!/bin/bash
set -e

# Créer le répertoire logs si n'existe pas
mkdir -p /var/logs/crud

# Lancer l'application Node en arrière-plan
echo "Démarrage de Node.js..."
node index.js &

sleep 2

# Lancer Nginx au premier plan
echo "Démarrage de Nginx..."
nginx -g "daemon off;"
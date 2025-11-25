#!/bin/bash
set -e

# Créer le répertoire logs si n'existe pas
mkdir -p /var/logs/crud

# Lancer l'application Node en arrière-plan ET afficher les logs
echo "Démarrage de Node.js..."
node index.js 2>&1 | tee /var/logs/crud/app.log &

# Attendre que Node.js démarre
sleep 3

# Lancer Nginx au premier plan
echo "Démarrage de Nginx..."
nginx -g "daemon off;"
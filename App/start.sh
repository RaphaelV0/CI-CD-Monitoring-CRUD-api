#!/bin/bash
set -e

# Créer le répertoire logs si n'existe pas
mkdir -p /var/logs/crud

# Attendre que le Cloud SQL Proxy soit prêt
echo "Attente du Cloud SQL Proxy sur le port 3306..."
for i in {1..30}; do
  if timeout 1 bash -c 'cat < /dev/null > /dev/tcp/127.0.0.1/3306' 2>/dev/null; then
    echo "✅ Cloud SQL Proxy est prêt!"
    break
  fi
  echo "Tentative $i/30..."
  sleep 2
done

# Lancer l'application Node en arrière-plan ET afficher les logs
echo "Démarrage de Node.js..."
node index.js 2>&1 | tee /var/logs/crud/app.log &

# Attendre que Node.js démarre
sleep 3

# Lancer Nginx au premier plan
echo "Démarrage de Nginx..."
nginx -g "daemon off;"
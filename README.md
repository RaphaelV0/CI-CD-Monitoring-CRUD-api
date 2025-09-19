# API CRUD - TP DevOps CI/CD et Monitoring

## Description
API REST conteneurisée pour la gestion d'utilisateurs avec base de données MariaDB, reverse proxy Nginx et système de logs complet

## Architecture
- **Service app** : Application Node.js + Nginx (même conteneur)
- **Service db** : MariaDB 10.11
- **Reverse proxy** : Nginx avec logs JSON
- **Logs structurés** : Application et infrastructure

## Prérequis
- Docker et Docker Compose
- Port 8080 disponible sur votre machine

## Démarrage rapide
```bash
# Cloner le projet et aller dans le répertoire
cd CICD-Monitoring

# Démarrer tous les services
docker-compose up -d

# Vérifier le statut
docker-compose ps
```

## Variables d'environnement

### Base de données (optionnelles)
- `DB_ROOT_PASSWORD` : Mot de passe root MariaDB (défaut: rootpass)
- `DB_NAME` : Nom de la base de données (défaut: crud_app)
- `DB_USER` : Utilisateur de la base (défaut: crud)
- `DB_PASSWORD` : Mot de passe utilisateur (défaut: crudpass)

### Application
- `PORT` : Port de l'application Node.js (défaut: 3000)
- `DB_HOST` : Nom du service de base de données (défaut: db)
- `LOG_DIR` : Répertoire des logs (défaut: /var/logs/crud)

## Endpoints API

### Monitoring
- `GET /health` - Statut de l'API et connexion DB

### Gestion des utilisateurs
- `GET /api/users` - Liste tous les utilisateurs
- `GET /api/users/{uuid}` - Récupère un utilisateur par UUID
- `POST /api/users` - Crée un nouvel utilisateur
- `PUT /api/users/{uuid}` - Met à jour un utilisateur
- `DELETE /api/users/{uuid}` - Supprime un utilisateur

### Format des données utilisateur
```json
{
  "fullname": "Jean Dupont",
  "study_level": "Master",
  "age": 25
}
```

## Structure des logs
```
/var/logs/crud/
├── app.log      # Logs applicatifs (JSON)
├── access.log   # Logs d'accès Nginx (JSON)
└── error.log    # Logs d'erreur Nginx
```

## Tests avec curl/Postman

### Health check
```bash
curl http://localhost:8080/health
```

### Créer un utilisateur
```bash
{
  "fullname": "Jean Dupont",
  "study_level": "Master",
  "age": 25
}
```

### Lister les utilisateurs
```bash
curl http://localhost:8080/api/users
```

## Logs et monitoring

### Consulter les logs applicatifs
```bash
docker-compose exec app cat /var/logs/crud/app.log
```

### Consulter les logs Nginx
```bash
docker-compose exec app cat /var/logs/crud/access.log
```
**Prêt pour CI/CD et monitoring !** 🚀

# API CRUD - TP DevOps CI/CD et Monitoring

## Description
API REST conteneurisée pour la gestion d'utilisateurs avec base de données MariaDB, reverse proxy Nginx et système de logs complet

## Architecture

### Local (Docker Compose)
- **Service app** : Application Node.js + Nginx (même conteneur)
- **Service db** : MariaDB 10.11
- **Reverse proxy** : Nginx avec logs JSON
- **Logs structurés** : Application et infrastructure

### Production (Google Cloud Run)
- **Container crud-api** : Node.js + Nginx
- **Container cloud-sql-proxy** : Connexion sécurisée à Cloud SQL
- **Container fluent-bit** : Envoi des logs vers Loki
- **Volumes partagés** : `/var/logs/crud` (emptyDir)

## Prérequis

### Local
- Docker et Docker Compose
- Port 8080 disponible sur votre machine

### Production (GCP)
- Compte Google Cloud Platform
- Projet GCP configuré
- Instance Cloud SQL (MySQL 8.0)
- Compte Docker Hub

## Démarrage rapide (Local)
```bash
# Cloner le projet et aller dans le répertoire
cd CICD-Monitoring

# Démarrer tous les services
docker-compose up -d

# Vérifier le statut
docker-compose ps
```

## 🚀 Déploiement sur Google Cloud Run

### 1. Configuration des secrets GitHub

Dans **Settings → Secrets and variables → Actions**, ajoutez :

```bash
# Docker Hub
DOCKERHUB_USERNAME=votre_username
DOCKERHUB_TOKEN=votre_token

# Google Cloud
GCP_PROJECT_ID=votre-project-id
GCP_REGION=europe-west1
GCP_SA_KEY={"type":"service_account",...}  # JSON du service account

# Cloud SQL
DB_INSTANCE_CONNECTION_NAME=project:region:instance
DB_USER=crud
DB_PASSWORD=votremotdepasse
DB_NAME=crud_app

# Loki
LOKI_HOST=34.76.33.55
LOKI_PORT=3100
```

### 2. Préparation de Google Cloud

```bash
# Créer l'instance Cloud SQL
gcloud sql instances create crud-db \
  --database-version=MYSQL_8_0 \
  --tier=db-f1-micro \
  --region=europe-west1

# Créer la base de données et l'utilisateur
gcloud sql databases create crud_app --instance=crud-db
gcloud sql users create crud --instance=crud-db --password=VOTRE_MOT_DE_PASSE

# Créer un service account pour Cloud Run
gcloud iam service-accounts create cloud-run-sa

# Donner les permissions Cloud SQL
gcloud projects add-iam-policy-binding VOTRE_PROJECT_ID \
  --member="serviceAccount:cloud-run-sa@VOTRE_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudsql.client"

# Récupérer le nom de connexion Cloud SQL
gcloud sql instances describe crud-db --format="value(connectionName)"
```

### 3. Déployer

Créer et pousser un tag pour déclencher le déploiement :

```bash
git tag v1.0.0
git push origin v1.0.0
```

Le workflow GitHub Actions va automatiquement :
1. ✅ Récupérer le code
2. ✅ Extraire la version du tag
3. ✅ Construire et pousser les images Docker
4. ✅ Exécuter les migrations de base de données
5. ✅ Déployer sur Cloud Run
6. ✅ Configurer l'accès public

### 4. Accéder au service déployé

```bash
# Récupérer l'URL du service
gcloud run services describe crud-api \
  --region=europe-west1 \
  --format='value(status.url)'

# Tester l'API
curl https://VOTRE-SERVICE-URL/health
curl https://VOTRE-SERVICE-URL/api/users
```

## Accès à l'application

### Local
- **Health check** : http://localhost:8080/health
- **API Users** : http://localhost:8080/api/users

### Production (Cloud Run)
- **Health check** : https://VOTRE-SERVICE-URL/health
- **API Users** : https://VOTRE-SERVICE-URL/api/users

## Variables d'environnement

### Base de données (optionnelles en local)
- `DB_ROOT_PASSWORD` : Mot de passe root MariaDB (défaut: rootpass)
- `DB_NAME` : Nom de la base de données (défaut: crud_app)
- `DB_USER` : Utilisateur de la base (défaut: crud)
- `DB_PASSWORD` : Mot de passe utilisateur (défaut: crudpass)

### Application
- `PORT` : Port de l'application Node.js (défaut: 3000)
- `DB_HOST` : Nom du service de base de données (défaut: db en local, 127.0.0.1 sur Cloud Run)
- `LOG_DIR` : Répertoire des logs (défaut: /var/logs/crud)

### Monitoring
- `LOKI_HOST` : Adresse du serveur Loki
- `LOKI_PORT` : Port du serveur Loki (défaut: 3100)
- `LOKI_JOB_LABEL` : Label pour identifier les logs dans Loki

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

## Tests avec curl

### Créer un utilisateur
```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "fullname": "Jean Dupont",
    "study_level": "Master",
    "age": 25
  }'
```

### Lister les utilisateurs
```bash
curl http://localhost:8080/api/users
```

### Récupérer un utilisateur
```bash
curl http://localhost:8080/api/users/{uuid}
```

### Mettre à jour un utilisateur
```bash
curl -X PUT http://localhost:8080/api/users/{uuid} \
  -H "Content-Type: application/json" \
  -d '{
    "fullname": "Jean Martin",
    "study_level": "Doctorat",
    "age": 28
  }'
```

### Supprimer un utilisateur
```bash
curl -X DELETE http://localhost:8080/api/users/{uuid}
```

## 📁 Structure du projet

```
.
├── .github/
│   └── workflows/
│       └── deploy.yml              # Pipeline CI/CD
├── App/
│   ├── Dockerfile                  # Image Node.js + Nginx
│   ├── index.js                    # Application Express
│   ├── nginx.conf                  # Configuration Nginx
│   ├── package.json                # Dépendances
│   └── start.sh                    # Script de démarrage
├── migrations/
│   └── migrations.js               # Migrations DB
├── logs/                           # Logs locaux
├── cloud-run-service.yaml          # Configuration Cloud Run
├── docker-compose.yaml             # Configuration locale
├── Dockerfile.fluentbit            # Image Fluent Bit
├── Dockerfile.migrations           # Image pour migrations
├── fluent-bit.conf                 # Configuration Fluent Bit
├── parsers.conf                    # Parsers JSON
├── .env                            # Variables locales
└── README.md
```

## Pipeline CI/CD

Le workflow GitHub Actions (`.github/workflows/deploy.yml`) effectue :

1. **Build** : Construction des images Docker (API + Fluent Bit)
2. **Push** : Publication sur Docker Hub avec tags de version
3. **Migration** : Exécution des migrations via Cloud SQL Proxy
4. **Deploy** : Déploiement sur Cloud Run avec configuration automatique
5. **Verification** : Test des endpoints déployés

---

**Prêt pour le déploiement local et production ! 🚀**
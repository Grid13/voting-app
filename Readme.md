# Voting App

## Prérequis

- Docker
- Docker Compose

## Configuration Environment Variables

Les variables d'environnement sont utilisées pour configurer les services PostgreSQL et Redis, surtout dans les environnements Docker ou les setups de conteneurs. Ces variables peuvent être configurées dans le fichier `.env` à la racine du projet. (si le fichier n'existe pas, il faudra le créer)

### PostgreSQL Configuration

- **POSTGRES_USER**: Initialise le nom d'utilisateur pour la base de données PostgreSQL.  
  *Default*: `postgres`  
  *Recommendation*: Remplacer `postgres` par un nom d'utilisateur unique pour votre base de données.

- **POSTGRES_PASSWORD**: Initialise le mot de passe pour la base de données PostgreSQL.  
  *Default*: `postgres`  
  *Recommendation*: Utiliser un mot de passe robuste et unique pour votre base de données.

- **POSTGRES_DB**: Spécifie le nom de la base de données PostgreSQL à utiliser.
  *Default*: `postgres`  
  *Recommendation*: Ne pas modifier ce paramètre, il est généralement déjà configuré pour utiliser la base de données `postgres` créée par défaut par l'image docker PostgreSQL.

- **POSTGRES_HOST**: Le nom de l'hôte où se trouve le service PostgreSQL.  
  *Default*: `db`  
  *Recommendation*: Vérifier que ce paramètre correspond au nom du service PostgreSQL dans votre fichier `docker-compose.yml`.

### Redis Configuration

- **REDIS_HOST**: Le nom de l'hôte où se trouve le service Redis.  
  *Default*: `redis`  
  *Recommendation*: Vérifier que ce paramètre correspond au nom du service Redis dans votre fichier `docker-compose.yml`.

## Démarrage du projet

1. Exécuter la commande suivante pour créer les images Docker :

```bash
docker-compose up --build -d
```

2. Vérifier que les images Docker sont prêtes :

```bash
docker-compose ps
```

3. Vérifier que les services sont prêts en se rendant sur les url suivantes :

- [Vote (localhost:8080)](http://localhost:8080)
- [Resultat (localhost:8081)](http://localhost:8081)

### Déploiement de Voting App avec Docker Swarm

## 1. Prérequis
Avant de commencer, assurez-vous d'avoir :
- Un cluster Docker Swarm configuré avec au moins **un nœud manager** et **deux nœuds workers**.
- Docker installé sur chaque nœud.
- Un accès réseau entre les nœuds.
- Un fichier `docker-compose.yml` adapté à Docker Swarm.

## 2. Adaptation du `docker-compose.yml` pour Docker Swarm
Docker Swarm utilise `docker stack deploy` au lieu de `docker-compose up`. Il est nécessaire d’adapter le fichier `docker-compose.yml` en ajoutant des directives spécifiques à Swarm.

### Exemple de fichier `compose.yml` pour Swarm :
```yaml
version: "3.8"

services:
  vote:
    image: vote-app
    deploy:
      replicas: 2
      restart_policy:
        condition: on-failure
    ports:
      - "8080:80"
    networks:
      - vote-net

  result:
    image: result-app
    deploy:
      replicas: 2
      restart_policy:
        condition: on-failure
    ports:
      - "8081:80"
    networks:
      - vote-net

  worker:
    image: worker-app
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
    networks:
      - vote-net

  redis:
    image: redis:alpine
    deploy:
      replicas: 1
    networks:
      - vote-net

  db:
    image: postgres:15
    deploy:
      replicas: 1
    volumes:
      - db-data:/var/lib/postgresql/data
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    networks:
      - vote-net

networks:
  vote-net:

volumes:
  db-data:
```

## 3. Déploiement de l'application sur Swarm

### 3.1. Initialiser Swarm (si ce n'est pas encore fait)
Sur le nœud manager, exécutez :
```bash
docker swarm init --advertise-addr <IP_MANAGER>
```
Si vous avez plusieurs nœuds workers, récupérez la commande pour les ajouter au cluster :
```bash
docker swarm join-token worker
```
Exécutez cette commande sur chaque nœud worker pour les intégrer au cluster.

### 3.2. Déployer la stack
Sur le nœud manager, déployez l'application avec :
```bash
docker stack deploy -c docker-compose.yml voting_app
```
Vérifiez que tous les services sont en cours d'exécution :
```bash
docker service ls
```

### 3.3. Vérifier les logs et l'état des services
Affichez les logs d'un service en particulier :
```bash
docker service logs voting_app_vote
```
Vérifiez les conteneurs en cours d'exécution :
```bash
docker ps
```

## 4. Tests et validation

- Accédez à l'interface de vote : [http://localhost:8080](http://localhost:8080)
- Accédez aux résultats : [http://localhost:8081](http://localhost:8081)
- Vérifiez l'état des nœuds Swarm :
```bash
docker node ls
```

## 5. Suppression de la stack
Si vous souhaitez supprimer le déploiement, exécutez :
```bash
docker stack rm voting_app
```
Pour quitter Swarm sur un nœud worker :
```bash
docker swarm leave
```
Pour désactiver Swarm sur le manager :
```bash
docker swarm leave --force
```


#!/bin/bash
# Script de connexion à PostgreSQL
set -eo pipefail

# récupérer les variables d'environnement
host="$(hostname -i || echo '127.0.0.1')"
user="${POSTGRES_USER:-postgres}" # fallback sur "postgres" si POSTGRES_USER n'est pas définie dans l'environnement
db="${POSTGRES_DB:-postgres}" # fallback sur "postgres" si POSTGRES_DB n'est pas définie dans l'environnement
export PGPASSWORD="${POSTGRES_PASSWORD:-}" # fallback sur vide si POSTGRES_PASSWORD n'est pas définie dans l'environnement

args=(
	--host "$host"
	--username "$user"
	--dbname "$db"
	--quiet --no-align --tuples-only
)

# Vérifier si la connexion est valide en exécutant la commande SELECT 1 sur le serveur PostgreSQL qui doit renvoyer 1
if select="$(echo 'SELECT 1' | psql "${args[@]}")" && [ "$select" = '1' ]; then
	exit 0
fi

# Si la connexion n'est pas valide, retourner un code d'erreur non-zéro
exit 1
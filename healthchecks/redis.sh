#!/bin/sh
# Script de vérification de la connexion à Redis
set -eo pipefail

# Récupérer les variables d'environnement
host="$(hostname -i || echo '127.0.0.1')"

# Vérifier si la connexion est valide en exécutant la commande PING sur le serveur Redis qui doit renvoyer PONG
if ping="$(redis-cli -h "$host" ping)" && [ "$ping" = 'PONG' ]; then
    exit 0
fi

# Si la connexion n'est pas valide, retourner un code d'erreur non-zéro
exit 1

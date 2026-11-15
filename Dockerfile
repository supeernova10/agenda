# --- Étape 1 : Builder (installation propre des dépendances) ---
FROM node:22-alpine AS builder

# Création du dossier de travail
WORKDIR /app

# Copie uniquement des fichiers de dépendances pour optimiser le cache
COPY package*.json ./

# Installation propre des dépendances de production
RUN npm ci --omit=dev

# --- Étape 2 : Image de production durcie ---
FROM node:22-alpine

# 1. Correction des CVE OS Alpine (OpenSSL, musl, zlib)
RUN apk update && apk upgrade --no-cache

# 2. Suppression des gestionnaires de paquets inutiles en production (élimine les CVE de npm)
RUN rm -rf /usr/local/lib/node_modules/npm \
           /usr/local/lib/node_modules/corepack \
           /usr/local/bin/npm \
           /usr/local/bin/npx \
           /usr/local/bin/corepack \
           /opt/yarn* \
           /usr/local/bin/yarn*

WORKDIR /app

# Récupération des dépendances installées et du code source
COPY --from=builder /app/node_modules ./node_modules
COPY . .

# Sécurité : bascule sur l'utilisateur non-privilégié "node" (inclus dans l'image)
RUN chown -R node:node /app
USER node

# Port exposé par ton serveur Express (adapte si tu utilises 3000 ou 8080)
EXPOSE 3000

# Lancement de l'application (adapte selon ton point d'entrée : app.js ou server.js)
CMD ["node", "src/server.js"]
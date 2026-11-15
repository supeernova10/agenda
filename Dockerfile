# Utilisation d'une image Node.js officielle légère et maintenue
FROM node:20-alpine

# Création du dossier de travail
WORKDIR /app

# Copie uniquement des fichiers de dépendances pour optimiser le cache
COPY package*.json ./

# Installation propre des dépendances de production
RUN npm ci --only=production

# Copie du reste du code source
COPY . .

# Sécurité : bascule sur l'utilisateur non-privilégié "node" (inclus dans l'image)
RUN chown -R node:node /app
USER node

# Port exposé par ton serveur Express (adapte si tu utilises 3000 ou 8080)
EXPOSE 3000

# Lancement de l'application (adapte selon ton point d'entrée : app.js ou server.js)
CMD ["node", "server.js"]
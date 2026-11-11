# Étape 1 : valider les XML contre leurs schémas et générer les pages
FROM alpine:3.20 AS build
RUN apk add --no-cache libxslt libxml2-utils
WORKDIR /app
COPY data/ data/
COPY docker/generer.sh docker/generer.sh

# Paramètres des transformations, modifiables avec --build-arg
ARG INFIRMIER_ID=001
ARG PATIENT_PRENOM=Hiba

RUN INFIRMIER_ID="$INFIRMIER_ID" PATIENT_PRENOM="$PATIENT_PRENOM" sh docker/generer.sh

# Étape 2 : servir les pages avec nginx
FROM nginx:1.27-alpine
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/data /usr/share/nginx/html
EXPOSE 80

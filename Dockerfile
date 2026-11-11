# Étape 1 : valider les XML contre leurs schémas et générer les pages
FROM alpine:3.20 AS build
RUN apk add --no-cache libxslt libxml2-utils
WORKDIR /app
COPY data/ data/

# Paramètres des transformations, modifiables avec --build-arg
ARG INFIRMIER_ID=001
ARG PATIENT_PRENOM=Hiba

RUN xmllint --noout --schema data/xsd/cabinet.xsd data/xml/cabinet.xml \
 && xmllint --noout --schema data/xsd/actes.xsd   data/xml/acte.xml \
 && xmllint --noout --schema data/xsd/patient.xsd data/xml/patient.xml \
 && xsltproc --stringparam destinedId "$INFIRMIER_ID" \
      -o data/html/infirmier.html data/xslt/cabinet.xsl data/xml/cabinet.xml \
 && xsltproc --stringparam destinedName "$PATIENT_PRENOM" \
      -o data/xml/patientxml.xml data/xslt/patientxml.xsl data/xml/cabinet.xml \
 && xmllint --noout --schema data/xsd/patient.xsd data/xml/patientxml.xml \
 && xsltproc -o data/html/patienthtml.html data/xslt/patienthtml.xsl data/xml/patientxml.xml

# Étape 2 : servir les pages avec nginx
FROM nginx:1.27-alpine
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/data /usr/share/nginx/html
EXPOSE 80

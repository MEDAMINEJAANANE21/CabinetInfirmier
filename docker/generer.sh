#!/bin/sh
# Valide les XML puis génère toutes les pages HTML du projet.
# À lancer depuis la racine du dépôt : sh docker/generer.sh
# Nécessite xsltproc et xmllint (paquets libxslt et libxml2-utils).
set -eu

INFIRMIER_ID="${INFIRMIER_ID:-001}"
PATIENT_PRENOM="${PATIENT_PRENOM:-Hiba}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Validation des XML"
xmllint --noout --schema data/xsd/cabinet.xsd data/xml/cabinet.xml
xmllint --noout --schema data/xsd/actes.xsd   data/xml/acte.xml
xmllint --noout --schema data/xsd/patient.xsd data/xml/patient.xml

echo "Tableau de bord : index.html"
xsltproc -o data/html/index.html data/xslt/accueil.xsl data/xml/cabinet.xml

echo "Nomenclature : nomenclature.html"
xsltproc -o data/html/nomenclature.html data/xslt/nomenclature.xsl data/xml/acte.xml

echo "Tournée de l'infirmier $INFIRMIER_ID"
xsltproc --stringparam destinedId "$INFIRMIER_ID" \
    -o data/html/infirmier.html data/xslt/cabinet.xsl data/xml/cabinet.xml

echo "Dossier de référence ($PATIENT_PRENOM) : patientxml.xml et patienthtml.html"
xsltproc --stringparam destinedName "$PATIENT_PRENOM" \
    -o data/xml/patientxml.xml data/xslt/patientxml.xsl data/xml/cabinet.xml
xmllint --noout --schema data/xsd/patient.xsd data/xml/patientxml.xml
xsltproc -o data/html/patienthtml.html data/xslt/patienthtml.xsl data/xml/patientxml.xml

# Un dossier et une facture par patient, nommés d'après son NIR (seul attribut de <patient>)
for nir in $(xmllint --xpath "//*[local-name()='patient']/@*" data/xml/cabinet.xml | grep -o '[0-9]\{15\}'); do
    echo "Dossier patient-$nir.html et facture-$nir.html"
    xsltproc --stringparam destinedNir "$nir" \
        -o "data/html/facture-$nir.html" data/xslt/facture.xsl data/xml/cabinet.xml
    xsltproc --stringparam destinedNir "$nir" \
        -o "$TMP/patient-$nir.xml" data/xslt/patientxml.xsl data/xml/cabinet.xml
    xmllint --noout --schema data/xsd/patient.xsd "$TMP/patient-$nir.xml"
    xsltproc -o "data/html/patient-$nir.html" data/xslt/patienthtml.xsl "$TMP/patient-$nir.xml"
done

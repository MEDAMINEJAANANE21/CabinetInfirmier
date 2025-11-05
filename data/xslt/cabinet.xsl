<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:med="http://www.univ-grenoble-alpes.fr/l3miage/medical" 
    xmlns:act="http://www.univ-grenoble-alpes.fr/l3miage/actes"
>
<xsl:output method="html" encoding="UTF-8"/>
    
    <!-- Paramettre global pour déterminier l'infirmier a affichée-->
    <xsl:param name="destinedId">001</xsl:param>
    
    <xsl:variable name="actes" select="document('../xml/acte.xml', /)/act:ngap"/> <!--Les actes: kathal fichier acte.xml ou kat7at la variable actes sur le noeud:  /act:ngap , fhala kat3awd lina /act:ngap avec actes-->
    
    <xsl:template match="/">
        <html>
            <head>
                <title>Page de l'Infirmier</title>
                <link rel="stylesheet" href="/data/css/infirmier.css"/>
                <script type="text/javascript" src="../js/buttonScript.js"></script> <!-- A revoir cette partie-->
            </head>
            <body>
                <div class="container">
                    <!-- Appliquer le template pour l'infirmier -->
                    <p>Bonjour <xsl:value-of select="med:cabinet/med:infirmiers/med:infirmier[@id=$destinedId]/@prénom"/> , </p>

                    <!-- Compter et afficher le nombre de patients assignés -->
                    <xsl:variable name="patientCount" select="count(med:cabinet/med:patients/med:patient[med:visite/@intervenant=$destinedId])"/>
                    <p>Aujourd'hui, vous avez <xsl:value-of select="$patientCount"/> patient(s).</p>

                    <!-- Appliquer les templates pour les patients -->
                    <xsl:apply-templates select="med:cabinet/med:patients/med:patient[med:visite/@intervenant=$destinedId]"/>
                </div>

            </body>
        </html>
    </xsl:template>

    
    <xsl:template match="med:patient">
        
        <h3> Patient : <xsl:value-of select="med:nom"/><xsl:text> </xsl:text><xsl:value-of select="med:prénom"/></h3>
        
        
        <xsl:variable name="adresse">
            <xsl:value-of select="concat(med:adresse/med:numéro, ' ', med:adresse/med:rue, ', ', med:adresse/med:codePostal, ' ', med:adresse/med :ville)"/>
        </xsl:variable>
        
        
        <div class="patient-container">
           <ul>
               <li>Sexe : <xsl:value-of select="med:sexe"/></li>
               <li>Date de Naissance : <xsl:value-of select="med:naissance"/></li>
               <li>NIR : <xsl:value-of select="@numéro"/></li>
               <li>Adresse : <xsl:apply-templates select="med:adresse"/></li>
           </ul>
            <h4>Soin a effectuer:</h4>
            <table>
                <th>Date de Visite</th><th> Actes </th>
                <xsl:apply-templates select="med:visite"/>
            </table>
        </div>
        
    </xsl:template>

    <xsl:template match="med:adresse">
        <xsl:value-of select="med:numéro"/> <xsl:text> </xsl:text>
        <xsl:value-of select="med:rue"/><xsl:text>, </xsl:text> <xsl:value-of select="med:codePostal"/><xsl:text> </xsl:text><xsl:value-of select="med:ville"/>
    </xsl:template>
    
    <xsl:template match="med:visite">
        <tr><td><xsl:value-of select="@date"/></td><td><ul><xsl:apply-templates select="med:acte"/></ul></td></tr>
    </xsl:template>

    <xsl:template match="med:acte">
        <xsl:variable name="idActeVisite" select="@id"/>
        <li> <xsl:value-of select="$actes/act:actes/act:acte[@id=$idActeVisite]/text()"/></li>
    </xsl:template>
    
</xsl:stylesheet>
    
    
    
    
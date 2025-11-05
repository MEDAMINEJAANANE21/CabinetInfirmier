<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pat="http://www.univ-grenoble-alpes.fr/l3miage/patient"
>
    <xsl:output method="html" encoding="UTF-8"/>
    
    <xsl:template match="/">
        <html>
            <head>
                <title>page fantastique</title>
                <link rel="stylesheet" href="/data/css/patient.css"/>
            </head>
            <body>
                <xsl:apply-templates select="pat:patient"/>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="pat:patient">
        <div class="milieuEcriture">
            <h4>Information du patient :</h4>  
        </div>       
        <div class="container">
            <ul>
            <li>Nom : <xsl:value-of select="pat:nom"/></li>
            <li>Prénom : <xsl:value-of select="pat:prénom"/></li>
            <li>Sexe : <xsl:value-of select="pat:sexe"/></li>
            <li>Naissance : <xsl:value-of select="pat:naissance"/></li>
            <li>NuméroSS : <xsl:value-of select="pat:numéroSS"/></li>
            <xsl:apply-templates select="pat:adresse"/>
            </ul>
            <h4>Visites :</h4>
            <table>
                <th>Date </th><th> Intervenant</th><th>Acte</th>
                <xsl:apply-templates select="pat:visite"/>
            </table>
        </div>
    </xsl:template>
    
    <xsl:template match="pat:adresse">
        <li>Adresse : <xsl:value-of select="pat:rue"/>, <xsl:text> </xsl:text>
        <xsl:value-of select="pat:codePostal"/><xsl:text> </xsl:text> <xsl:value-of select="pat:ville"/>
        </li>
    </xsl:template>
    
    <xsl:template match="pat:visite"> <!-- On a fait le choix qu une visite ne peut avoir qu un seul intervenant-->
        <tr><td><xsl:value-of select="@date"/></td>
            <td><xsl:value-of select="pat:intervenant/pat:nom"/><xsl:text> </xsl:text><xsl:value-of select="pat:intervenant/pat:prénom"/></td>
        <td>
            <ul>
                <xsl:apply-templates select="pat:acte"/>
            </ul>
        </td>
        </tr>
    </xsl:template>
    
    <xsl:template match="pat:acte">
                <li> <xsl:value-of select="."/> </li>
    </xsl:template>    
    
</xsl:stylesheet>
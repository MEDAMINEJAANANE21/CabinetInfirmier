<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:med="http://www.univ-grenoble-alpes.fr/l3miage/medical"
                xmlns:act="http://www.univ-grenoble-alpes.fr/l3miage/actes"
                xmlns="http://www.univ-grenoble-alpes.fr/l3miage/patient"
                exclude-result-prefixes="med act"><!--had la ligne kathayd lina dakchi li maandi mandir bih ou kan khaliw binathoum un espace -->
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:param name="destinedName">Hiba</xsl:param>
    <xsl:variable name="actes" select="document('../xml/acte.xml',/)/act:ngap"/><!--fach kanbghi nkharj les infos man fichier xml akhour -->
    
    <xsl:template match="/">
        <patient xmlns:xs="http://www.w3.org/2001/XMLSchema-instance"
                 xs:schemaLocation="http://www.univ-grenoble-alpes.fr/l3miage/patient ../xsd/patient.xsd">
            <xsl:apply-templates select="//med:patient[med:prénom = $destinedName]"/>
        </patient>
    </xsl:template>
    
    <xsl:template match="med:patient"> 
        <nom><xsl:value-of select="med:nom"/></nom>
        <prénom><xsl:value-of select="med:prénom"/></prénom>
        <sexe><xsl:value-of select="med:sexe"/></sexe>
        <naissance><xsl:value-of select="med:naissance"/></naissance>
        <numéroSS><xsl:value-of select="@numéro"/></numéroSS>
        <adresse><xsl:apply-templates select="med:adresse"/></adresse> <!--On a fait un apply car on a bcp d'information dans une adresse qu'il faut structurer -->
        <visite><xsl:apply-templates select="med:visite"/></visite> <!-- car on peut avoir plusieurs visites-->
    </xsl:template>
    
    <xsl:template match="med:adresse">
        <rue><xsl:value-of select="med:rue"/></rue>
        <codePostal><xsl:value-of select="med:codePostal"/></codePostal>
        <ville><xsl:value-of select="med:ville"/></ville>
    </xsl:template>
    
    <xsl:template match="med:visite">
        <xsl:attribute name="date">
            <xsl:value-of select="@date"/>
        </xsl:attribute>
        <intervenant>
            <xsl:variable name="idIntervenant" select="@intervenant"/><!--finma ykoun andi [] kan3raf rassi aykhassni ndir une variable dans la partie a doite-->
            <nom><xsl:value-of select="//med:infirmier[@id = $idIntervenant]/@nom"/></nom>
            <prénom><xsl:value-of select="//med:infirmier[@id = $idIntervenant]/@prénom"/></prénom>
        </intervenant>
        <xsl:apply-templates select="med:acte"/>
    </xsl:template>
    
    <xsl:template match="med:acte">
        <acte>
        <xsl:variable name="idActePatient" select="@id"/>
        <xsl:value-of select="$actes/act:actes/act:acte[@id=$idActePatient]/text()"/>
        </acte>
    </xsl:template>














</xsl:stylesheet>
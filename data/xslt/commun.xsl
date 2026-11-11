<?xml version="1.0" encoding="UTF-8" ?>
<!--
    Modèles partagés par toutes les pages HTML (xsl:include) :
    en-tête de page, barre de navigation, dates, tarifs des actes et montants.
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:med="http://www.univ-grenoble-alpes.fr/l3miage/medical"
    xmlns:act="http://www.univ-grenoble-alpes.fr/l3miage/actes"
    exclude-result-prefixes="med act">

    <!-- Données de référence, chemins relatifs à ce fichier (data/xslt/) -->
    <xsl:variable name="actes" select="document('../xml/acte.xml')/act:ngap"/>
    <xsl:variable name="cabinet" select="document('../xml/cabinet.xml')/med:cabinet"/>

    <!-- Valeur des lettres-clés en centimes (mêmes valeurs que facture.js : 3,15 €, 2,65 €, 10 €) -->
    <xsl:variable name="centimesAMI" select="315"/>
    <xsl:variable name="centimesAIS" select="265"/>
    <xsl:variable name="centimesDI" select="1000"/>

    <xsl:decimal-format name="fr" decimal-separator="," grouping-separator=" "/>

    <!-- <head> commun : titre, polices, feuilles de style -->
    <xsl:template name="entete-html">
        <xsl:param name="titre"/>
        <xsl:param name="css"/>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1"/>
            <title><xsl:value-of select="$titre"/></title>
            <link rel="preconnect" href="https://fonts.googleapis.com"/>
            <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin=""/>
            <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=DM+Mono:wght@400;500&amp;family=Figtree:wght@400;500;600&amp;display=swap"/>
            <link rel="stylesheet" href="../css/commun.css"/>
            <xsl:if test="$css">
                <link rel="stylesheet" href="../css/{$css}"/>
            </xsl:if>
        </head>
    </xsl:template>

    <!-- Barre du haut : nom du cabinet et navigation ; $actif = page courante -->
    <xsl:template name="barre">
        <xsl:param name="actif"/>
        <header class="barre">
            <div class="barre-contenu">
                <a class="marque" href="index.html">
                    <!-- Logo : croix blanche sur carré bleu, point rose -->
                    <svg class="logo" width="28" height="28" viewBox="0 0 28 28" aria-hidden="true">
                        <rect width="28" height="28" rx="8" fill="#2563eb"/>
                        <path d="M11.5 7h5v4.5H21v5h-4.5V21h-5v-4.5H7v-5h4.5z" fill="#ffffff"/>
                        <circle cx="23" cy="5" r="3.5" fill="#ec4899" stroke="#ffffff" stroke-width="1.5"/>
                    </svg>
                    <span><xsl:value-of select="$cabinet/med:nom"/></span>
                </a>
                <nav class="nav" aria-label="Navigation principale">
                    <xsl:call-template name="lien-nav">
                        <xsl:with-param name="href">index.html</xsl:with-param>
                        <xsl:with-param name="texte">Tableau de bord</xsl:with-param>
                        <xsl:with-param name="actif" select="$actif = 'accueil'"/>
                    </xsl:call-template>
                    <xsl:call-template name="lien-nav">
                        <xsl:with-param name="href">infirmier.html</xsl:with-param>
                        <xsl:with-param name="texte">Tournée</xsl:with-param>
                        <xsl:with-param name="actif" select="$actif = 'tournee'"/>
                    </xsl:call-template>
                    <xsl:call-template name="lien-nav">
                        <xsl:with-param name="href">nomenclature.html</xsl:with-param>
                        <xsl:with-param name="texte">Nomenclature</xsl:with-param>
                        <xsl:with-param name="actif" select="$actif = 'nomenclature'"/>
                    </xsl:call-template>
                    <a href="../xml/cabinet.xml">Données XML</a>
                </nav>
            </div>
        </header>
    </xsl:template>

    <xsl:template name="lien-nav">
        <xsl:param name="href"/>
        <xsl:param name="texte"/>
        <xsl:param name="actif" select="false()"/>
        <a href="{$href}">
            <xsl:if test="$actif"><xsl:attribute name="aria-current">page</xsl:attribute></xsl:if>
            <xsl:value-of select="$texte"/>
        </a>
    </xsl:template>

    <!-- AAAA-MM-JJ vers JJ/MM/AAAA -->
    <xsl:template name="date">
        <xsl:param name="iso"/>
        <time datetime="{$iso}">
            <xsl:value-of select="concat(substring($iso, 9, 2), '/', substring($iso, 6, 2), '/', substring($iso, 1, 4))"/>
        </time>
    </xsl:template>

    <!-- Tarif d'un acte de la nomenclature, en centimes : lettre-clé × coefficient -->
    <xsl:template name="centimes-acte">
        <xsl:param name="ref"/>
        <xsl:value-of select="round($ref/@coef * (($ref/@clé = 'AMI') * $centimesAMI
                                                 + ($ref/@clé = 'AIS') * $centimesAIS
                                                 + ($ref/@clé = 'DI') * $centimesDI))"/>
    </xsl:template>

    <!-- Somme en centimes d'une liste de <med:acte id="…"/> (récursif, XSLT 1.0) -->
    <xsl:template name="centimes-total">
        <xsl:param name="refs"/>
        <xsl:param name="cumul" select="0"/>
        <xsl:choose>
            <xsl:when test="$refs">
                <xsl:variable name="id" select="$refs[1]/@id"/>
                <xsl:variable name="tarif">
                    <xsl:call-template name="centimes-acte">
                        <xsl:with-param name="ref" select="$actes/act:actes/act:acte[@id = $id]"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="centimes-total">
                    <xsl:with-param name="refs" select="$refs[position() &gt; 1]"/>
                    <xsl:with-param name="cumul" select="$cumul + number($tarif)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$cumul"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Centimes vers « 11,03 € » -->
    <xsl:template name="euros">
        <xsl:param name="centimes"/>
        <xsl:value-of select="format-number($centimes div 100, '# ##0,00', 'fr')"/>
        <xsl:text>&#160;€</xsl:text>
    </xsl:template>

    <!-- Étiquette du code NGAP : « 101 · AMI 1,5 » -->
    <xsl:template name="code-acte">
        <xsl:param name="ref"/>
        <span class="code">
            <xsl:value-of select="$ref/@id"/>
            <xsl:text> · </xsl:text>
            <xsl:value-of select="$ref/@clé"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="translate($ref/@coef, '.', ',')"/>
        </span>
    </xsl:template>

    <!-- Libellé d'un type d'acte (pi, pc, pl, sd) -->
    <xsl:template name="libelle-type">
        <xsl:param name="type"/>
        <xsl:value-of select="normalize-space($actes/act:types/act:type[@id = $type])"/>
    </xsl:template>

</xsl:stylesheet>

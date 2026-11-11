<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:med="http://www.univ-grenoble-alpes.fr/l3miage/medical"
    xmlns:act="http://www.univ-grenoble-alpes.fr/l3miage/actes"
    exclude-result-prefixes="med act">

    <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat"/>

    <!-- Paramètre global : identifiant de l'infirmier dont on affiche la tournée -->
    <xsl:param name="destinedId">001</xsl:param>

    <!-- Nomenclature des actes (NGAP), chargée depuis acte.xml -->
    <xsl:variable name="actes" select="document('../xml/acte.xml', /)/act:ngap"/>

    <xsl:variable name="infirmier" select="/med:cabinet/med:infirmiers/med:infirmier[@id = $destinedId]"/>
    <xsl:variable name="patients" select="/med:cabinet/med:patients/med:patient[med:visite/@intervenant = $destinedId]"/>

    <xsl:template match="/">
        <html lang="fr">
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1"/>
                <title>Tournée de l'infirmier</title>
                <link rel="preconnect" href="https://fonts.googleapis.com"/>
                <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin=""/>
                <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&amp;family=IBM+Plex+Sans:wght@400;500&amp;display=swap"/>
                <link rel="stylesheet" href="../css/infirmier.css"/>
            </head>
            <body>
                <main class="page">
                    <header class="entete">
                        <p class="surtitre">
                            <xsl:value-of select="med:cabinet/med:nom"/>
                            <xsl:text> · </xsl:text>
                            <xsl:apply-templates select="med:cabinet/med:adresse"/>
                        </p>
                        <h1>Patients à voir</h1>
                        <p class="resume">
                            <xsl:value-of select="$infirmier/@prénom"/>
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="$infirmier/@nom"/>
                            <xsl:text> · </xsl:text>
                            <strong><xsl:value-of select="count($patients)"/></strong>
                            <xsl:choose>
                                <xsl:when test="count($patients) &gt; 1"> patients</xsl:when>
                                <xsl:otherwise> patient</xsl:otherwise>
                            </xsl:choose>
                        </p>
                    </header>

                    <div class="patients">
                        <xsl:apply-templates select="$patients"/>
                    </div>
                </main>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="med:patient">
        <section class="patient">
            <header class="patient-entete">
                <h2>
                    <xsl:value-of select="normalize-space(med:nom)"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="normalize-space(med:prénom)"/>
                </h2>
                <span class="nir">NIR <xsl:value-of select="@numéro"/></span>
            </header>

            <dl class="fiche">
                <dt>Sexe</dt>
                <dd><xsl:value-of select="med:sexe"/></dd>
                <dt>Naissance</dt>
                <dd>
                    <xsl:call-template name="date">
                        <xsl:with-param name="iso" select="med:naissance"/>
                    </xsl:call-template>
                </dd>
                <dt>Adresse</dt>
                <dd><xsl:apply-templates select="med:adresse"/></dd>
            </dl>

            <h3>Soins à effectuer</h3>
            <table class="soins">
                <thead>
                    <tr><th scope="col">Date de visite</th><th scope="col">Actes</th></tr>
                </thead>
                <tbody>
                    <xsl:apply-templates select="med:visite[@intervenant = $destinedId]"/>
                </tbody>
            </table>
        </section>
    </xsl:template>

    <!-- Adresse sur une ligne ; le numéro et l'étage sont optionnels -->
    <xsl:template match="med:adresse">
        <xsl:if test="med:numéro">
            <xsl:value-of select="med:numéro"/>
            <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:value-of select="normalize-space(med:rue)"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="med:codePostal"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="normalize-space(med:ville)"/>
        <xsl:if test="med:étage">
            <xsl:text>, étage </xsl:text>
            <xsl:value-of select="med:étage"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="med:visite">
        <tr>
            <td class="date">
                <xsl:call-template name="date">
                    <xsl:with-param name="iso" select="@date"/>
                </xsl:call-template>
            </td>
            <td><ul class="actes"><xsl:apply-templates select="med:acte"/></ul></td>
        </tr>
    </xsl:template>

    <!-- Un acte : code NGAP (id, lettre-clé, coefficient) puis son intitulé -->
    <xsl:template match="med:acte">
        <xsl:variable name="idActeVisite" select="@id"/>
        <xsl:variable name="ref" select="$actes/act:actes/act:acte[@id = $idActeVisite]"/>
        <li>
            <span class="code">
                <xsl:value-of select="$idActeVisite"/>
                <xsl:text> · </xsl:text>
                <xsl:value-of select="$ref/@clé"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="translate($ref/@coef, '.', ',')"/>
            </span>
            <span class="intitule"><xsl:value-of select="normalize-space($ref)"/></span>
        </li>
    </xsl:template>

    <!-- AAAA-MM-JJ vers JJ/MM/AAAA -->
    <xsl:template name="date">
        <xsl:param name="iso"/>
        <time datetime="{$iso}">
            <xsl:value-of select="concat(substring($iso, 9, 2), '/', substring($iso, 6, 2), '/', substring($iso, 1, 4))"/>
        </time>
    </xsl:template>

</xsl:stylesheet>

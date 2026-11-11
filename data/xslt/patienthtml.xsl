<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pat="http://www.univ-grenoble-alpes.fr/l3miage/patient"
                exclude-result-prefixes="pat">

    <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat"/>

    <xsl:template match="/">
        <html lang="fr">
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1"/>
                <title>Dossier patient</title>
                <link rel="preconnect" href="https://fonts.googleapis.com"/>
                <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin=""/>
                <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&amp;family=IBM+Plex+Sans:wght@400;500&amp;display=swap"/>
                <link rel="stylesheet" href="../css/patient.css"/>
            </head>
            <body>
                <main class="page">
                    <xsl:apply-templates select="pat:patient"/>
                </main>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="pat:patient">
        <header class="entete">
            <p class="surtitre">Dossier patient</p>
            <h1>
                <xsl:value-of select="normalize-space(pat:prénom)"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="normalize-space(pat:nom)"/>
            </h1>
            <p class="nir">NIR <xsl:value-of select="pat:numéroSS"/></p>
        </header>

        <section class="bloc">
            <h2>Informations</h2>
            <dl class="fiche">
                <dt>Nom</dt>
                <dd><xsl:value-of select="normalize-space(pat:nom)"/></dd>
                <dt>Prénom</dt>
                <dd><xsl:value-of select="normalize-space(pat:prénom)"/></dd>
                <dt>Sexe</dt>
                <dd><xsl:value-of select="pat:sexe"/></dd>
                <dt>Naissance</dt>
                <dd>
                    <xsl:call-template name="date">
                        <xsl:with-param name="iso" select="pat:naissance"/>
                    </xsl:call-template>
                </dd>
                <dt>Adresse</dt>
                <dd><xsl:apply-templates select="pat:adresse"/></dd>
            </dl>
        </section>

        <section class="bloc">
            <div class="bloc-titre">
                <h2>Visites</h2>
                <span class="compte">
                    <xsl:value-of select="count(pat:visite)"/>
                    <xsl:choose>
                        <xsl:when test="count(pat:visite) &gt; 1"> visites</xsl:when>
                        <xsl:otherwise> visite</xsl:otherwise>
                    </xsl:choose>
                </span>
            </div>
            <table class="visites">
                <thead>
                    <tr>
                        <th scope="col">Date</th>
                        <th scope="col">Intervenant</th>
                        <th scope="col">Actes</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:apply-templates select="pat:visite"/>
                </tbody>
            </table>
        </section>
    </xsl:template>

    <xsl:template match="pat:adresse">
        <xsl:value-of select="normalize-space(pat:rue)"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="pat:codePostal"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="normalize-space(pat:ville)"/>
    </xsl:template>

    <!-- On a fait le choix qu'une visite ne peut avoir qu'un seul intervenant -->
    <xsl:template match="pat:visite">
        <tr>
            <td class="date">
                <xsl:call-template name="date">
                    <xsl:with-param name="iso" select="@date"/>
                </xsl:call-template>
            </td>
            <td class="intervenant">
                <xsl:value-of select="normalize-space(pat:intervenant/pat:prénom)"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="normalize-space(pat:intervenant/pat:nom)"/>
            </td>
            <td><ul class="actes"><xsl:apply-templates select="pat:acte"/></ul></td>
        </tr>
    </xsl:template>

    <xsl:template match="pat:acte">
        <li><xsl:value-of select="normalize-space(.)"/></li>
    </xsl:template>

    <!-- AAAA-MM-JJ vers JJ/MM/AAAA -->
    <xsl:template name="date">
        <xsl:param name="iso"/>
        <time datetime="{$iso}">
            <xsl:value-of select="concat(substring($iso, 9, 2), '/', substring($iso, 6, 2), '/', substring($iso, 1, 4))"/>
        </time>
    </xsl:template>

</xsl:stylesheet>

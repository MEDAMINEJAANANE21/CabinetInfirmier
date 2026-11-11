<?xml version="1.0" encoding="UTF-8" ?>
<!-- Dossier XML d'un patient (espace de noms pat) → page HTML -->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pat="http://www.univ-grenoble-alpes.fr/l3miage/patient"
                xmlns:act="http://www.univ-grenoble-alpes.fr/l3miage/actes"
                exclude-result-prefixes="pat act">

    <xsl:include href="commun.xsl"/>

    <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat"/>

    <xsl:template match="/">
        <html lang="fr">
            <xsl:call-template name="entete-html">
                <xsl:with-param name="titre">Dossier patient</xsl:with-param>
                <xsl:with-param name="css">patient.css</xsl:with-param>
            </xsl:call-template>
            <body>
                <xsl:call-template name="barre"/>
                <main class="page">
                    <xsl:apply-templates select="pat:patient"/>
                </main>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="pat:patient">
        <header class="entete entete-actions">
            <div>
                <p class="surtitre">Dossier patient</p>
                <h1>
                    <xsl:value-of select="normalize-space(pat:prénom)"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="normalize-space(pat:nom)"/>
                </h1>
                <p class="nir">NIR <xsl:value-of select="pat:numéroSS"/></p>
            </div>
            <div class="actions">
                <a class="bouton bouton-secondaire" href="infirmier.html">Tournée</a>
                <a class="bouton" href="facture-{pat:numéroSS}.html">Facture</a>
            </div>
        </header>

        <section class="carte">
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

        <section class="carte">
            <div class="carte-titre">
                <h2>Visites</h2>
                <span class="meta">
                    <xsl:value-of select="count(pat:visite)"/>
                    <xsl:choose>
                        <xsl:when test="count(pat:visite) &gt; 1"> visites</xsl:when>
                        <xsl:otherwise> visite</xsl:otherwise>
                    </xsl:choose>
                </span>
            </div>
            <div class="defilement">
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
            </div>
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

    <!-- Le dossier ne garde que l'intitulé : on retrouve le code NGAP en le comparant à acte.xml -->
    <xsl:template match="pat:acte">
        <xsl:variable name="intitule" select="normalize-space(.)"/>
        <xsl:variable name="ref" select="$actes/act:actes/act:acte[normalize-space(.) = $intitule]"/>
        <li>
            <xsl:if test="$ref">
                <xsl:call-template name="code-acte">
                    <xsl:with-param name="ref" select="$ref[1]"/>
                </xsl:call-template>
            </xsl:if>
            <span class="intitule"><xsl:value-of select="$intitule"/></span>
        </li>
    </xsl:template>

</xsl:stylesheet>

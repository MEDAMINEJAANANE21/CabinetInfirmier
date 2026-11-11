<?xml version="1.0" encoding="UTF-8" ?>
<!-- acte.xml → nomenclature des actes avec tarifs (data/html/nomenclature.html) -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:med="http://www.univ-grenoble-alpes.fr/l3miage/medical"
    xmlns:act="http://www.univ-grenoble-alpes.fr/l3miage/actes"
    exclude-result-prefixes="med act">

    <xsl:include href="commun.xsl"/>

    <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat"/>

    <xsl:variable name="minuscules" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="majuscules" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

    <!-- Actes réalisés dans le cabinet, pour compter chaque acte -->
    <xsl:variable name="realises" select="$cabinet/med:patients/med:patient/med:visite/med:acte"/>

    <xsl:template match="/">
        <html lang="fr">
            <xsl:call-template name="entete-html">
                <xsl:with-param name="titre">Nomenclature des actes</xsl:with-param>
                <xsl:with-param name="css">nomenclature.css</xsl:with-param>
            </xsl:call-template>
            <body>
                <xsl:call-template name="barre">
                    <xsl:with-param name="actif">nomenclature</xsl:with-param>
                </xsl:call-template>
                <main class="page">
                    <header class="entete">
                        <p class="surtitre">NGAP, extrait</p>
                        <h1>Nomenclature des actes</h1>
                        <p class="resume">
                            <xsl:value-of select="count(act:ngap/act:actes/act:acte)"/>
                            <xsl:text> actes · </xsl:text>
                            <xsl:value-of select="count(act:ngap/act:types/act:type)"/>
                            <xsl:text> types</xsl:text>
                        </p>
                    </header>

                    <section class="cles" aria-label="Valeur des lettres-clés">
                        <div class="cle">
                            <span class="code">AMI</span>
                            <span>Acte médico-infirmier</span>
                            <span class="cle-valeur"><xsl:call-template name="euros"><xsl:with-param name="centimes" select="$centimesAMI"/></xsl:call-template></span>
                        </div>
                        <div class="cle">
                            <span class="code">AIS</span>
                            <span>Acte infirmier de soins</span>
                            <span class="cle-valeur"><xsl:call-template name="euros"><xsl:with-param name="centimes" select="$centimesAIS"/></xsl:call-template></span>
                        </div>
                        <div class="cle">
                            <span class="code">DI</span>
                            <span>Démarche de soins infirmiers</span>
                            <span class="cle-valeur"><xsl:call-template name="euros"><xsl:with-param name="centimes" select="$centimesDI"/></xsl:call-template></span>
                        </div>
                    </section>

                    <xsl:apply-templates select="act:ngap/act:types/act:type"/>
                </main>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="act:type">
        <xsl:variable name="type" select="@id"/>
        <xsl:variable name="libelle" select="normalize-space(.)"/>
        <xsl:variable name="liste" select="/act:ngap/act:actes/act:acte[@type = $type]"/>
        <section class="carte" id="type-{$type}">
            <div class="carte-titre">
                <h2>
                    <xsl:value-of select="concat(translate(substring($libelle, 1, 1), $minuscules, $majuscules), substring($libelle, 2))"/>
                </h2>
                <span class="meta">
                    <xsl:value-of select="$type"/>
                    <xsl:text> · </xsl:text>
                    <xsl:value-of select="count($liste)"/>
                    <xsl:text> actes</xsl:text>
                </span>
            </div>
            <div class="defilement">
                <table class="nomenclature">
                    <thead>
                        <tr>
                            <th scope="col">Code</th>
                            <th scope="col">Intitulé</th>
                            <th scope="col" class="nombre">Clé</th>
                            <th scope="col" class="nombre">Coef</th>
                            <th scope="col" class="nombre">Tarif</th>
                            <th scope="col" class="nombre">Réalisés</th>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:for-each select="$liste">
                            <xsl:variable name="id" select="@id"/>
                            <xsl:variable name="nb" select="count($realises[@id = $id])"/>
                            <tr>
                                <xsl:if test="$nb &gt; 0"><xsl:attribute name="class">realise</xsl:attribute></xsl:if>
                                <td class="mono"><xsl:value-of select="@id"/></td>
                                <td><xsl:value-of select="normalize-space(.)"/></td>
                                <td class="nombre"><xsl:value-of select="@clé"/></td>
                                <td class="nombre"><xsl:value-of select="translate(@coef, '.', ',')"/></td>
                                <td class="nombre">
                                    <xsl:call-template name="euros">
                                        <xsl:with-param name="centimes">
                                            <xsl:call-template name="centimes-acte">
                                                <xsl:with-param name="ref" select="."/>
                                            </xsl:call-template>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </td>
                                <td class="nombre">
                                    <xsl:choose>
                                        <xsl:when test="$nb &gt; 0"><xsl:value-of select="$nb"/></xsl:when>
                                        <xsl:otherwise><span class="vide">0</span></xsl:otherwise>
                                    </xsl:choose>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </tbody>
                </table>
            </div>
        </section>
    </xsl:template>

</xsl:stylesheet>

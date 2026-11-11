<?xml version="1.0" encoding="UTF-8" ?>
<!-- cabinet.xml → tournée de l'infirmier (data/html/infirmier.html) -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:med="http://www.univ-grenoble-alpes.fr/l3miage/medical"
    xmlns:act="http://www.univ-grenoble-alpes.fr/l3miage/actes"
    exclude-result-prefixes="med act">

    <!-- Navigation, dates, tarifs ; définit aussi $actes (acte.xml) -->
    <xsl:include href="commun.xsl"/>

    <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat"/>

    <!-- Paramètre global : identifiant de l'infirmier dont on affiche la tournée -->
    <xsl:param name="destinedId">001</xsl:param>

    <xsl:variable name="infirmier" select="/med:cabinet/med:infirmiers/med:infirmier[@id = $destinedId]"/>
    <xsl:variable name="patients" select="/med:cabinet/med:patients/med:patient[med:visite/@intervenant = $destinedId]"/>

    <xsl:template match="/">
        <html lang="fr">
            <xsl:call-template name="entete-html">
                <xsl:with-param name="titre">Tournée de l'infirmier</xsl:with-param>
                <xsl:with-param name="css">infirmier.css</xsl:with-param>
            </xsl:call-template>
            <body>
                <xsl:call-template name="barre">
                    <xsl:with-param name="actif">tournee</xsl:with-param>
                </xsl:call-template>
                <main class="page">
                    <header class="entete">
                        <p class="surtitre">
                            <xsl:text>Infirmier </xsl:text>
                            <xsl:value-of select="$infirmier/@id"/>
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
                            <xsl:text> · </xsl:text>
                            <xsl:value-of select="count($patients/med:visite[@intervenant = $destinedId]/med:acte)"/>
                            <xsl:text> actes · </xsl:text>
                            <xsl:call-template name="euros">
                                <xsl:with-param name="centimes">
                                    <xsl:call-template name="centimes-total">
                                        <xsl:with-param name="refs" select="$patients/med:visite[@intervenant = $destinedId]/med:acte"/>
                                    </xsl:call-template>
                                </xsl:with-param>
                            </xsl:call-template>
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
                <!-- Lien vers le dossier du patient, généré sous le nom patient-NIR.html -->
                <h2>
                    <a href="patient-{@numéro}.html">
                        <xsl:value-of select="normalize-space(med:nom)"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="normalize-space(med:prénom)"/>
                    </a>
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
                    <tr>
                        <th scope="col">Date de visite</th>
                        <th scope="col">Actes</th>
                        <th scope="col" class="montant">Tarif</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:apply-templates select="med:visite[@intervenant = $destinedId]"/>
                </tbody>
            </table>

            <footer class="patient-pied">
                <a href="patient-{@numéro}.html">Dossier</a>
                <a href="facture-{@numéro}.html">Facture</a>
            </footer>
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
            <td class="montant">
                <xsl:call-template name="euros">
                    <xsl:with-param name="centimes">
                        <xsl:call-template name="centimes-total">
                            <xsl:with-param name="refs" select="med:acte"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </td>
        </tr>
    </xsl:template>

    <!-- Un acte : code NGAP (id, lettre-clé, coefficient) puis son intitulé -->
    <xsl:template match="med:acte">
        <xsl:variable name="idActeVisite" select="@id"/>
        <xsl:variable name="ref" select="$actes/act:actes/act:acte[@id = $idActeVisite]"/>
        <li>
            <xsl:call-template name="code-acte">
                <xsl:with-param name="ref" select="$ref"/>
            </xsl:call-template>
            <span class="intitule"><xsl:value-of select="normalize-space($ref)"/></span>
        </li>
    </xsl:template>

</xsl:stylesheet>

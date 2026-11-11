<?xml version="1.0" encoding="UTF-8" ?>
<!--
    cabinet.xml → facture d'un patient (data/html/facture-NIR.html).
    Reprend en XSLT ce que data/js/facture.js prévoyait : type, clé, intitulé,
    coefficient et tarif de chaque acte, puis le total.
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:med="http://www.univ-grenoble-alpes.fr/l3miage/medical"
    xmlns:act="http://www.univ-grenoble-alpes.fr/l3miage/actes"
    exclude-result-prefixes="med act">

    <xsl:include href="commun.xsl"/>

    <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat"/>

    <!-- NIR du patient à facturer -->
    <xsl:param name="destinedNir">206049935000375</xsl:param>

    <xsl:variable name="patient" select="/med:cabinet/med:patients/med:patient[@numéro = $destinedNir]"/>

    <xsl:template match="/">
        <html lang="fr">
            <xsl:call-template name="entete-html">
                <xsl:with-param name="titre">Facture</xsl:with-param>
                <xsl:with-param name="css">facture.css</xsl:with-param>
            </xsl:call-template>
            <body>
                <xsl:call-template name="barre"/>
                <main class="page">
                    <header class="entete entete-actions">
                        <div>
                            <p class="surtitre">Facture</p>
                            <h1>
                                <xsl:value-of select="normalize-space($patient/med:prénom)"/>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="normalize-space($patient/med:nom)"/>
                            </h1>
                        </div>
                        <div class="actions">
                            <a class="bouton bouton-secondaire" href="patient-{$destinedNir}.html">Dossier du patient</a>
                            <button class="bouton" type="button" onclick="window.print()">Imprimer</button>
                        </div>
                    </header>

                    <section class="carte">
                        <div class="parties">
                            <div>
                                <h2>Cabinet</h2>
                                <p><xsl:value-of select="$cabinet/med:nom"/></p>
                                <p class="secondaire"><xsl:apply-templates select="$cabinet/med:adresse"/></p>
                                <xsl:for-each select="$cabinet/med:infirmiers/med:infirmier[@id = $patient/med:visite/@intervenant]">
                                    <p class="secondaire">
                                        <xsl:text>Infirmier </xsl:text>
                                        <xsl:value-of select="concat(@prénom, ' ', @nom, ' (', @id, ')')"/>
                                    </p>
                                </xsl:for-each>
                            </div>
                            <div>
                                <h2>Patient</h2>
                                <p>
                                    <xsl:value-of select="normalize-space($patient/med:nom)"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="normalize-space($patient/med:prénom)"/>
                                </p>
                                <p class="secondaire"><xsl:apply-templates select="$patient/med:adresse"/></p>
                                <p class="secondaire mono">NIR <xsl:value-of select="$patient/@numéro"/></p>
                            </div>
                        </div>

                        <div class="defilement">
                            <table class="lignes">
                                <thead>
                                    <tr>
                                        <th scope="col">Date</th>
                                        <th scope="col">Acte</th>
                                        <th scope="col" class="nombre">Clé</th>
                                        <th scope="col" class="nombre">Coef</th>
                                        <th scope="col" class="nombre">Tarif</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <xsl:for-each select="$patient/med:visite/med:acte">
                                        <xsl:variable name="id" select="@id"/>
                                        <xsl:variable name="ref" select="$actes/act:actes/act:acte[@id = $id]"/>
                                        <tr>
                                            <td class="date">
                                                <xsl:call-template name="date">
                                                    <xsl:with-param name="iso" select="../@date"/>
                                                </xsl:call-template>
                                            </td>
                                            <td>
                                                <span class="acte-intitule">
                                                    <span class="mono"><xsl:value-of select="$id"/></span>
                                                    <xsl:text> </xsl:text>
                                                    <xsl:value-of select="normalize-space($ref)"/>
                                                </span>
                                                <span class="acte-type">
                                                    <xsl:call-template name="libelle-type">
                                                        <xsl:with-param name="type" select="$ref/@type"/>
                                                    </xsl:call-template>
                                                </span>
                                            </td>
                                            <td class="nombre"><xsl:value-of select="$ref/@clé"/></td>
                                            <td class="nombre"><xsl:value-of select="translate($ref/@coef, '.', ',')"/></td>
                                            <td class="nombre">
                                                <xsl:call-template name="euros">
                                                    <xsl:with-param name="centimes">
                                                        <xsl:call-template name="centimes-acte">
                                                            <xsl:with-param name="ref" select="$ref"/>
                                                        </xsl:call-template>
                                                    </xsl:with-param>
                                                </xsl:call-template>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                                <tfoot>
                                    <tr>
                                        <th scope="row" colspan="4">Total</th>
                                        <td class="nombre total">
                                            <xsl:call-template name="euros">
                                                <xsl:with-param name="centimes">
                                                    <xsl:call-template name="centimes-total">
                                                        <xsl:with-param name="refs" select="$patient/med:visite/med:acte"/>
                                                    </xsl:call-template>
                                                </xsl:with-param>
                                            </xsl:call-template>
                                        </td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>

                        <p class="note">
                            <xsl:text>Tarif = valeur de la lettre-clé × coefficient. AMI </xsl:text>
                            <xsl:call-template name="euros"><xsl:with-param name="centimes" select="$centimesAMI"/></xsl:call-template>
                            <xsl:text> · AIS </xsl:text>
                            <xsl:call-template name="euros"><xsl:with-param name="centimes" select="$centimesAIS"/></xsl:call-template>
                            <xsl:text> · DI </xsl:text>
                            <xsl:call-template name="euros"><xsl:with-param name="centimes" select="$centimesDI"/></xsl:call-template>
                        </p>
                    </section>
                </main>
            </body>
        </html>
    </xsl:template>

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

</xsl:stylesheet>

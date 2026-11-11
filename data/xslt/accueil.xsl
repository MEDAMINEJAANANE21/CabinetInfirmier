<?xml version="1.0" encoding="UTF-8" ?>
<!-- cabinet.xml → tableau de bord du cabinet (data/html/index.html) -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:med="http://www.univ-grenoble-alpes.fr/l3miage/medical"
    xmlns:act="http://www.univ-grenoble-alpes.fr/l3miage/actes"
    xmlns:exsl="http://exslt.org/common"
    exclude-result-prefixes="med act exsl">

    <xsl:include href="commun.xsl"/>

    <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat"/>

    <!-- Regroupement des actes réalisés par identifiant (méthode de Muench) -->
    <xsl:key name="acte-par-id" match="med:visite/med:acte" use="@id"/>

    <xsl:variable name="tousLesActes" select="/med:cabinet/med:patients/med:patient/med:visite/med:acte"/>

    <xsl:variable name="totalCentimes">
        <xsl:call-template name="centimes-total">
            <xsl:with-param name="refs" select="$tousLesActes"/>
        </xsl:call-template>
    </xsl:variable>

    <!-- Montant de chaque patient, calculé une fois puis trié (exsl:node-set) -->
    <xsl:variable name="montantsRTF">
        <xsl:for-each select="/med:cabinet/med:patients/med:patient">
            <ligne nir="{@numéro}" nom="{normalize-space(med:nom)} {normalize-space(med:prénom)}">
                <xsl:attribute name="centimes">
                    <xsl:call-template name="centimes-total">
                        <xsl:with-param name="refs" select="med:visite/med:acte"/>
                    </xsl:call-template>
                </xsl:attribute>
            </ligne>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="montants" select="exsl:node-set($montantsRTF)/ligne"/>

    <xsl:template match="/">
        <html lang="fr">
            <xsl:call-template name="entete-html">
                <xsl:with-param name="titre">Tableau de bord</xsl:with-param>
                <xsl:with-param name="css">accueil.css</xsl:with-param>
            </xsl:call-template>
            <body>
                <xsl:call-template name="barre">
                    <xsl:with-param name="actif">accueil</xsl:with-param>
                </xsl:call-template>
                <main class="page page-large">
                    <header class="entete">
                        <p class="surtitre"><xsl:apply-templates select="med:cabinet/med:adresse"/></p>
                        <h1>Tableau de bord</h1>
                    </header>

                    <section class="stats" aria-label="Chiffres du cabinet">
                        <div class="stat">
                            <p class="stat-libelle">Patients</p>
                            <p class="stat-valeur"><xsl:value-of select="count(med:cabinet/med:patients/med:patient)"/></p>
                        </div>
                        <div class="stat">
                            <p class="stat-libelle">Visites</p>
                            <p class="stat-valeur"><xsl:value-of select="count(med:cabinet/med:patients/med:patient/med:visite)"/></p>
                        </div>
                        <div class="stat">
                            <p class="stat-libelle">Actes réalisés</p>
                            <p class="stat-valeur"><xsl:value-of select="count($tousLesActes)"/></p>
                        </div>
                        <div class="stat">
                            <p class="stat-libelle">Montant facturable</p>
                            <p class="stat-valeur">
                                <xsl:call-template name="euros">
                                    <xsl:with-param name="centimes" select="$totalCentimes"/>
                                </xsl:call-template>
                            </p>
                        </div>
                    </section>

                    <div class="grille">
                        <section class="carte carte-principale">
                            <div class="carte-titre">
                                <h2>Montant par patient</h2>
                                <span class="meta">tarifs NGAP</span>
                            </div>
                            <xsl:variable name="max">
                                <xsl:for-each select="$montants">
                                    <xsl:sort select="@centimes" data-type="number" order="descending"/>
                                    <xsl:if test="position() = 1"><xsl:value-of select="@centimes"/></xsl:if>
                                </xsl:for-each>
                            </xsl:variable>
                            <ol class="barres">
                                <xsl:for-each select="$montants">
                                    <xsl:sort select="@centimes" data-type="number" order="descending"/>
                                    <li>
                                        <xsl:if test="position() = 1"><xsl:attribute name="class">premier</xsl:attribute></xsl:if>
                                        <div class="barre-ligne">
                                            <a href="facture-{@nir}.html"><xsl:value-of select="@nom"/></a>
                                            <span class="barre-valeur">
                                                <xsl:call-template name="euros">
                                                    <xsl:with-param name="centimes" select="@centimes"/>
                                                </xsl:call-template>
                                            </span>
                                        </div>
                                        <div class="barre-piste">
                                            <div class="barre-remplie" style="width: {round(@centimes * 100 div $max)}%"></div>
                                        </div>
                                    </li>
                                </xsl:for-each>
                            </ol>
                        </section>

                        <aside class="colonne">
                            <section class="carte">
                                <h2>Actes les plus réalisés</h2>
                                <ol class="classement">
                                    <xsl:for-each select="$tousLesActes[generate-id() = generate-id(key('acte-par-id', @id)[1])]">
                                        <xsl:sort select="count(key('acte-par-id', @id))" data-type="number" order="descending"/>
                                        <xsl:sort select="@id"/>
                                        <xsl:variable name="id" select="@id"/>
                                        <xsl:variable name="ref" select="$actes/act:actes/act:acte[@id = $id]"/>
                                        <li>
                                            <xsl:call-template name="code-acte">
                                                <xsl:with-param name="ref" select="$ref"/>
                                            </xsl:call-template>
                                            <span class="classement-texte"><xsl:value-of select="normalize-space($ref)"/></span>
                                            <span class="meta">× <xsl:value-of select="count(key('acte-par-id', @id))"/></span>
                                        </li>
                                    </xsl:for-each>
                                </ol>
                            </section>

                            <section class="carte">
                                <h2>Équipe</h2>
                                <ul class="equipe">
                                    <xsl:for-each select="med:cabinet/med:infirmiers/med:infirmier">
                                        <xsl:variable name="id" select="@id"/>
                                        <li>
                                            <span class="initiales" aria-hidden="true">
                                                <xsl:value-of select="translate(substring(@prénom, 1, 1), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
                                                <xsl:value-of select="translate(substring(@nom, 1, 1), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
                                            </span>
                                            <span>
                                                <a href="infirmier.html"><xsl:value-of select="concat(@prénom, ' ', @nom)"/></a>
                                                <span class="meta">
                                                    <xsl:text>Infirmier </xsl:text>
                                                    <xsl:value-of select="@id"/>
                                                    <xsl:text> · </xsl:text>
                                                    <xsl:value-of select="count(/med:cabinet/med:patients/med:patient[med:visite/@intervenant = $id])"/>
                                                    <xsl:text> patients</xsl:text>
                                                </span>
                                            </span>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </section>
                        </aside>
                    </div>

                    <section class="carte">
                        <div class="carte-titre">
                            <h2>Visites</h2>
                            <span class="meta">de la plus récente à la plus ancienne</span>
                        </div>
                        <div class="defilement">
                            <table class="visites">
                                <thead>
                                    <tr>
                                        <th scope="col">Date</th>
                                        <th scope="col">Patient</th>
                                        <th scope="col">Intervenant</th>
                                        <th scope="col">Actes</th>
                                        <th scope="col" class="montant">Tarif</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <xsl:for-each select="med:cabinet/med:patients/med:patient/med:visite">
                                        <xsl:sort select="@date" order="descending"/>
                                        <xsl:variable name="intervenant" select="@intervenant"/>
                                        <xsl:variable name="inf" select="/med:cabinet/med:infirmiers/med:infirmier[@id = $intervenant]"/>
                                        <tr>
                                            <td class="date">
                                                <xsl:call-template name="date">
                                                    <xsl:with-param name="iso" select="@date"/>
                                                </xsl:call-template>
                                            </td>
                                            <td>
                                                <a href="patient-{../@numéro}.html">
                                                    <xsl:value-of select="concat(normalize-space(../med:nom), ' ', normalize-space(../med:prénom))"/>
                                                </a>
                                            </td>
                                            <td><xsl:value-of select="concat($inf/@prénom, ' ', $inf/@nom)"/></td>
                                            <td>
                                                <span class="codes">
                                                    <xsl:for-each select="med:acte">
                                                        <xsl:variable name="id" select="@id"/>
                                                        <xsl:call-template name="code-acte">
                                                            <xsl:with-param name="ref" select="$actes/act:actes/act:acte[@id = $id]"/>
                                                        </xsl:call-template>
                                                    </xsl:for-each>
                                                </span>
                                            </td>
                                            <td class="montant">
                                                <a href="facture-{../@numéro}.html">
                                                    <xsl:call-template name="euros">
                                                        <xsl:with-param name="centimes">
                                                            <xsl:call-template name="centimes-total">
                                                                <xsl:with-param name="refs" select="med:acte"/>
                                                            </xsl:call-template>
                                                        </xsl:with-param>
                                                    </xsl:call-template>
                                                </a>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                            </table>
                        </div>
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
    </xsl:template>

</xsl:stylesheet>

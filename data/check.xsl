<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:param name="conf"/>
    <xsl:param name="debug"/>
    <xsl:variable name="prof" select="/"/>
    <xsl:template match="/">
        <html>
            <head>
                <title>
                    <xsl:text>VLO mapping for profile </xsl:text>
                    <xsl:value-of select="/CMD_ComponentSpec/Header/Name"/>
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="/CMD_ComponentSpec/Header/ID"/>
                    <xsl:text>)</xsl:text>
                </title>
            </head>
            <body>
                <h1>
                    <a href="index.html">VLO mapping</a>
                    <xsl:text> for profile </xsl:text>
                    <xsl:value-of select="/CMD_ComponentSpec/Header/Name"/>
                    <xsl:text> (</xsl:text>
                    <a href="$registry$/rest/registry/profiles/{/CMD_ComponentSpec/Header/ID}/xml">
                        <xsl:value-of select="/CMD_ComponentSpec/Header/ID"/>
                    </a>
                    <xsl:text>)</xsl:text>
                </h1>
                <dl>
                    <xsl:apply-templates select="$conf//facetConcept"/>
                </dl>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="facetConcept">
        <xsl:variable name="facet" select="."/>
        <dt>
            <xsl:text>Facet: </xsl:text>
            <xsl:value-of select="@name"/>
        </dt>
        <dd>
            <dl>
                <xsl:variable name="concepts" select="concept"/>
                <xsl:for-each-group select="$prof//*[@ConceptLink = $concepts]" group-by="@ConceptLink">
                    <dt>
                        <xsl:text>Matched CMD Element ConceptLink: </xsl:text>
                        <a href="{current-grouping-key()}">
                            <xsl:value-of select="current-grouping-key()"/>
                        </a>
                    </dt>
                    <dd>
                        <dl>
                            <xsl:for-each select="current-group()">
                                <xsl:variable name="leaf" select="."/>
                                <dt>
                                    <xsl:text>/c:CMD/c:Components/c:</xsl:text>
                                    <xsl:value-of select="string-join(ancestor-or-self::*/@name, '/c:')"/>
                                    <xsl:text>/text()</xsl:text>
                                </dt>
                                <dd>
                                    <xsl:choose>
                                        <xsl:when test="exists($facet/acceptableContext) or exists($facet/rejectableContext)">
                                            <xsl:variable name="ac" select="$facet/acceptableContext"/>
                                            <!--<xsl:variable name="context" select="($leaf/ancestor::*/@ConceptLink)[last()]"/>-->
                                            <xsl:variable name="context" select="$leaf/ancestor::*[normalize-space(@ConceptLink) != ''][1]/@ConceptLink"/>
                                            <xsl:if test="$debug = 't'">
                                                <xsl:message>!DEBUG: path: <xsl:value-of select="string-join(ancestor-or-self::*/@name, '/c:')"/></xsl:message>
                                                <xsl:message>!DEBUG: concept: <xsl:value-of select="current-grouping-key()"/></xsl:message>
                                                <xsl:message>!DEBUG: context(s): <xsl:value-of select="string-join($leaf/ancestor::*/@ConceptLink, ', ')"/></xsl:message>
                                                <xsl:message>!DEBUG: parent context: <xsl:value-of select="$context"/></xsl:message>
                                            </xsl:if>
                                            <p>
                                                <xsl:text>Context: </xsl:text>
                                                <xsl:choose>
                                                    <xsl:when test="normalize-space($context) != ''">
                                                        <a href="{$context}">
                                                            <xsl:value-of select="$context"/>
                                                        </a>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:text>empty</xsl:text>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </p>
                                            <xsl:choose>
                                                <xsl:when test="normalize-space($context) = '' and (empty($ac/@includeEmpty) or ($ac/@includeEmpty = 'true'))">
                                                    <xsl:text>xpath accepted (empty context accepted)</xsl:text>
                                                </xsl:when>
                                                <xsl:when test="$context = $ac/concept">
                                                    <xsl:text>xpath accepted (acceptable context)</xsl:text>
                                                </xsl:when>
                                                <xsl:when test="exists($facet/rejectableContext)">
                                                    <xsl:variable name="rc" select="$facet/rejectableContext"/>
                                                    <xsl:choose>
                                                        <xsl:when test="normalize-space($context) = '' and ($rc/@includeEmpty = 'true')">
                                                            <xsl:text>xpath rejected (empty context rejected)</xsl:text>
                                                        </xsl:when>
                                                        <xsl:when test="$context = $rc/concept">
                                                            <xsl:text>xpath rejected (rejectable context)</xsl:text>
                                                        </xsl:when>
                                                        <xsl:when test="(empty($rc/@includeAny) or ($rc/@includeAny = 'true'))">
                                                            <xsl:text>xpath rejected (any context rejected)</xsl:text>
                                                        </xsl:when>
                                                        <xsl:when test="$ac/@includeAny = 'true'">
                                                            <xsl:text>xpath accepted (any context, which is not rejected, accepted)</xsl:text>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:text>xpath rejected (implicit)</xsl:text>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:text>xpath rejected (implicit)</xsl:text>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>xpath accepted</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </dd>
                            </xsl:for-each>
                        </dl>
                    </dd>
                </xsl:for-each-group>
            </dl>
        </dd>
    </xsl:template>
</xsl:stylesheet>

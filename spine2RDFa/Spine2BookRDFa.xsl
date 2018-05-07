<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:xlink="http://www.w3.org/1999/xlink" version="1.0" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:spine="http://diglib.hab.de/rules/schema/emblem"
  exclude-result-prefixes="xsl xsi html xlink mods spine">
  <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
  <xsl:variable name="BookUri">
    <xsl:choose>
      <xsl:when test="/spine:biblioDesc/mods:mods/mods:location/mods:url/@usage='primary display'">
        <xsl:value-of select="/spine:biblioDesc/mods:mods/mods:location/mods:url[@usage='primary display']"/>
      </xsl:when>
      <xsl:when test="//mods:mods/mods:identifier/@type='purl'">
        <xsl:value-of select="//mods:mods/mods:identifier[@type='purl']"/>
      </xsl:when>
      <xsl:when test="//mods:mods/mods:location/mods:url">
        <xsl:value-of select="//mods:mods/mods:location/mods:url"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:template match="/">
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;&#0010;</xsl:text>
    <html>
      <head>
        <title>Book Information</title>
        <meta charset="UTF-8"/>
        <style type="text/css">
          .table { display: table; padding: 7px; }
          .row { display: table-row; }
          .col-sm-3 { display: table-cell; padding: 7px; width: 25%; }
          .col-sm-9 { display: table-cell; padding: 7px; }
          ul { padding-left:17px; }
        </style>
      </head>
      <body>
        <xsl:apply-templates select="//mods:mods"/>        
      </body>
    </html>
  </xsl:template>
  <xsl:template match="mods:mods">
    <div class="table" prefix="s: http://schema.org/" typeof="s:Book" resource="{$BookUri}">
      <meta property="s:additionalType" content="http://schema.org/Product"/>
      <div class="row">
        <div class="col-sm-3">
          <span>
            <b>Title</b>
          </span>
        </div>
        <div class="col-sm-9">
          <span property="s:name">
            <xsl:value-of select="mods:titleInfo/mods:title"/>
            <xsl:value-of select="mods:titleInfo/mods:subTitle"/>
          </span>
        </div>
      </div>
      <xsl:if test="mods:name">
        <div class="row">
          <div class="col-sm-3">
            <span>
              <b>Authors and contributors</b>
            </span>
          </div>
          <div class="col-sm-9">
            <ul>
              <xsl:for-each select="mods:name">
                <xsl:element name="li">
                  <xsl:attribute name="class">name</xsl:attribute>
                  <xsl:choose>
                    <xsl:when test="position()=1">
                      <!-- arguably we should test for usage="primary" -->
                      <xsl:attribute name="property">s:author</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:attribute name="property">s:contributor</xsl:attribute>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:choose>
                    <xsl:when test="./@type='personal'">
                      <xsl:attribute name="typeof">s:Person</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:attribute name="typeof">s:Organization</xsl:attribute>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:if test="./@valueURI">
                    <xsl:attribute name="resource">
                      <xsl:value-of select="./@valueURI"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:element name="span">
                    <xsl:if test="not(./@valueURI)">
                      <xsl:attribute name="property">s:name</xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="mods:namePart[1]"/>
                    <xsl:if test="mods:namePart[2]">
                      <xsl:text>, </xsl:text>
                      <xsl:value-of select="mods:namePart[2]"/>
                    </xsl:if>
                    <xsl:text>. </xsl:text>
                  </xsl:element>
                  <xsl:if test="./mods:role/mods:roleTerm">
                    <xsl:element name="span">
                      <xsl:attribute name="property">s:jobTitle</xsl:attribute>
                      <xsl:value-of select="./mods:role/mods:roleTerm"/>
                    </xsl:element>
                  </xsl:if>
                </xsl:element>
              </xsl:for-each>
            </ul>
          </div>
        </div>
      </xsl:if>
      <xsl:if test="mods:originInfo/mods:publisher">
        <div class="row">
          <div class="col-sm-3">
            <span>
              <b>Publisher</b>
            </span>
          </div>
          <div class="col-sm-9" property="s:publisher" typeof="s:Organization">
            <span property="s:name">
              <xsl:value-of select="mods:originInfo/mods:publisher"/>
            </span>
          </div>
        </div>
      </xsl:if>
      <xsl:for-each select="mods:originInfo/mods:place/mods:placeTerm">
        <xsl:choose>
          <xsl:when test="./@type='code'">
            <xsl:text>&#0010;</xsl:text>
            <xsl:element name="span">
              <xsl:attribute name="style">display:none</xsl:attribute>
              <xsl:attribute name="property">s:locationCreated</xsl:attribute>
              <xsl:if test="./@valueURI">
                <xsl:attribute name="resource">
                  <xsl:value-of select="./@valueURI"/>
                </xsl:attribute>
                <xsl:attribute name="typeof">s:Place</xsl:attribute>
              </xsl:if>
              <xsl:value-of select="."/>
            </xsl:element>
            <xsl:text>&#0010;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <div class="row">
              <div class="col-sm-3">
                <span>
                  <b>Place of Publication</b>
                </span>
              </div>
              <div class="col-sm-9">
                <xsl:element name="span">
                  <xsl:attribute name="property">s:locationCreated</xsl:attribute>
                  <xsl:if test="./@valueURI">
                    <xsl:attribute name="resource">
                      <xsl:value-of select="./@valueURI"/>
                    </xsl:attribute>
                    <xsl:attribute name="typeof">s:Place</xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="."/>
                </xsl:element>
              </div>
            </div>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:for-each>
      <xsl:if test="mods:originInfo/mods:dateIssued">
        <xsl:variable name="dateIssuedValue">
          <xsl:value-of select="mods:originInfo/mods:dateIssued"/>
        </xsl:variable>
        <div class="row">
          <div class="col-sm-3">
            <span>
              <b>Publication Date</b>
            </span>
          </div>
          <div class="col-sm-9">
            <span property="s:datePublished" content="{$dateIssuedValue}">
              <xsl:value-of select="mods:originInfo/mods:dateIssued"/>
            </span>
          </div>
        </div>
      </xsl:if>
      <xsl:if test="mods:physicalDescription">
        <div class="row">
          <div class="col-sm-3">
            <span>
              <b>Physical Description</b>
            </span>
          </div>
          <div class="col-sm-9">
            <xsl:choose>
              <xsl:when test="count(mods:physicalDescription) = 1">
                <span property="s:description">
                  <xsl:value-of select="normalize-space(mods:physicalDescription)"/>
                </span>
              </xsl:when>
              <xsl:otherwise>
                <ul>
                  <xsl:for-each select="mods:physicalDescription">
                    <xsl:for-each select="./*">
                      <li property="s:description">
                        <xsl:value-of select="normalize-space(.)"/>
                      </li>
                    </xsl:for-each>
                  </xsl:for-each>
                </ul>
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </div>
      </xsl:if>

      <xsl:if test="mods:language/mods:languageTerm">
        <div class="row">
          <div class="col-sm-3">
            <span>
              <b>Language</b>
            </span>
          </div>
          <div class="col-sm-9">
            <ul>
              <xsl:for-each select="mods:language/mods:languageTerm">
                <xsl:variable name="LangUri">http://id.loc.gov/vocabulary/iso639-2/<xsl:value-of
                    select="."/></xsl:variable>
                <li property="s:inLanguage" resource="{$LangUri}" typeof="s:Language">
                  <xsl:value-of select="."/>
                </li>
              </xsl:for-each>
            </ul>
          </div>
        </div>
      </xsl:if>

      <xsl:if test="mods:subject">
        <div class="row">
          <div class="col-sm-3">
            <span>
              <b>Subjects</b>
            </span>
          </div>
          <div class="col-sm-9">
            <ul>
              <xsl:for-each select="mods:subject">
                <xsl:element name="li">
                  <xsl:attribute name="property">s:about</xsl:attribute>
                  <xsl:choose>
                    <xsl:when test="local-name(./child::*[1])='name'">
                      <xsl:choose>
                        <xsl:when test="./mods:name/@valueURI">
                            <xsl:attribute name="resource">
                              <xsl:value-of select="./mods:name/@valueURI"/>
                            </xsl:attribute>
                            <xsl:choose>
                              <xsl:when test="./mods:name/@type='personal'">
                                <xsl:attribute name="typeof">s:Person</xsl:attribute>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:attribute name="typeof">s:Organization</xsl:attribute>
                              </xsl:otherwise>
                            </xsl:choose>
                            <xsl:for-each select="./mods:name/child::*">
                              <xsl:value-of select="."/>
                              <xsl:if test="position()!=last()">
                                <xsl:text> </xsl:text>
                              </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:for-each select="./mods:name/child::*">
                            <xsl:value-of select="."/>
                            <xsl:if test="position()!=last()">
                              <xsl:text> </xsl:text>
                            </xsl:if>
                          </xsl:for-each>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:when test="local-name(./child::*[1])='hierarchicalGeographic'">
                      <xsl:if test="./mods:hierarchicalGeographic/@valueURI">
                        <xsl:attribute name="resource">
                          <xsl:value-of select="./mods:hierarchicalGeographic/@valueURI"/>
                        </xsl:attribute>
                      </xsl:if>
                      <xsl:for-each select="./mods:hierarchicalGeographic/child::*">
                        <xsl:value-of select="."/>
                        <xsl:if test="position()!=last()">
                          <xsl:text> </xsl:text>
                        </xsl:if>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:if test="./@valueURI">
                        <xsl:attribute name="resource">
                          <xsl:value-of select="./@valueURI"/>
                        </xsl:attribute>
                        <xsl:attribute name="typeof">s:Intangible</xsl:attribute>
                      </xsl:if>
                      <xsl:for-each select="./child::*">
                        <xsl:value-of select="."/>
                        <xsl:if test="position()!=last()">
                          <xsl:text> -- </xsl:text>
                        </xsl:if>
                      </xsl:for-each>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:element>
              </xsl:for-each>
            </ul>
          </div>
        </div>
      </xsl:if>

      <xsl:if test="mods:note">
        <div class="row">
          <div class="col-sm-3">
            <span>
              <b>Notes</b>
            </span>
          </div>
          <div class="col-sm-9">
            <ul>
              <xsl:for-each select="mods:note">
                <li property="s:description">
                  <xsl:value-of select="."/>
                </li>
              </xsl:for-each>
            </ul>
          </div>
        </div>
      </xsl:if>

      <xsl:if test="mods:location/mods:url or mods:mods/mods:identifier[@type='purl']"/>
      <div class="row">
        <div class="col-sm-3">
          <span>
            <b>Links</b>
          </span>
        </div>
        <div class="col-sm-9">
          <xsl:choose>
            <xsl:when test="mods:location/mods:url">
              <ul>
                <xsl:for-each select="mods:location/mods:url">
                  <xsl:if
                    test="./@displayLabel != 'Full text - UIUC' and ./@displayLabel != 'Full Text - UIUC'">
                    <li>
                      <a>
                        <xsl:attribute name="property">s:url</xsl:attribute>
                        <xsl:attribute name="href">
                          <xsl:value-of select="."/>
                        </xsl:attribute>
                        <xsl:choose>
                          <xsl:when test="./@displayLabel = 'Full text - OCA'">
                            <xsl:text>Internet Archive</xsl:text>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="./@displayLabel"/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </a>
                    </li>
                  </xsl:if>
                </xsl:for-each>
              </ul>
            </xsl:when>
            <xsl:otherwise>
              <ul>
                <xsl:for-each select="mods:identifier[@type='purl']">
                  <li>
                    <a>
                      <xsl:attribute name="property">s:url</xsl:attribute>
                      <xsl:attribute name="href">
                        <xsl:value-of select="."/>
                      </xsl:attribute>
                      <xsl:value-of select="."/>
                    </a>
                  </li>
                </xsl:for-each>
              </ul>
            </xsl:otherwise>
          </xsl:choose>
        </div>
      </div>
    </div>
  </xsl:template>
</xsl:stylesheet>

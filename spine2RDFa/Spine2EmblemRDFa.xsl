<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:xlink="http://www.w3.org/1999/xlink" version="2.0" xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdf2="http://www.w3.org/1999/02/22-rdf-syntax-ns"
  xmlns:emblem="http://diglib.hab.de/rules/schema/emblem"
  xmlns:skos="http://www.w3.org/2004/02/skos/core#"
  exclude-result-prefixes="xsl xsi xlink html rdf rdf2 mods emblem skos">
  <xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
  <xsl:template match="/">
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;&#0010;</xsl:text>
    <html>
      <head>
        <title>Emblem Information</title>
        <meta charset="UTF-8"/>
        <style type="text/css">
          .table { display: table; padding: 7px; }
          .row { display: table-row; }
          .col-sm-3 { display: table-cell; padding: 7px; width: 25%; }
          .col-sm-9 { display: table-cell; padding: 7px; }
          .emptySpan { display:none; }
        </style>
      </head>
      <body>                
        <xsl:apply-templates select="//emblem:emblem"/>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="emblem:emblem">
    <div class="table" prefix="s: http://schema.org/ e: http://emblematica.library.illinois.edu/schemas/emb/"
      typeof="s:CreativeWork">
      <xsl:attribute name="resource">
        <xsl:value-of select="@globalID"/>
      </xsl:attribute>
      <xsl:variable name="emblemID">
        <xsl:value-of select="substring-after(@globalID, 'http://hdl.handle.net/10111/EmblemRegistry:')"></xsl:value-of>
      </xsl:variable>
      <span class="emptySpan" property="s:additionalType" resource="http://emblematica.library.illinois.edu/schemas/emb/Emblem">&#0160;</span>
      <span class="emptySpan" property="s:sameAs"
        resource="http://emblematica.library.illinois.edu/detail/emblem/{$emblemID}">&#0160;</span>
      <span class="emptySpan" property="s:associatedMedia" resource="{@xlink:href}">&#0160;</span>
      <div id="descriptors" class="row" property="s:hasPart" typeof="s:CreativeWork">
        <span class="emptySpan" property="s:additionalType" resource="http://emblematica.library.illinois.edu/schemas/emb/Pictura">&#0160;</span>
        <span class="emptySpan" property="s:associatedMedia" resource="{emblem:pictura/@xlink:href}">&#0160;</span>
        <xsl:choose>
          <xsl:when test="count(emblem:pictura/emblem:iconclass) = 0">
            <div class="col-sm-12">
              <span class="font-20">No available descriptors for this emblem (Iconclass Headings)</span>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <div class="col-sm-3 label">
              <span class="font-20">Descriptors for this Emblem (Iconclass Headings)</span>
            </div>
            <div class="col-sm-9">
              <xsl:for-each select="emblem:pictura/emblem:iconclass">
                <xsl:element name="p">
                  <xsl:attribute name="class">iconclass</xsl:attribute>
                  <xsl:attribute name="property">s:about</xsl:attribute>
                  <xsl:attribute name="id">
                    <xsl:value-of select="concat('iconclass-', position())"/>
                  </xsl:attribute>
                  <xsl:variable name="uriEncodedOpenParenthesis">
                    <xsl:call-template name="string-replace-all">
                      <xsl:with-param name="text" select="skos:notation" />
                      <xsl:with-param name="replace">(</xsl:with-param>
                      <xsl:with-param name="by">%28</xsl:with-param>
                    </xsl:call-template>
                  </xsl:variable>
                  <xsl:variable name="uriEncodedCloseParenthesis">
                    <xsl:call-template name="string-replace-all">
                      <xsl:with-param name="text" select="$uriEncodedOpenParenthesis" />
                      <xsl:with-param name="replace">)</xsl:with-param>
                      <xsl:with-param name="by">%29</xsl:with-param>
                    </xsl:call-template>
                  </xsl:variable>
                  <xsl:variable name="uriEncodedNotation">
                    <xsl:call-template name="string-replace-all">
                      <xsl:with-param name="text" select="$uriEncodedCloseParenthesis" />
                      <xsl:with-param name="replace" xml:space="preserve"> </xsl:with-param>
                      <xsl:with-param name="by">%20</xsl:with-param>
                    </xsl:call-template>
                  </xsl:variable>
                  <xsl:attribute name="resource"><xsl:value-of select="concat('http://iconclass.org/',$uriEncodedNotation)"/></xsl:attribute>
                  <xsl:value-of select="skos:notation"/>
                </xsl:element>
              </xsl:for-each>
            </div>
          </xsl:otherwise>  
        </xsl:choose>
      </div>
      <div id="motto-transcriptions" class="row">
        <div class="col-sm-3 label">
          <span class="font-20">Motto Transcriptions</span>
        </div>
        <xsl:for-each select="emblem:motto/emblem:transcription">
          <xsl:if test="normalize-space(string(.)) != ''">
            <div class="font-16" property="s:hasPart" typeof="s:CreativeWork">
              <span class="emptySpan" property="s:additionalType" resource="http://emblematica.library.illinois.edu/schemas/emb/EmblemTextPart">&#0160;</span>
              <span class="emptySpan" property="s:additionalType" resource="http://emblematica.library.illinois.edu/schemas/emb/Motto">&#0160;</span>
              <xsl:choose>
                <xsl:when test="@xml:lang  = 'de'">
                  <div class="col-sm-3">
                    <span class="indent" property="s:inLanguage" content="{@xml:lang}">
                      <xsl:text>German (Original): </xsl:text>
                    </span>
                  </div>
                  <div class="col-sm-9" property="s:text">
                    <xsl:value-of select="normalize-space(text()[1])"/>
                  </div>
                  <xsl:if test="emblem:normalisation">
                    <div class="col-sm-3" >
                      <span class="indent">
                        <xsl:text>German (Normalized): </xsl:text>
                      </span>
                    </div>
                    <div class="col-sm-9" property="e:normalizedText">
                      <xsl:value-of select="normalize-space(emblem:normalisation/text())"/>
                    </div>
                  </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:if test="@xml:lang">
                    <div class="col-sm-3" property="s:inLanguage" content="{@xml:lang}">
                      <span class="indent">
                        <xsl:choose>
                          <xsl:when test="@xml:lang  = 'la'">Latin</xsl:when>
                          <xsl:when test="@xml:lang  = 'en'">English</xsl:when>
                          <xsl:when test="@xml:lang  = 'nl'">Dutch</xsl:when>
                          <xsl:when test="@xml:lang  = 'it'">Italian</xsl:when>
                          <xsl:when test="@xml:lang  = 'fr'">French</xsl:when>
                          <xsl:when test="@xml:lang  = 'el'">Greek</xsl:when>
                          <xsl:when test="@xml:lang  = 'es'">Spanish</xsl:when>
                        </xsl:choose>
                        <xsl:text>: </xsl:text>
                      </span>
                    </div>
                  </xsl:if>
                  <div class="col-sm-9" property="s:text">
                    <xsl:value-of select="text()"/>
                  </div>
                </xsl:otherwise>
              </xsl:choose>
            </div>
          </xsl:if>
        </xsl:for-each>
      </div>
      <div class="row">
        <div class="col-sm-3">
          <span class="font-20">Persistent Link:</span>
        </div>
        <div class="col-sm-9">
          <a class="font-16">
            <xsl:attribute name="href">
              <xsl:value-of select="@globalID"/>
            </xsl:attribute>
            <xsl:value-of select="@globalID"/>
          </a>
        </div>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template name="string-replace-all">
    <xsl:param name="text" />
    <xsl:param name="replace" xml:space="preserve" />
    <xsl:param name="by" />
    <xsl:choose>
      <xsl:when test="$text = '' or $replace = '' or not($replace)" >
        <xsl:value-of select="$text" />
      </xsl:when>
      <xsl:when test="contains($text, $replace)">
        <xsl:value-of select="substring-before($text,$replace)" />
        <xsl:value-of select="$by" />
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text" select="substring-after($text,$replace)" />
          <xsl:with-param name="replace" select="$replace" />
          <xsl:with-param name="by" select="$by" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>

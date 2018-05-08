<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="marc"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns="http://purl.org/dc/elements/1.1/">
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  <xsl:template match="/">
    <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns="http://purl.org/dc/elements/1.1/">
      <xsl:attribute name="schemaLocation" namespace="http://www.w3.org/2001/XMLSchema-instance"
        >http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd</xsl:attribute>
      <xsl:if test="/marc:record/marc:datafield[@tag=245]">
        <xsl:element name="title" namespace="http://purl.org/dc/elements/1.1/">
          <xsl:value-of select="/marc:record/marc:datafield[@tag=245][1]/marc:subfield[@code='a']"/>
        </xsl:element>
      </xsl:if>
      <xsl:for-each select="//marc:datafield[@tag=100] | //marc:datafield[@tag=110] | //marc:datafield[@tag=111] | 
        //marc:datafield[@tag=700] | //marc:datafield[@tag=710] | //marc:datafield[@tag=711] | //marc:datafield[@tag=720]">
        <xsl:element name="creator" namespace="http://purl.org/dc/elements/1.1/">
          <xsl:value-of select="marc:subfield[@code='a']"/></xsl:element>
      </xsl:for-each>
      <xsl:for-each select="marc:record/marc:datafield[500 &lt;= @tag and @tag &lt;= 599][not(@tag=506 
        or @tag=530 or @tag=540 or @tag=546)]">
        <xsl:element name="description" namespace="http://purl.org/dc/elements/1.1/">
          <xsl:value-of select="marc:subfield[@code='a']"/></xsl:element>
      </xsl:for-each>
      <xsl:for-each select="//marc:datafield[@tag=600] | //marc:datafield[@tag=610] | //marc:datafield[@tag=611] | 
        //marc:datafield[@tag=630] | //marc:datafield[@tag=650] | //marc:datafield[@tag=653] ">
        <xsl:element name="subject" namespace="http://purl.org/dc/elements/1.1/">
          <xsl:value-of select="marc:subfield[@code='a']"/></xsl:element>
      </xsl:for-each>
      <xsl:for-each select="//marc:datafield[@tag=020] | //marc:datafield[@tag=022] | //marc:datafield[@tag=024]">
        <xsl:element name="identifier" namespace="http://purl.org/dc/elements/1.1/">
          <xsl:value-of select="marc:subfield[@code='a'] | marc:subfield[@code='z']"/></xsl:element>
      </xsl:for-each>
      <xsl:for-each select="marc:record/marc:datafield[@tag=856]/marc:subfield[@code='u']">
        <xsl:element name="identifier" namespace="http://purl.org/dc/elements/1.1/">
          <xsl:value-of select="."/></xsl:element>
      </xsl:for-each>
      <xsl:for-each select="marc:record/marc:datafield[@tag=260]">
        <xsl:element name="publisher" namespace="http://purl.org/dc/elements/1.1/">
          <xsl:value-of select="concat(marc:subfield[@code='a'], ' ', marc:subfield[@code='b'])"/>
        </xsl:element>
      </xsl:for-each>
      <xsl:if test="string-length(marc:record/marc:controlfield[@tag=008]/text()) &gt; 37">
        <xsl:element name="language" namespace="http://purl.org/dc/elements/1.1/">
          <xsl:value-of select="substring(marc:record/marc:controlfield[@tag=008],36,3)"/>
        </xsl:element>
      </xsl:if>
      <xsl:element name="date" namespace="http://purl.org/dc/elements/1.1/">
        <xsl:choose>
          <xsl:when test="marc:record/marc:datafield[@tag='260']/marc:subfield[@code='c']">
            <xsl:value-of select="marc:record/marc:datafield[@tag='260']/marc:subfield[@code='c']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="substring(marc:record/marc:controlfield[@tag=008],8,4)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:apply-templates select="/marc:record/marc:leader"/>
    </oai_dc:dc>
  </xsl:template>
  <xsl:template match="/marc:record/marc:leader">
    <xsl:element name="type" namespace="http://purl.org/dc/elements/1.1/">
      <xsl:choose>
        <xsl:when test="substring(.,7,1)='a' or substring(.,7,1)='t'">text</xsl:when>
        <xsl:when test="substring(.,7,1)='e' or substring(.,7,1)='f'">cartographic</xsl:when>
        <xsl:when test="substring(.,7,1)='c' or substring(.,7,1)='d'">notated music</xsl:when>
        <xsl:when test="substring(.,7,1)='i' or substring(.,7,1)='j'">sound recording</xsl:when>
        <xsl:when test="substring(.,7,1)='k'">still image</xsl:when>
        <xsl:when test="substring(.,7,1)='g'">moving image</xsl:when>
        <xsl:when test="substring(.,7,1)='r'">three dimensional object</xsl:when>
        <xsl:when test="substring(.,7,1)='m'">software, multimedia</xsl:when>
        <xsl:when test="substring(.,7,1)='p'">mixed material</xsl:when>
      </xsl:choose>                
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
  <xsl:output method="xhtml" omit-xml-declaration="yes" include-content-type="no"/>
  <xsl:template match="/">
    <xsl:element name="html" namespace="http://www.w3.org/1999/xhtml">
      <xsl:element name="head" namespace="http://www.w3.org/1999/xhtml">
        <xsl:element name="title" namespace="http://www.w3.org/1999/xhtml">Names from MARC</xsl:element>
      </xsl:element>
      <xsl:element name="body" namespace="http://www.w3.org/1999/xhtml">
        <xsl:element name="h3" namespace="http://www.w3.org/1999/xhtml">Personal Names (Main &amp; Added Entry)</xsl:element> 
        <xsl:apply-templates select='//marc:datafield[@tag = "100" or @tag = "700"]'/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <xsl:template match='//marc:datafield[@tag = "100" or @tag = "700"]'>
    <xsl:element name="h4" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="style">font-style:italic; color:red</xsl:attribute>
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>

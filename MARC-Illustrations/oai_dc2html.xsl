<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="oai_dc dc"  
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:dc="http://purl.org/dc/elements/1.1/" 
  xmlns="http://www.w3.org/1999/xhtml">
  <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
  <xsl:template match="/">
    <xsl:element name="html" namespace="http://www.w3.org/1999/xhtml">
      <xsl:element name="head" namespace="http://www.w3.org/1999/xhtml">
        <xsl:element name="title" namespace="http://www.w3.org/1999/xhtml">
          XHTML version of Simple Dublin Core Record</xsl:element>
      </xsl:element>
      <xsl:element name="body" namespace="http://www.w3.org/1999/xhtml">
        <xsl:for-each select="oai_dc:dc/*">
          <xsl:element name="p" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class">
              <xsl:value-of select="local-name(.)"/></xsl:attribute>
            <i><xsl:value-of select="local-name(.)"/></i>: <b><xsl:value-of select="."/></b>
          </xsl:element>
        </xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>

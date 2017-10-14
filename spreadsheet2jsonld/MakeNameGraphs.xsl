<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:s="urn:schemas-microsoft-com:office:spreadsheet"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">

  <!-- Global Variables: -->
  <!--   these spreadsheet columns contain local identifiers of related resources; 
         values must be prefixed to yield globally valid resource URIs  -->
  <xsl:variable name="needPrefix"> memberOf parent sibling spouse children </xsl:variable>  
  <xsl:variable name="prefix">http://catalogdata.library.illinois.edu/lod/entities/Persons/kp/</xsl:variable> 
    
  <xsl:template match='/'>
    <xsl:for-each select="//s:Row[position()>1][s:Cell/s:NamedCell/@s:Name='KeyCode']">

       <!-- this spreadsheet column contains local identifier of the resource being described by the row,
            from which the global resource URI and local file location for saving can be derived -->
       <xsl:variable name="localId" select="./s:Cell[s:NamedCell/@s:Name='KeyCode']/s:Data"/>
       <xsl:variable name="saveAs" select="concat('NameGraphs/',$localId, '.jsonld')"/>
       <xsl:variable name='uri' select="concat($prefix, $localId )"/>
           
       <xsl:result-document href="{$saveAs}" method='text' exclude-result-prefixes="#all" 
                            omit-xml-declaration="yes" indent="no" encoding="UTF-8">

         <xsl:text>{ &#10; "@context": "http://schema.org"</xsl:text>
         <xsl:text>, &#10; "id": "</xsl:text><xsl:value-of select='$uri'/><xsl:text>"</xsl:text>
                
         <!-- URIs found in these spreadsheet columns will be conflated to  
              yield the value of the schema:sameAs property for resource being described -->
         <xsl:variable name="myLinks">
           <xsl:for-each select="./s:Cell[s:NamedCell/@s:Name='VIAF_Link' or 
                  s:NamedCell/@s:Name='EN_WIKIPEDIA' or s:NamedCell/@s:Name='FR_WIKIPEDIA']/s:Data">    
            <value>"<xsl:value-of select="."/>"</value>
           </xsl:for-each>
         </xsl:variable>     
         <xsl:call-template name="addValues">
           <xsl:with-param name="valueKey">sameAs</xsl:with-param>
           <xsl:with-param name="valueArray" select="$myLinks" />
         </xsl:call-template>

         <xsl:choose> 
           <xsl:when test="contains(./s:Cell[s:NamedCell/@s:Name='name']/s:Data, 'famille')">
             <xsl:text>,&#10; "type": "Organization"</xsl:text>
           </xsl:when>                    
           <xsl:otherwise>
              <xsl:text>,&#10; "type": "Person"</xsl:text>
           </xsl:otherwise>
         </xsl:choose>
            
         <xsl:call-template name="parseValues">
           <xsl:with-param name="valueKey">name</xsl:with-param></xsl:call-template>             
         <xsl:call-template name="parseValues">
           <xsl:with-param name="valueKey">familyName</xsl:with-param></xsl:call-template>                                     
         <xsl:call-template name="parseValues">
           <xsl:with-param name="valueKey">givenName</xsl:with-param></xsl:call-template>             
         <xsl:call-template name="parseValues">
           <xsl:with-param name="valueKey">birthDate</xsl:with-param></xsl:call-template>                                     
         <xsl:call-template name="parseValues">
           <xsl:with-param name="valueKey">deathDate</xsl:with-param></xsl:call-template>                                     
         <xsl:call-template name="parseValues">
           <xsl:with-param name="valueKey">gender</xsl:with-param></xsl:call-template>                        
         <xsl:call-template name="parseValues">
           <xsl:with-param name="valueKey">description</xsl:with-param></xsl:call-template>             
         <xsl:call-template name="parseValues">
           <xsl:with-param name="valueKey">parent</xsl:with-param></xsl:call-template>
         <xsl:call-template name="parseValues">
           <xsl:with-param name="valueKey">sibling</xsl:with-param></xsl:call-template>
         <xsl:call-template name="parseValues">
           <xsl:with-param name="valueKey">children</xsl:with-param></xsl:call-template>

         <xsl:text>&#10;}</xsl:text>
        </xsl:result-document>
      </xsl:for-each>
    </xsl:template>

    <xsl:template name="parseValues">
      <xsl:param name="valueKey" required="yes"/>
      <xsl:variable name="valueArray">
        <xsl:for-each select="tokenize(./s:Cell[s:NamedCell/@s:Name=$valueKey]/s:Data, '; ')">
          <xsl:choose>
            <xsl:when test="contains($needPrefix, $valueKey)">
              <value>"<xsl:value-of select="$prefix"/><xsl:value-of select="."/>"</value>
            </xsl:when>
            <xsl:otherwise>
              <value>"<xsl:value-of select="."/>"</value>                    
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>
      <xsl:call-template name="addValues">
        <xsl:with-param name="valueKey" select="$valueKey"/>
        <xsl:with-param name="valueArray" select="$valueArray"/>
      </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="addValues">
      <xsl:param name="valueArray" required="yes"/>
      <xsl:param name="valueKey" required="yes" />
      <xsl:choose>
        <xsl:when test="count($valueArray/value)=1">
          <xsl:text>,&#10; "</xsl:text><xsl:value-of select="$valueKey"/><xsl:text>": </xsl:text>
                            <xsl:value-of select="$valueArray/value"/>
        </xsl:when>
        <xsl:when test="count($valueArray/value)>1">
          <xsl:text>,&#10; "</xsl:text><xsl:value-of select="$valueKey"/><xsl:text>": [</xsl:text>
                            <xsl:value-of select="$valueArray/value" separator=", "/><xsl:text>]</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
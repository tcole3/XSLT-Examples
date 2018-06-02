<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:emblem="http://diglib.hab.de/rules/schema/emblem" 
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    version="2.0">
    <xsl:output method="text" omit-xml-declaration="yes" indent="yes" />

    <!-- Parameters - defaults to values for an item from University of Illinois  -->
    <xsl:param name="facet_collection_code">Illinois</xsl:param>
    <xsl:param name="spine_subfolder">Illinois</xsl:param>
    <xsl:param name="display_collection">University of Illinois at UC</xsl:param>
    
    <!-- quote and json-escaped quote characters as string variables, for use in string replace function -->
    <xsl:variable name="quoteChar">"</xsl:variable>
    <xsl:variable name="escQuoteChar">\\"</xsl:variable>
    
    <!-- Properties of both books and emblems -->
    <xsl:variable name="has_emblems">
        <xsl:choose>
            <xsl:when test="/emblem:biblioDesc/emblem:emblem">true</xsl:when>
            <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="book_id"><xsl:value-of select="substring-after(/emblem:biblioDesc/mods:mods/mods:location/mods:url[@usage='primary display'],'/detail/book/')"/></xsl:variable>
    <xsl:variable name="spineXML">http://emblematica.library.illinois.edu/EmblemSpine/<xsl:value-of select="$spine_subfolder"/>/<xsl:value-of select="$book_id"/>.xml</xsl:variable>
    <xsl:variable name="ark_id">
        <xsl:choose>
            <xsl:when test="/emblem:biblioDesc/mods:mods/mods:identifier[@type='ark']">"<xsl:value-of select="/emblem:biblioDesc/mods:mods/mods:identifier[@type='ark']"/>"</xsl:when>
            <xsl:otherwise>null</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="display_book_title">
        <xsl:choose>
            <xsl:when test="/emblem:biblioDesc/mods:mods/mods:titleInfo[not (@type)]/mods:subTitle">"<xsl:value-of select="normalize-space(/emblem:biblioDesc/mods:mods/mods:titleInfo[not (@type)]/mods:title)"/><xsl:text>: </xsl:text><xsl:value-of select="normalize-space(/emblem:biblioDesc/mods:mods/mods:titleInfo[not (@type='alternative')]/mods:subTitle)"/>"</xsl:when>
            <xsl:when test="/emblem:biblioDesc/mods:mods/mods:titleInfo[not (@type)]/mods:title">"<xsl:value-of select="normalize-space(/emblem:biblioDesc/mods:mods/mods:titleInfo[not (@type)]/mods:title)"/>"</xsl:when>
            <xsl:when test="/emblem:biblioDesc/mods:mods/mods:titleInfo/mods:title">"<xsl:value-of select="normalize-space(/emblem:biblioDesc/mods:mods/mods:titleInfo[1]/mods:title)"/>"</xsl:when>
            <xsl:otherwise>null</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="facet_language_code">
        <xsl:choose>
            <xsl:when test="/emblem:biblioDesc/mods:mods/mods:language/mods:languageTerm[@type='code']">
                <xsl:text>[&#010;</xsl:text>
                <xsl:for-each select="/emblem:biblioDesc/mods:mods/mods:language/mods:languageTerm[@type='code']">"<xsl:value-of select="."/>"<xsl:if test="position() != last()">,&#010;</xsl:if></xsl:for-each>
                <xsl:text>&#010;]</xsl:text>                   
            </xsl:when>
            <xsl:otherwise>null</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- *** Assumes singluar publication information about the original item (original as indicated by presence of dateIssued) -->
    <xsl:variable name="publication_date">
        <xsl:choose>
            <xsl:when test="/emblem:biblioDesc/mods:mods/mods:originInfo/mods:dateIssued">"<xsl:value-of select="/emblem:biblioDesc/mods:mods/mods:originInfo/mods:dateIssued"/>"</xsl:when>
            <xsl:otherwise>null</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="publication_place">
        <xsl:choose>
            <xsl:when test="/emblem:biblioDesc/mods:mods/mods:originInfo/mods:dateIssued">"<xsl:value-of select="/emblem:biblioDesc/mods:mods/mods:originInfo[mods:dateIssued]/mods:place/mods:placeTerm"/>"</xsl:when>
            <xsl:otherwise>null</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="publisher">
        <xsl:choose>
            <xsl:when test="/emblem:biblioDesc/mods:mods/mods:originInfo/mods:dateIssued">"<xsl:value-of select="/emblem:biblioDesc/mods:mods/mods:originInfo[mods:dateIssued]/mods:publisher"/>"</xsl:when>
            <xsl:otherwise>null</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="publication_century">
        <xsl:choose>
            <xsl:when test="substring($publication_date, 2, 4) castable as xsd:integer">"<xsl:value-of select="concat( (number(substring($publication_date, 2, 2))+1), 'th Century')"/>"</xsl:when>
            <xsl:otherwise><xsl:text>"uncertain"</xsl:text></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>   

    <!-- Required to know where to save json file(s) -->
    <xsl:variable name="book_solr"><xsl:text>.\Solr\books\</xsl:text><xsl:value-of select="$book_id"/><xsl:text>.json</xsl:text></xsl:variable>
    <xsl:variable name="emblem_solr_root"><xsl:text>.\Solr\emblems\</xsl:text></xsl:variable>

    <!-- root (book) template -->
    <xsl:template match="/">
        
        <!-- Calculate properties only required for the books solr -->
        <xsl:variable name="search_keywords">"<xsl:value-of select="replace(normalize-space(string-join(/emblem:biblioDesc/mods:mods/descendant::*/text(), ' ')),$quoteChar, $escQuoteChar)"/>"</xsl:variable>
        <xsl:variable name="search_title">
            <xsl:choose>
                <xsl:when test="/emblem:biblioDesc/mods:mods/mods:titleInfo">
                    <xsl:text>[&#010;</xsl:text>
                    <xsl:for-each select="/emblem:biblioDesc/mods:mods/mods:titleInfo">"<xsl:value-of select="normalize-space(string-join(./descendant::*/text(),' '))"/>"<xsl:if test="position() != last()">,&#010;</xsl:if></xsl:for-each>
                    <xsl:text>&#010;]</xsl:text>                   
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="search_name">
            <xsl:choose>
                <xsl:when test="/emblem:biblioDesc/mods:mods/mods:name">
                    <xsl:text>[&#010;</xsl:text>
                    <xsl:for-each select="/emblem:biblioDesc/mods:mods/mods:name">
                        <xsl:choose>
                            <xsl:when test="./mods:displayForm">"<xsl:value-of select="./mods:displayForm"/>"</xsl:when>
                            <xsl:when test="./mods:namePart">"<xsl:value-of select="normalize-space(string-join(./child::mods:namePart/text(),' '))"/>"</xsl:when>                            
                            <xsl:otherwise>"<xsl:value-of select="normalize-space(string-join(./descendant::*/text(),' '))"/>"</xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="position() != last()">,&#010;</xsl:if>
                    </xsl:for-each>
                   <xsl:text>&#010;]</xsl:text>  
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise>
            </xsl:choose>                        
        </xsl:variable> 
        <xsl:variable name="first_pictura_link">
            <xsl:choose>
                <xsl:when test="/emblem:biblioDesc/emblem:emblem[1]/emblem:pictura/@xlink:href">"<xsl:value-of select="/emblem:biblioDesc/emblem:emblem[1]/emblem:pictura/@xlink:href"/>"</xsl:when>
                <xsl:otherwise>null</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- now we write and save the book solr -->
        <xsl:result-document href="{$book_solr} ">
            <xsl:text>[{&#010;</xsl:text>
            <!-- Required values dp not already have quotes, optional (may be null) do have quotes; order per sample we're trying to match -->
            <xsl:text>  "id": "</xsl:text><xsl:value-of select="$book_id"/><xsl:text>",&#010;</xsl:text>
            <xsl:text>  "ark_id": </xsl:text><xsl:value-of select="$ark_id"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "spineXML": "</xsl:text><xsl:value-of select="$spineXML"/><xsl:text>",&#010;</xsl:text>
            <xsl:text>  "has_emblems": </xsl:text><xsl:value-of select="$has_emblems"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "search_keywords": </xsl:text><xsl:value-of select="$search_keywords"/><xsl:text>,&#010;</xsl:text>   
            <xsl:text>  "search_title": </xsl:text><xsl:value-of select="$search_title"/><xsl:text>,&#010;</xsl:text>  
            <xsl:text>  "search_publication_date": </xsl:text><xsl:value-of select="$publication_date"/><xsl:text>,&#010;</xsl:text>   
            <xsl:text>  "search_publication_place": </xsl:text><xsl:value-of select="$publication_place"/><xsl:text>,&#010;</xsl:text>   
            <xsl:text>  "search_publisher": </xsl:text><xsl:value-of select="$publisher"/><xsl:text>,&#010;</xsl:text>   
            <xsl:text>  "search_name": </xsl:text><xsl:value-of select="$search_name"/><xsl:text>,&#010;</xsl:text>  
            <xsl:text>  "display_title": </xsl:text><xsl:value-of select="$display_book_title"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "display_name": </xsl:text><xsl:value-of select="$search_name"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "display_publication_date": </xsl:text><xsl:value-of select="$publication_date"/><xsl:text>,&#010;</xsl:text>   
            <xsl:text>  "display_publication_place": </xsl:text><xsl:value-of select="$publication_place"/><xsl:text>,&#010;</xsl:text> 
            <xsl:text>  "display_collection": "</xsl:text><xsl:value-of select="$display_collection"/><xsl:text>",&#010;</xsl:text>
            <xsl:text>  "display_first_pictura_link": </xsl:text><xsl:value-of select="$first_pictura_link"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "facet_collection_code": "</xsl:text><xsl:value-of select="$facet_collection_code"/><xsl:text>",&#010;</xsl:text>
            <xsl:text>  "facet_language_code": </xsl:text><xsl:value-of select="$facet_language_code"/><xsl:text>,&#010;</xsl:text>   
            <xsl:text>  "facet_publication_century": </xsl:text><xsl:value-of select="$publication_century"/><xsl:text>,&#010;</xsl:text>   
            <xsl:text>  "facet_publication_place": </xsl:text><xsl:value-of select="$publication_place"/><xsl:text>&#010;</xsl:text>
            <xsl:text>}]</xsl:text>
      </xsl:result-document>
        
        <!-- Last we call a subsidary template which will write and save each emblem description for solr -->
        <xsl:for-each select="/emblem:biblioDesc/emblem:emblem">
            <xsl:apply-templates select="."></xsl:apply-templates>
        </xsl:for-each>

    </xsl:template>
    
    <xsl:template match="/emblem:biblioDesc/emblem:emblem">
        <xsl:variable name="emblem_id"><xsl:value-of select="substring-after(./@globalID, 'EmblemRegistry:')"/></xsl:variable>
        <xsl:variable name="emblem_solr"><xsl:value-of select="$emblem_solr_root"/><xsl:value-of select="$emblem_id"/><xsl:text>.json</xsl:text></xsl:variable>
        
        <!-- Calculate properties only required for the emblem solr -->
        <xsl:variable name="search_keywords">"<xsl:value-of select="replace(normalize-space(string-join(./descendant::*/text(), ' ')),$quoteChar, $escQuoteChar)"/>"</xsl:variable>
        <xsl:variable name="search_keywords_iconclass_term">
            <xsl:choose>
                <xsl:when test="./emblem:pictura/emblem:iconclass/(skos:prefLabel | emblem:keyword)">"<xsl:value-of select="normalize-space(string-join(./emblem:pictura/emblem:iconclass/(skos:prefLabel | emblem:keyword)/text(), ' '))"/>"</xsl:when>
                <xsl:otherwise>null</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="search_iconclass">
            <xsl:choose>
                <xsl:when test="./emblem:pictura/emblem:iconclass/skos:notation">
                    <xsl:text>[&#010;</xsl:text>                    
                    <xsl:for-each select="./emblem:pictura/emblem:iconclass/skos:notation">"<xsl:value-of select="normalize-space(./text())"/>"<xsl:if test="position() != last()">,&#010;</xsl:if></xsl:for-each>
                    <xsl:text>&#010;]</xsl:text> 
                </xsl:when>                    
                <xsl:otherwise>null</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="display_motto">
            <xsl:choose>
                <xsl:when test="./emblem:motto/emblem:transcription">"<xsl:value-of select="normalize-space(string-join(./emblem:motto[1]/(emblem:transcription[1] | emblem:transcription[1]/tei:p[1])/text()[normalize-space()], ' '))"/>"</xsl:when>
                <xsl:otherwise>null</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="search_motto">
            <xsl:choose>
                <xsl:when test="./emblem:motto/emblem:transcription">
                    <xsl:text>[&#010;</xsl:text>
                    <xsl:for-each select="./emblem:motto/(emblem:transcription | emblem:transcription/tei:p | emblem:transcription/emblem:normalisation)/text()[normalize-space()]">"<xsl:value-of select="normalize-space(.)"/>"<xsl:if test="position() != last()">,&#010;</xsl:if></xsl:for-each>
                    <xsl:text>&#010;]</xsl:text> 
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise> 
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="search_motto_latin">
            <xsl:choose>
                <xsl:when test="./emblem:motto/(emblem:transcription | emblem:transcription/tei:p | emblem:transcription/emblem:normalisation)[@xml:lang='la']">
                    <xsl:text>[&#010;</xsl:text>
                    <xsl:for-each select="./emblem:motto/(emblem:transcription | emblem:transcription/tei:p | emblem:transcription/emblem:normalisation)[@xml:lang='la']/text()[normalize-space()]">"<xsl:value-of select="normalize-space(.)"/>"<xsl:if test="position() != last()">,&#010;</xsl:if></xsl:for-each>
                    <xsl:text>&#010;]</xsl:text> 
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise> 
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="search_motto_english">
            <xsl:choose>
                <xsl:when test="./emblem:motto/(emblem:transcription | emblem:transcription/tei:p | emblem:transcription/emblem:normalisation)[@xml:lang='en']">
                    <xsl:text>[&#010;</xsl:text>
                    <xsl:for-each select="./emblem:motto/(emblem:transcription | emblem:transcription/tei:p | emblem:transcription/emblem:normalisation)[@xml:lang='en']/text()[normalize-space()]">"<xsl:value-of select="normalize-space(.)"/>"<xsl:if test="position() != last()">,&#010;</xsl:if></xsl:for-each>
                    <xsl:text>&#010;]</xsl:text> 
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise> 
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="search_motto_german">
            <xsl:choose>
                <xsl:when test="./emblem:motto/(emblem:transcription | emblem:transcription/tei:p | emblem:transcription/emblem:normalisation)[@xml:lang='de']">
                    <xsl:text>[&#010;</xsl:text>
                    <xsl:for-each select="./emblem:motto/(emblem:transcription | emblem:transcription/tei:p | emblem:transcription/emblem:normalisation)[@xml:lang='de']/text()[normalize-space()]">"<xsl:value-of select="normalize-space(.)"/>"<xsl:if test="position() != last()">,&#010;</xsl:if></xsl:for-each>
                    <xsl:text>&#010;]</xsl:text> 
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise> 
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="search_motto_dutch">
            <xsl:choose>
                <xsl:when test="./emblem:motto/(emblem:transcription | emblem:transcription/tei:p | emblem:transcription/emblem:normalisation)[@xml:lang='nl']">
                    <xsl:text>[&#010;</xsl:text>
                    <xsl:for-each select="./emblem:motto/(emblem:transcription | emblem:transcription/tei:p | emblem:transcription/emblem:normalisation)[@xml:lang='nl']/text()[normalize-space()]">"<xsl:value-of select="normalize-space(.)"/>"<xsl:if test="position() != last()">,&#010;</xsl:if></xsl:for-each>
                    <xsl:text>&#010;]</xsl:text> 
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise> 
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="search_motto_italian">
            <xsl:choose>
                <xsl:when test="./emblem:motto/(emblem:transcription | emblem:transcription/tei:p | emblem:transcription/emblem:normalisation)[@xml:lang='it']">
                    <xsl:text>[&#010;</xsl:text>
                    <xsl:for-each select="./emblem:motto/(emblem:transcription | emblem:transcription/tei:p | emblem:transcription/emblem:normalisation)[@xml:lang='it']/text()[normalize-space()]">"<xsl:value-of select="normalize-space(.)"/>"<xsl:if test="position() != last()">,&#010;</xsl:if></xsl:for-each>
                    <xsl:text>&#010;]</xsl:text> 
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise> 
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="search_motto_french">
            <xsl:choose>
                <xsl:when test="./emblem:motto/(emblem:transcription | emblem:transcription/tei:p | emblem:transcription/emblem:normalisation)[@xml:lang='fr']">
                    <xsl:text>[&#010;</xsl:text>
                    <xsl:for-each select="./emblem:motto/(emblem:transcription | emblem:transcription/tei:p | emblem:transcription/emblem:normalisation)[@xml:lang='fr']/text()[normalize-space()]">"<xsl:value-of select="normalize-space(.)"/>"<xsl:if test="position() != last()">,&#010;</xsl:if></xsl:for-each>
                    <xsl:text>&#010;]</xsl:text> 
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise> 
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="search_motto_greek">
            <xsl:choose>
                <xsl:when test="./emblem:motto/(emblem:transcription | emblem:transcription/tei:p | emblem:transcription/emblem:normalisation)[@xml:lang='el']">
                    <xsl:text>[&#010;</xsl:text>
                    <xsl:for-each select="./emblem:motto/(emblem:transcription | emblem:transcription/tei:p | emblem:transcription/emblem:normalisation)[@xml:lang='el']/text()[normalize-space()]">"<xsl:value-of select="normalize-space(.)"/>"<xsl:if test="position() != last()">,&#010;</xsl:if></xsl:for-each>
                    <xsl:text>&#010;]</xsl:text> 
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise> 
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="search_motto_spanish">
            <xsl:choose>
                <xsl:when test="./emblem:motto/(emblem:transcription | emblem:transcription/tei:p | emblem:transcription/emblem:normalisation)[@xml:lang='es']">
                    <xsl:text>[&#010;</xsl:text>
                    <xsl:for-each select="./emblem:motto/(emblem:transcription | emblem:transcription/tei:p | emblem:transcription/emblem:normalisation)[@xml:lang='es']/text()[normalize-space()]">"<xsl:value-of select="normalize-space(.)"/>"<xsl:if test="position() != last()">,&#010;</xsl:if></xsl:for-each>
                    <xsl:text>&#010;]</xsl:text> 
                </xsl:when>
                <xsl:otherwise>null</xsl:otherwise> 
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="display_emblem_link">
            <xsl:choose>
                <xsl:when test="./@xlink:href">"<xsl:value-of select="./@xlink:href"/>"</xsl:when>
                <xsl:otherwise>null</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="scanned_pictura_link">
            <xsl:choose>
                <xsl:when test="./emblem:pictura/@xlink:href">"<xsl:value-of select="./emblem:pictura/@xlink:href"/>"</xsl:when>
                <xsl:otherwise>null</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- Now we write and save the emblem solr -->
        <xsl:result-document href="{$emblem_solr}">
            <xsl:text>[{&#010;</xsl:text>
    
            <xsl:text>  "id": "</xsl:text><xsl:value-of select="$emblem_id"/><xsl:text>",&#010;</xsl:text>
            <xsl:text>  "bookID": "</xsl:text><xsl:value-of select="$book_id"/><xsl:text>",&#010;</xsl:text>
            <xsl:text>  "ark_id": </xsl:text><xsl:value-of select="$ark_id"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "spineXML": "</xsl:text><xsl:value-of select="replace($spineXML, 'emblems', $emblem_id)"/><xsl:text>",&#010;</xsl:text>
            <xsl:text>  "search_keywords": </xsl:text><xsl:value-of select="$search_keywords"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "search_keywords_iconclass_term": </xsl:text><xsl:value-of select="$search_keywords_iconclass_term"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "search_motto": </xsl:text><xsl:value-of select="$search_motto"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "search_motto_latin": </xsl:text><xsl:value-of select="$search_motto_latin"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "search_motto_english": </xsl:text><xsl:value-of select="$search_motto_english"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "search_motto_old_german": </xsl:text><xsl:value-of select="$search_motto_german"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "search_motto_new_german": </xsl:text><xsl:value-of select="$search_motto_german"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "search_motto_dutch": </xsl:text><xsl:value-of select="$search_motto_dutch"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "search_motto_italian": </xsl:text><xsl:value-of select="$search_motto_italian"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "search_motto_french": </xsl:text><xsl:value-of select="$search_motto_french"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "search_motto_greek": </xsl:text><xsl:value-of select="$search_motto_greek"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "search_motto_spanish": </xsl:text><xsl:value-of select="$search_motto_spanish"/><xsl:text>,&#010;</xsl:text>            
            <xsl:text> "search_iconclass": </xsl:text><xsl:value-of select="$search_iconclass"/><xsl:text>,&#010;</xsl:text>
            <xsl:text> "display_motto": </xsl:text><xsl:value-of select="$display_motto"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "display_emblem_link": </xsl:text><xsl:value-of select="$display_emblem_link"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "display_book_title": </xsl:text><xsl:value-of select="$display_book_title"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "display_book_has_emblems": </xsl:text><xsl:value-of select="$has_emblems"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "emblem_more_info_link": null,&#010;</xsl:text>
            <xsl:text>  "scanned_pictura_link": </xsl:text><xsl:value-of select="$scanned_pictura_link"/><xsl:text>,&#010;</xsl:text>
            <xsl:text>  "facet_collection_code": "</xsl:text><xsl:value-of select="$facet_collection_code"/><xsl:text>",&#010;</xsl:text>
            <xsl:text>  "facet_language_code": </xsl:text><xsl:value-of select="$facet_language_code"/><xsl:text>,&#010;</xsl:text>   
            <xsl:text>  "facet_publication_century": </xsl:text><xsl:value-of select="$publication_century"/><xsl:text>,&#010;</xsl:text>   
            <xsl:text>  "facet_publication_place": </xsl:text><xsl:value-of select="$publication_place"/><xsl:text>&#010;</xsl:text>
                        
            <xsl:text>}]</xsl:text>
            
        </xsl:result-document>
    </xsl:template>
    
</xsl:stylesheet>

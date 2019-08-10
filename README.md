# XSLT
Examples of trivial transforms written in EXstensible Stylesheet Language for Transformations (XSLT)
Each folder in this repository contains one or more source XML files, one or more XSLTs and at least one example of the output expected when the XSLT is used to transform the Source. Some folders include an about.html or pdf providing context and/or other information about the transform.  These examples derive from ongoing research and are provided for illustrative purposes only, no warranty or guarantee of quality is implied. Use at your own risk. Subject to change or deletion at any time.

1. Transforming rows in a spreadsheet saved as XML into json-ld
* [About](https://tcole3.github.io/XSLT-Examples/spreadsheet2jsonld/about.html)
* [Source XML](https://tcole3.github.io/XSLT-Examples/spreadsheet2jsonld/KolbProustSubset.xml)
* [XSLT](https://tcole3.github.io/XSLT-Examples/spreadsheet2jsonld/MakeNameGraphs.xsl)
* [Sample output](https://tcole3.github.io/XSLT-Examples/spreadsheet2jsonld/NameGraphs/adam7.jsonld)

2. oai_dc and html from MARCXML
* [Sample MARC Record - Source XML](https://tcole3.github.io/XSLT-Examples/MARC-Illustrations/MARC2oai_dc.xsl)
* [XSLT to transform MARC to oai_dc](https://tcole3.github.io/XSLT-Examples/MARC-Illustrations/MARC2oai_dc.xsl)
* [Resulting oai_dc record](https://tcole3.github.io/XSLT-Examples/MARC-Illustrations/Results-oai_dcFromMarc.xml)
* [XSLT to transform oai_dc to HTML](https://tcole3.github.io/XSLT-Examples/MARC-Illustrations/oai_dc2html.xsl)
* [Resulting HTML](https://tcole3.github.io/XSLT-Examples/MARC-Illustrations/Results-HtmlFromOai_dc.html)
* [XSLT extracting names from MARC and displaying as HTML](https://tcole3.github.io/XSLT-Examples/MARC-Illustrations/namesFromMARC.xsl)
* [Resulting HTML](https://tcole3.github.io/XSLT-Examples/MARC-Illustrations/Results-NamesFromMarc.html)

3. RDFa from emblem spine metadata 
* [Sample Spine Record - Source XML](https://tcole3.github.io/XSLT-Examples/spine2RDFa/SpineExample.xml)
* [XSLT to transform book info from Spine to RDFa](https://tcole3.github.io/XSLT-Examples/spine2RDFa/Spine2BookRDFa.xsl)
* [Resulting book-level RDFa](https://tcole3.github.io/XSLT-Examples/spine2RDFa/ResultBookRDFa.html)
* [XSLT to transform emblem info from Spine to RDFa](https://tcole3.github.io/XSLT-Examples/spine2RDFa/Spine2EmblemRDFa.xsl)
* [Resulting RDFa](https://tcole3.github.io/XSLT-Examples/spine2RDFa/ResultEmblemRDFa.html)

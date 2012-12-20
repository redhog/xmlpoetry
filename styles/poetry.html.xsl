<xsl:stylesheet
 version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

 <xsl:output
  method="xml"
  encoding="utf-8"
  doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
  doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" /> 

 <xsl:template name="translate">
  <xsl:param name="input"/>
  <xsl:variable name="language" select="ancestor-or-self::node()/chapter/language/text()"/>
  <xsl:choose>
   <xsl:when test="$language = 'swedish'">
    <xsl:choose>
     <xsl:when test="$input = 'Images copyright (c) '">Bilderna copyright (c) </xsl:when>
     <xsl:when test="$input = 'Translation copyright (c) '">Övrsättningen copyright (c) </xsl:when>
     <xsl:when test="$input = 'Copyright (c) '">Copyright (c) </xsl:when>
     <xsl:when test="$input = ' by '">, </xsl:when>
     <xsl:when test="$input = 'This document is also available in'">Detta dokument finns också tillgängligt i</xsl:when>
     <xsl:when test="$input = 'for printing, and in'">för utskrift, och i</xsl:when>
     <xsl:when test="$input = 'for editing.'">för editering.</xsl:when>
     <xsl:when test="$input = 'Table of contents'">Innehållsförteckning</xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="$input"/>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$input"/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template match="/chapter[title and author and copyright]" name="root" priority="1">
  <html>
   <head>
    <title><xsl:value-of select="title"/></title>
    <link rel="stylesheet" href='poetry.html.css' type="text/css"/>
   </head>
   <body>
    <div class="dochead">
     <xsl:apply-templates select="header/*"/>
     <h1><xsl:value-of select="title"/></h1>
     <xsl:if test="date"><div class="date"><xsl:value-of select="date"/></div></xsl:if>
     <div class="copyright">
      <xsl:call-template name="translate"><xsl:with-param name="input" select="'Copyright (c) '"/></xsl:call-template>
      <xsl:value-of select="copyright"/>
      <xsl:call-template name="translate"><xsl:with-param name="input" select="' by '"/></xsl:call-template>
      <xsl:value-of select="author"/>.
     </div>
     <xsl:if test="translation">
      <div class="imagecopyright">
       <xsl:call-template name="translate"><xsl:with-param name="input" select="'Translation copyright (c) '"/></xsl:call-template>
       <xsl:value-of select="translation/copyright"/>
       <xsl:call-template name="translate"><xsl:with-param name="input" select="' by '"/></xsl:call-template>
       <xsl:value-of select="translation/author"/>.
      </div>
     </xsl:if>
     <xsl:if test="images">
      <div class="imagecopyright">
       <xsl:call-template name="translate"><xsl:with-param name="input" select="'Images copyright (c) '"/></xsl:call-template>
       <xsl:value-of select="images/copyright"/>
       <xsl:call-template name="translate"><xsl:with-param name="input" select="' by '"/></xsl:call-template>
       <xsl:value-of select="images/author"/>.
      </div>
     </xsl:if>
     <div class="formatlisting">
      <xsl:call-template name="translate"><xsl:with-param name="input" select="'This document is also available in'"/></xsl:call-template>
      <xsl:element name="a">
       <xsl:attribute name="href"><xsl:copy-of select="$filename"/>.pdf</xsl:attribute>
       PDF format
      </xsl:element>
      <xsl:call-template name="translate"><xsl:with-param name="input" select="'for printing, and in'"/></xsl:call-template>
      <xsl:element name="a">
       <xsl:attribute name="href"><xsl:copy-of select="$filename"/>.xml</xsl:attribute>
       XML format
      </xsl:element>
      <xsl:call-template name="translate"><xsl:with-param name="input" select="'for editing.'"/></xsl:call-template>
     </div>
    </div>
    <xsl:if test="count(descendant::node()[(self::chapter or self::verse) and (title or date or author or copyright)]) > 0">
     <div class="toc">
      <h2><xsl:call-template name="translate"><xsl:with-param name="input" select="'Table of contents'"/></xsl:call-template></h2>
      <xsl:apply-templates select="*" mode="gentoc"/>
     </div>
    </xsl:if>
    <div class="body">
     <xsl:apply-templates/>
    </div>
   </body>
  </html>
 </xsl:template>

 <xsl:template match="include" priority="1">
  <xsl:variable name="id" select="id/text()"/>
  <xsl:variable name="document" select="document/text()"/>
  <xsl:apply-templates select="document($document)/descendant-or-self::node()[@id=$id]"/>
 </xsl:template>

 <xsl:template match="include" mode="gentoc" priority="1">
  <xsl:variable name="id" select="id/text()"/>
  <xsl:variable name="document" select="document/text()"/>
  <xsl:apply-templates select="document($document)/descendant-or-self::node()[@id=$id]" mode="gentoc"/>
 </xsl:template>

 <xsl:template match="*[(self::chapter or self::verse) and (title or date or author or copyright)]" name="toc" mode="gentoc" priority="0.5">
  <xsl:variable name="title">
   <xsl:if test="title"><span class="title"><xsl:value-of select="title"/></span></xsl:if>
   <xsl:if test="date"><span class="date"><xsl:value-of select="date"/></span></xsl:if>
   <xsl:if test="author"><span class="author"><xsl:value-of select="author"/></span></xsl:if>
   <xsl:if test="copyright"><span class="copyright"><xsl:value-of select="copyright"/></span></xsl:if>
  </xsl:variable>
  <li>
   <xsl:element name="a">
    <xsl:attribute name="href">#chapter.<xsl:value-of select="generate-id()"/></xsl:attribute>
    <xsl:copy-of select="$title"/>
   </xsl:element>
  </li>
  <ul>
   <xsl:apply-templates select="*" mode="gentoc"/>
  </ul>
 </xsl:template>

 <xsl:template match="node()" name="nontoc" mode="gentoc" priority="0.1">
  <xsl:apply-templates select="*" mode="gentoc"/>
 </xsl:template>

 <xsl:template match="*[(self::chapter or self::verse) and (title or date or author or copyright)]" name="chapter" priority="0.5">
  <xsl:variable name="title">
   <xsl:element name="a">
    <xsl:attribute name="name">chapter.<xsl:value-of select="generate-id()"/></xsl:attribute>
    <xsl:if test="title"><span class="title"><xsl:value-of select="title"/></span></xsl:if>
    <xsl:if test="date"><span class="date"><xsl:value-of select="date"/></span></xsl:if>
    <xsl:if test="author"><span class="author"><xsl:value-of select="author"/></span></xsl:if>
    <xsl:if test="copyright"><span class="copyright"><xsl:value-of select="copyright"/></span></xsl:if>
   </xsl:element>
  </xsl:variable>
  <xsl:variable name="level" select="count(ancestor::chapter[title or date or author or copyright])"/>
  <p class="chapter">
   <xsl:choose>
    <xsl:when test="$level=0"><h1><xsl:copy-of select="$title"/></h1></xsl:when>
    <xsl:when test="$level=1"><h2><xsl:copy-of select="$title"/></h2></xsl:when>
    <xsl:when test="$level=2"><h3><xsl:copy-of select="$title"/></h3></xsl:when>
    <xsl:when test="$level=3"><h4><xsl:copy-of select="$title"/></h4></xsl:when>
   </xsl:choose>
   <xsl:apply-templates/>
  </p>
 </xsl:template>

 <xsl:template match="*[(self::chapter or self::verse)]" name="anonymouschapter" priority="0.4">
  <xsl:element name="p">
   <xsl:attribute name="class">
    <xsl:if test="class">
     <xsl:value-of select="class/text()"/>
    </xsl:if>
    anonymouschapter
   </xsl:attribute>
   <xsl:apply-templates/>
  </xsl:element>
 </xsl:template>

 <xsl:template match="stanca" name="stanca" priority="0.5">
  <p class="stanca">
   <xsl:apply-templates/>
  </p>
 </xsl:template>

 <xsl:template match="line" name="line" priority="0.5">
  <div class="line">
   <xsl:apply-templates/>
  </div>
 </xsl:template>

 <xsl:template match="space" name="space" priority="0.5">
  &#160;
 </xsl:template>

 <xsl:template match="table" name="table" priority="0.5">
  <table>
   <xsl:for-each select="row | headerrow">
    <xsl:apply-templates select="."/>
   </xsl:for-each>
  </table>
 </xsl:template>

 <xsl:template match="headerrow" name="headerrow" priority="0.5">
  <tr>
   <xsl:for-each select="cell">
    <th>
     <xsl:apply-templates/>
    </th>
   </xsl:for-each>
  </tr>
 </xsl:template>

 <xsl:template match="row" name="row" priority="0.4">
  <tr>
   <xsl:for-each select="cell">
    <td>
     <xsl:apply-templates/>
    </td>
   </xsl:for-each>
  </tr>
 </xsl:template>

 <xsl:template match="quote" name="quote" priority="0.3">
  ''<xsl:apply-templates/>''
 </xsl:template>

 <xsl:template match="image" name="image" priority="0.2">
  <xsl:element name="img">
   <xsl:attribute name="width"><xsl:copy-of select="width/text()*100"/></xsl:attribute>
   <xsl:attribute name="src"><xsl:copy-of select="name/text()"/>.lnk.jpg</xsl:attribute>
   <xsl:if test="position">
    <xsl:attribute name="class"><xsl:copy-of select="position/text()"/></xsl:attribute>
   </xsl:if>
  </xsl:element>
 </xsl:template>

 <xsl:template match="script" name="script" priority="0.2">
  <div class="script">
   <xsl:apply-templates/>
  </div>
 </xsl:template>

 <xsl:template match="repl" name="repl" priority="0.2">
  <div class="repl">
   <span class="speaker">
    <xsl:apply-templates select="speaker/text()"/>:
   </span>
   <xsl:apply-templates/>
  </div>
 </xsl:template>

 <xsl:template match="emph" name="emph" priority="0.2">
  <em>
   <xsl:apply-templates/>
  </em>
 </xsl:template>

 <xsl:template match="text()" name="text" priority="0.1">
  <xsl:copy-of select="."/>
 </xsl:template>

 <xsl:template match="*" name="discardparams" priority="0">
 </xsl:template>

</xsl:stylesheet>

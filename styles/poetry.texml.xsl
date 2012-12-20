<xsl:stylesheet
 version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

 <xsl:output method="xml" encoding="utf-8"/>

 <xsl:template name="translate">
  <xsl:param name="input"/>
  <xsl:variable name="language" select="ancestor-or-self::node()/chapter/language/text()"/>
  <xsl:choose>
   <xsl:when test="$language = 'swedish'">
    <xsl:choose>
     <xsl:when test="$input = 'Images copyright (c) '">Bilderna copyright </xsl:when>
     <xsl:when test="$input = 'Translation copyright (c) '">Övrsättningen copyright (c) </xsl:when>
     <xsl:when test="$input = ' by '">, </xsl:when>
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
  <TeXML>
   <cmd name="documentclass" nl2="1">
    <opt>a4paper,12pt</opt>
    <parm>article</parm>
   </cmd>
   <cmd name="usepackage" nl2="1">
    <parm>graphicx,float,floatflt</parm>
   </cmd>

   <xsl:if test="language">
    <cmd name="usepackage" nl2="1">
     <opt><xsl:value-of select="language"/></opt>
     <parm>babel</parm>
    </cmd>
   </xsl:if>

   <env name="document">

    <cmd name="title" nl2="1"><parm><xsl:value-of select="title"/></parm></cmd>
    <xsl:if test="date"><cmd name="date" nl2="1"><parm><xsl:value-of select="date"/></parm></cmd></xsl:if>
    <cmd name="author" nl2="1">
     <parm>
      <cmd name="copyright" nl2="1">
       <parm><xsl:value-of select="copyright"/></parm>
      </cmd>,
      <xsl:value-of select="author"/>
      <xsl:if test="translation">
       , 
       <xsl:call-template name="translate"><xsl:with-param name="input" select="'Translation copyright (c) '"/></xsl:call-template>
       <xsl:value-of select="translation/copyright"/>
       <xsl:call-template name="translate"><xsl:with-param name="input" select="' by '"/></xsl:call-template>
       <xsl:value-of select="translation/author"/>.
      </xsl:if>
      <xsl:if test="images">
       , 
       <xsl:call-template name="translate"><xsl:with-param name="input" select="'Images copyright (c) '"/></xsl:call-template>
       <xsl:value-of select="images/copyright"/>
       <xsl:call-template name="translate"><xsl:with-param name="input" select="' by '"/></xsl:call-template>
       <xsl:value-of select="images/author"/>.
      </xsl:if>
     </parm>
    </cmd>
    <cmd name="maketitle" nl2="1" gr="0"/>

    <xsl:apply-templates select="header/*"/>

    <cmd name="newpage" nl2="1" gr="0"/>

    <xsl:if test="count(descendant::node()[(self::chapter or self::verse) and (title or date or author or copyright)]) > 0">
     <cmd name="tableofcontents" nl2="1" gr="0"/>
     <cmd name="newpage" nl2="1" gr="0"/>
    </xsl:if>

    <xsl:apply-templates/>

   </env>
  </TeXML>
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

 <xsl:template match="*[(self::chapter or self::verse) and (title or date or author or copyright)]" name="chapter" priority="0.5">
  <xsl:variable name="title">
   <parm>
    <xsl:if test="title"><xsl:value-of select="title"/></xsl:if>
    <xsl:if test="date"><xsl:value-of select="date"/></xsl:if>
    <xsl:if test="author"><xsl:value-of select="author"/></xsl:if>
    <xsl:if test="copyright"><xsl:value-of select="copyright"/></xsl:if>
   </parm>
  </xsl:variable>
  <xsl:variable name="level" select="count(ancestor::chapter[title or date or author or copyright])"/>
  <xsl:choose>
   <xsl:when test="$level=0"><cmd name="chapter" nl1="1" nl2="1"><xsl:copy-of select="$title"/></cmd></xsl:when>
   <xsl:when test="$level=1"><cmd name="section" nl1="1" nl2="1"><xsl:copy-of select="$title"/></cmd></xsl:when>
   <xsl:when test="$level=2"><cmd name="subsection" nl1="1" nl2="1"><xsl:copy-of select="$title"/></cmd></xsl:when>
   <xsl:when test="$level=3"><cmd name="subsubsection" nl1="1" nl2="1"><xsl:copy-of select="$title"/></cmd></xsl:when>
  </xsl:choose>
  <xsl:call-template name="paragraph"/>
 </xsl:template>

 <xsl:template match="chapter | verse" name="paragraph" priority="0.4">
  <xsl:choose>
   <xsl:when test="self::chapter">
    <spec cat="nl"/>
    <group>
     <xsl:if test="class/text() = 'meta'">
      <cmd name="em"/>
     </xsl:if>
     <xsl:apply-templates/>
    </group>
    <spec cat="nl"/>
   </xsl:when>
   <xsl:when test="self::verse">
    <env name="verse">
     <xsl:apply-templates/>
    </env>
   </xsl:when>
  </xsl:choose>
 </xsl:template>

 <xsl:template match="stanca" name="stanca" priority="0.5">
  <xsl:apply-templates/>
  <spec cat="nl"/>
  <spec cat="nl"/>
 </xsl:template>

 <xsl:template match="line" name="line" priority="0.5">
  <xsl:apply-templates/>
  <spec cat="esc"/><spec cat="esc"/><spec cat="nl"/>
 </xsl:template>

 <xsl:template match="space" name="space" priority="0.5">
  <cmd name="hskip" gr="0"/>10pt<spec cat="space"/>
 </xsl:template>

 <xsl:template match="table" name="table" priority="0.5">
  <env name="tabular">
   <parm>*<group><xsl:value-of select="width"/></group><group>l</group></parm>
   <xsl:for-each select="row | headerrow">
    <xsl:apply-templates select="."/>
   </xsl:for-each>
  </env>
 </xsl:template>

 <xsl:template match="headerrow" name="headerrow" priority="0.5">
  <xsl:call-template name="row"/>
  <cmd name="hline" nl2="1"/>
 </xsl:template>

 <xsl:template match="row | headerrow" name="row" priority="0.4">
  <xsl:apply-templates select="cell[position() = 1]"/>
  <xsl:for-each select="cell[position() != 1]">
   <spec cat="align"/>
   <xsl:apply-templates select="."/>
  </xsl:for-each>
  <spec cat="esc"/><spec cat="esc"/><spec cat="nl"/>
 </xsl:template>

 <xsl:template match="quote" name="quote" priority="0.1">
  ``<xsl:apply-templates/>''
 </xsl:template>

 <xsl:template match="image" name="image" priority="0.2">
  <xsl:if test="parent::script"> <!-- and position/text() = 'all'"> -->
   <cmd name="item"><opt></opt></cmd>
  </xsl:if>
  <xsl:variable name="graphics">
   <cmd name="includegraphics">
    <opt>width=<xsl:copy-of select="width/text()"/>in</opt>
    <parm><xsl:copy-of select="name/text()"/>.eps</parm>
   </cmd>
  </xsl:variable>
  <env name="center"><xsl:copy-of select="$graphics"/></env>
  <!--
  <xsl:choose>
   <xsl:when test="position/text() = 'all'">
    <env name="center"><xsl:copy-of select="$graphics"/></env>
   </xsl:when>
   <xsl:when test="position/text() = 'left'">
    <env name="floatingfigure"><opt>l</opt><parm><xsl:copy-of select="width/text()"/>in</parm><xsl:copy-of select="$graphics"/></env>
   </xsl:when>
   <xsl:when test="position/text() = 'right'">
    <env name="floatingfigure"><opt>r</opt><parm><xsl:copy-of select="width/text()"/>in</parm><xsl:copy-of select="$graphics"/></env>
   </xsl:when>
  </xsl:choose>
  -->
 </xsl:template>

 <xsl:template match="script" name="script" priority="0.2">
  <env name="itemize">
   <cmd name="setlength">
    <parm><cmd name="itemsep" gr="0"/></parm>
    <parm>0pt</parm>
   </cmd>
   <cmd name="setlength">
    <parm><cmd name="parskip" gr="0"/></parm>
    <parm>0pt</parm>
   </cmd>
   <xsl:apply-templates/>
  </env>
 </xsl:template>

 <xsl:template match="repl" name="repl" priority="0.2">
  <cmd name="item">
   <opt><group><cmd name="mdseries"/><cmd name="scshape"/><xsl:apply-templates select="speaker/text()"/>:</group></opt>
  </cmd>
  <xsl:apply-templates/>
 </xsl:template>

 <xsl:template match="emph" name="emph" priority="0.2">
  <group>
   <cmd name="em"/>
   <xsl:apply-templates/>
  </group>
 </xsl:template>

 <xsl:template match="text()" name="text" priority="0.1">
  <xsl:copy-of select="."/>
 </xsl:template>

 <xsl:template match="*" name="discardparams" priority="0">
 </xsl:template>

</xsl:stylesheet>

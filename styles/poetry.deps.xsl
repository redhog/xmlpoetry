<xsl:stylesheet
 version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:func="http://exslt.org/functions"
 xmlns:deps="http://redhog.org/Projects/Programming/XML/Namespace/Deps">

 <xsl:output method="text" encoding="utf-8"/>

 <xsl:template match="/">
  <xsl:copy-of select="$filename"/><xsl:text>.html: </xsl:text>
  <xsl:apply-templates mode="html"/>

  <xsl:text>
</xsl:text>

  <xsl:copy-of select="$filename"/><xsl:text>.dvi: </xsl:text>
  <xsl:apply-templates mode="dvi"/>

  <xsl:text>
</xsl:text>

  <xsl:apply-templates mode="link"/>
 </xsl:template>


 <xsl:template name="escape">
  <xsl:param name="input"/>
  <xsl:choose>
   <xsl:when test="contains($input, ' ')">
    <xsl:value-of select="concat(substring-before($input, ' '), '\ ')"/>
    <xsl:call-template name="escape">
     <xsl:with-param name="input" select="substring-after($input, ' ')"/>
    </xsl:call-template>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$input"/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template match="image" mode="dvi">
  <xsl:call-template name="escape"><xsl:with-param name="input" select="name/text()"/></xsl:call-template>
  <xsl:text>.eps </xsl:text>
 </xsl:template>

 <xsl:template match="include" mode="dvi">
  <xsl:variable name="id" select="id/text()"/>
  <xsl:variable name="document" select="document/text()"/>
  <xsl:apply-templates select="document($document)/descendant-or-self::node()[@id=$id]" mode="dvi"/>
 </xsl:template>

 <xsl:template match="text()" mode="dvi">
 </xsl:template>

 <xsl:template match="*" mode="dvi">
  <xsl:apply-templates mode="dvi"/>
 </xsl:template>


 <xsl:template match="image" mode="html">
  <xsl:call-template name="escape"><xsl:with-param name="input" select="name/text()"/></xsl:call-template>
  <xsl:text>.lnk.jpg </xsl:text>
 </xsl:template>

 <xsl:template match="include" mode="html">
  <xsl:variable name="id" select="id/text()"/>
  <xsl:variable name="document" select="document/text()"/>
  <xsl:apply-templates select="document($document)/descendant-or-self::node()[@id=$id]" mode="html"/>
 </xsl:template>

 <xsl:template match="text()" mode="html">
 </xsl:template>

 <xsl:template match="*" mode="html">
  <xsl:apply-templates mode="html"/>
 </xsl:template>


 <xsl:template match="image" mode="link">
  <xsl:call-template name="escape"><xsl:with-param name="input" select="name/text()"/></xsl:call-template>
  <xsl:text>.lnk.jpg: </xsl:text>

  <xsl:call-template name="escape"><xsl:with-param name="input" select="location/text()"/></xsl:call-template>
  <xsl:text>/</xsl:text>
  <xsl:call-template name="escape"><xsl:with-param name="input" select="name/text()"/></xsl:call-template>
  <xsl:text>.jpg</xsl:text>

<xsl:text>
	ln -s "$&lt;" "$@"
</xsl:text>
 </xsl:template>

 <xsl:template match="include" mode="link">
  <xsl:variable name="id" select="id/text()"/>
  <xsl:variable name="document" select="document/text()"/>
  <xsl:apply-templates select="document($document)/descendant-or-self::node()[@id=$id]" mode="link"/>
 </xsl:template>

 <xsl:template match="text()" mode="link">
 </xsl:template>

 <xsl:template match="*" mode="link">
  <xsl:apply-templates mode="link"/>
 </xsl:template>

</xsl:stylesheet>

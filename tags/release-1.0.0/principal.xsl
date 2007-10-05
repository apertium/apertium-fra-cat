<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="UTF-8"/>

<xsl:template match="/">
  <xsl:value-of select="string('&#xa;')"/> <!-- \n -->
  <xsl:apply-templates select="dictionary"/> 
</xsl:template>

<xsl:template match="dictionary">
  <dictionary><xsl:value-of select="string('&#xa;')"/><!-- \n -->
  <xsl:apply-templates select="alphabet"/>
  <xsl:apply-templates select="sdefs"/>
  <xsl:apply-templates select="pardefs"/>
  <xsl:apply-templates select="section"/>
  </dictionary><xsl:value-of select="string('&#xa;')"/><!-- \n -->
</xsl:template>

<xsl:template name="alpha" match="alphabet">
  <alphabet>  
  <xsl:apply-templates />
  </alphabet><xsl:value-of select="string('&#xa;')"/> <!-- \n -->
</xsl:template>

<xsl:template match="sdefs">
  <sdefs>
  <xsl:apply-templates />
  </sdefs>
</xsl:template>

<xsl:template match="sdef">
  <xsl:copy-of select="."/>
</xsl:template>
<!-- Since here, a copy from the dictionary -->




<!-- Generates the new paradigms from pardef -->
<xsl:template match="pardefs">
  <xsl:value-of select="string('&#xa;')"/><!-- \n -->
  <pardefs><xsl:value-of select="string('&#xa;')"/><!-- \n -->

  <!-- Copy the dictionary original paradigms -->
  <xsl:apply-templates />
  <xsl:value-of select="string('&#xa;')"/><!-- \n -->


     <!-- Generates the news paradigms -->

      <!-- in variable mypardef we save the pardefs nodes of the dictionary-->
      <xsl:variable name="mypardefs" select="//pardefs"/>

      <xsl:for-each select="$paradigms">
      <!-- Here the body of each new paradigm -->
      <pardef n='{ concat(@name,"__",@prm) }'> <xsl:value-of select="string('&#xa;')"/><!-- \n -->

	 <!-- In the variable $paradigmname we save the name of the basic paradigm for expansion -->
         <xsl:variable name="paradigmname" select="./@name"/>
	 <!-- and in the variable $paradigmprm we save the name of the variable part for expansion -->
         <xsl:variable name="paradigmprm" select="./@prm"/>

         <xsl:call-template name="pardef-generated" select="$mypardefs/pardef[./@n=$paradigmname]">
	     <xsl:with-param name="parametro" select="$paradigmprm"/>
	     <xsl:with-param name="ambito" select="$mypardefs/pardef[./@n=$paradigmname]"/>
	 </xsl:call-template> 

      </pardef>
      <xsl:value-of select="string('&#xa;')"/><!-- \n -->
    </xsl:for-each> 

  </pardefs><!--<xsl:value-of select="string('&#xa;')"/>--><!-- \n -->
</xsl:template>





<!--
<xsl:template match="pardef">
    <xsl:copy-of select="."/>
</xsl:template>
-->
<xsl:template match="pardef">
    <pardef n='{@n}'> <xsl:value-of select="string('&#xa;')"/><!-- \n -->
    <xsl:apply-templates/>
    </pardef>
    <xsl:value-of select="string('&#xa;')"/><!-- \n -->
</xsl:template>

<xsl:template name='pardef-generated'>
   <xsl:param name="parametro"/>
   <xsl:param name="ambito"/>
   <xsl:apply-templates select="$ambito/e">
      <xsl:with-param name="parametro" select="$parametro"/>
   </xsl:apply-templates>
   <xsl:value-of select="string('&#xa;')"/> <!-- \n -->
</xsl:template>



<!-- Copy the rest of the dictionary deleting "prm" atribute from <par> nodes-->
<xsl:template match="section">
   <xsl:copy-of select="."/>
</xsl:template>

<xsl:template match="section">
  <xsl:value-of select="string('&#xa;')"/><!-- \n -->
  <section id='{@id}' type='{@type}'>
  <xsl:apply-templates />
  </section><xsl:value-of select="string('&#xa;')"/><!-- \n -->
</xsl:template>



<xsl:template match="e[@lm]"> <!-- with 'lm' atribute-->
<xsl:param name="parametro"/>
      <xsl:value-of select="string('                        ')"/>
      <e lm='{@lm}'>
         <xsl:apply-templates>
           <xsl:with-param name="parametro" select="$parametro"/>
         </xsl:apply-templates>
      </e>   <xsl:value-of select="string('&#xa;')"/> <!-- \n -->
</xsl:template>
<xsl:template match="e[@r]">  <!-- with 'r' atribute-->
<xsl:param name="parametro"/>
      <xsl:value-of select="string('                        ')"/>
      <e r='{@r}'>
         <xsl:apply-templates>
           <xsl:with-param name="parametro" select="$parametro"/>
         </xsl:apply-templates>
      </e>   <xsl:value-of select="string('&#xa;')"/> <!-- \n -->
</xsl:template>
<xsl:template match="e[not(@*)]">
<xsl:param name="parametro"/>
      <xsl:value-of select="string('                        ')"/>
      <e>
        <xsl:apply-templates>
           <xsl:with-param name="parametro" select="$parametro"/>
        </xsl:apply-templates>
      </e>   <xsl:value-of select="string('&#xa;')"/> <!-- \n -->
</xsl:template>


<!-- If the <par> node have "prm" atribute delete it, otherwise copy -->
<xsl:template match="par[@prm]">
       <par n='{ concat(@n,"__",@prm) }' />
</xsl:template>

<xsl:template match="par[not(@prm)]">
       <xsl:copy-of select="."/>
</xsl:template>
<!-- ********************************************************** -->


<xsl:template match="i">
<xsl:param name="parametro"/>
      <i>
        <xsl:apply-templates>
           <xsl:with-param name="parametro" select="$parametro"/>
        </xsl:apply-templates>
      </i>
</xsl:template>



<xsl:template match="p|re|s|a|b|j">
   <xsl:copy-of select="."/>
</xsl:template>

<xsl:template match="prm">
   <xsl:param name="parametro"/>
   <xsl:value-of select="$parametro"/>   
</xsl:template>


</xsl:stylesheet>

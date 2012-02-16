<?xml version="1.0" encoding="iso-8859-1" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dto2extjs="http://dto2extjs.faratasystems.com/"
  xmlns:exsl="http://exslt.org/common"
  xmlns:u="xalan://com.farata.dto2extjs.asap"
  exclude-result-prefixes="xsl dtodto2extjs exsl u"
  version="1.1" 
>
	<xsl:template match="/dto2extjs:class" mode="generated-file">
		<xsl:variable name="thisClass" select="@name"/>
    	<xsl:variable name="thisGeneratedClass">
			<xsl:call-template name="generated-superclass">
				<xsl:with-param name="packageName" select="$packageName"/>
				<xsl:with-param name="className" select="$className"/>   
				<xsl:with-param name="genPackage" select="$genPackage"/>   	
			</xsl:call-template>
    	</xsl:variable>
    	<xsl:variable name="superclass" select="dto2extjs:superclass"/>
		<xsl:variable name="scalarProperties" select="dto2extjs:property[not(@abstract = 'true') and (not(dto2extjs:OneToMany)) and (not(dto2extjs:ManyToOne))]"/>
		<xsl:variable name="relationProperties1M" select="dto2extjs:property[not(@abstract = 'true') and (dto2extjs:OneToMany)]"/>
		<xsl:variable name="relationPropertiesM1" select="dto2extjs:property[not(@abstract = 'true') and (dto2extjs:ManyToOne)]"/>
Ext.define('<xsl:value-of select="$thisGeneratedClass"/>', {
	extend: '<xsl:choose>
	<xsl:when test="$superclass"><xsl:value-of select="$superclass/@name"/></xsl:when>
		<xsl:otherwise>Ext.data.Model</xsl:otherwise>
	</xsl:choose>',
	<xsl:if test="$scalarProperties">
	fields: [
<xsl:apply-templates select="$scalarProperties" mode="scalarProperty"/>
	],
	</xsl:if>
	<xsl:if test="$relationProperties1M">
	hasMany: [
<xsl:apply-templates select="$relationProperties1M" mode="relationProperty1M"/>
	],
	</xsl:if>
	<xsl:if test="$relationPropertiesM1">
	belongsTo: [
<xsl:apply-templates select="$relationPropertiesM1" mode="relationPropertyM1"/>
	],
	</xsl:if>
	requires: [
		<xsl:key name="distinct-custom-types" match="dto2extjs:property[not(starts-with(@type, 'Ext.data.Types.')) or @contentType]" 
			use="@contentType | @type"/>
		<xsl:variable name="required-types">
			<xsl:if test="dto2extjs:property[starts-with(@type, 'Ext.data.Types.')]"><t>Ext.data.Types</t></xsl:if>
			<xsl:for-each select="dto2extjs:property[not(starts-with(@type, 'Ext.data.Types.')) or @contentType]">
				<xsl:if test="generate-id() = generate-id(key('distinct-custom-types', @contentType | @type))">
				<xsl:variable name="v">
					<xsl:choose>
						<xsl:when test="@contentType"><xsl:value-of select="@contentType"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="@type"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
	      		<t><xsl:value-of select="$v"/></t>
	      		</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:for-each select="exsl:node-set($required-types)/t">
		'<xsl:value-of select="."/>'<xsl:if test="last() != position()">,</xsl:if>
		</xsl:for-each>
	]
}
	</xsl:template>		

	<xsl:template match="dto2extjs:property" mode="relationPropertyM1">
		{
			model: '<xsl:value-of select="@type"/>',  
			getterName:'<xsl:value-of select="u:XsltUtils.getterFor(@name)"/>', 
			setterName:'<xsl:value-of select="u:XsltUtils.setterFor(@name)"/>',
			primaryKey:'<xsl:value-of select="dto2extjs:ManyToOne/@primaryKey"/>',
			foreignKey:'<xsl:value-of select="dto2extjs:ManyToOne/@foreignKey"/>'
		},
	</xsl:template>

  <xsl:template match="dto2extjs:property" mode="relationProperty1M">
  
	  <xsl:variable name="contentType">
	  	<xsl:call-template name="replace-once">
	  		<xsl:with-param name="text" select="@contentType"/>
	  		<xsl:with-param name="replace" select="'gen._'"/>
	  		<xsl:with-param name="by" select="''"/>
	  	</xsl:call-template>
	  </xsl:variable>
	  	
	  <xsl:variable name="storeType">
	  		<xsl:choose>
	  			<xsl:when test="not(dto2extjs:OneToMany/@storeType='')"><xsl:value-of select="dto2extjs:OneToMany/@storeType"/></xsl:when>
	  			<xsl:otherwise>
	  				<xsl:call-template name="inferStoreType">
	  					<xsl:with-param name="contentType" select="$contentType"/>
	  				</xsl:call-template>
	  			</xsl:otherwise>
	  		</xsl:choose>
	  </xsl:variable>
  
		{
			model: '<xsl:value-of select="$contentType"/>',
			name: '<xsl:value-of select="u:XsltUtils.getterFor(@name)"/>', 
			primaryKey:'<xsl:value-of select="dto2extjs:OneToMany/@primaryKey"/>',
			foreignKey:'<xsl:value-of select="dto2extjs:OneToMany/@foreignKey"/>',
			autoLoad: true,
			storeClassName:'<xsl:value-of select="$storeType"/>'
		},
  </xsl:template>	

  <xsl:template match="dto2extjs:property" mode="scalarProperty"><xsl:text>
</xsl:text>
		{
			name: '<xsl:value-of select="@name"/>',
			type: <xsl:value-of select="@type"/>,
			useNull: true
		},
  </xsl:template>	
  
<xsl:template name="tokenize">
  <xsl:param name="string" />
  <xsl:param name="delimiter" select="','" />
  <xsl:choose>
    <xsl:when test="$delimiter and contains($string, $delimiter)">"<xsl:value-of select="substring-before($string, $delimiter)" />", <xsl:call-template name="tokenize">
        <xsl:with-param name="string" 
                        select="substring-after($string, $delimiter)" />
        <xsl:with-param name="delimiter" select="$delimiter" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>"<xsl:value-of select="$string" />"</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="inferStoreType">
 <xsl:param name="contentType" />
  <xsl:variable name="contentClassName">
    <xsl:call-template name="unqualifyClassName"><xsl:with-param name="string" select="$contentType"/></xsl:call-template>	  	
  </xsl:variable>
  <xsl:variable name="contentPackageName" select="substring-before($contentType, concat('.', $contentClassName))"/>
  <xsl:call-template name="collectionsPackageFromDTOPackage"><xsl:with-param name="string" select="$contentPackageName"/><xsl:value-of select="$className"/></xsl:call-template>.<xsl:choose>
    	<xsl:when test="substring($contentClassName,string-length($contentClassName) - 2,3)='DTO'"><xsl:value-of select="substring($contentClassName,1,string-length($contentClassName) - 3)"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$contentClassName"/></xsl:otherwise>
	</xsl:choose>Collection</xsl:template>   	

<xsl:template name="inferFillArguments">
 <xsl:param name="contentType" />
  <xsl:variable name="contentClassName">
    <xsl:call-template name="unqualifyClassName"><xsl:with-param name="string" select="$contentType"/></xsl:call-template>	  	
  </xsl:variable>
  <xsl:variable name="contentPackageName" select="substring-before($contentType, concat('.', $contentClassName))"/>
  <xsl:call-template name="collectionsPackageFromDTOPackage"><xsl:with-param name="string" select="$contentPackageName"/><xsl:value-of select="$className"/></xsl:call-template>.<xsl:choose>
    	<xsl:when test="substring($contentClassName,string-length($contentClassName) - 2,3)='DTO'"><xsl:value-of select="substring($contentClassName,1,string-length($contentClassName) - 3)"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="$contentClassName"/></xsl:otherwise>
	</xsl:choose>Collection</xsl:template>  
 <xsl:template name="replace-once">
    <xsl:param name="text" />
    <xsl:param name="replace" />
    <xsl:param name="by" />
    <xsl:choose>
      <xsl:when test="contains($text, $replace)">
        <xsl:value-of select="substring-before($text,$replace)" />
        <xsl:value-of select="$by" />
      	<xsl:value-of select="substring-after($text,$replace)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  
 <xsl:template name="replace-all">
    <xsl:param name="text" />
    <xsl:param name="replace" />
    <xsl:param name="by" />
    <xsl:choose>
      <xsl:when test="contains($text, $replace)">
        <xsl:value-of select="substring-before($text,$replace)" />
        <xsl:value-of select="$by" />
        <xsl:call-template name="replace-all">
          <xsl:with-param name="text"
          select="substring-after($text,$replace)" />
          <xsl:with-param name="replace" select="$replace" />
          <xsl:with-param name="by" select="$by" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
<xsl:template name="collectionsPackageFromDTOPackage">
  <xsl:param name="string" />
  <xsl:param name="delimiter" select="'.'" />
  <xsl:choose>
    <xsl:when test="$delimiter and contains($string, $delimiter)"><xsl:value-of select="substring-before($string, $delimiter)" />.<xsl:call-template name="collectionsPackageFromDTOPackage">
        <xsl:with-param name="string" 
                        select="substring-after($string, $delimiter)" />
        <xsl:with-param name="delimiter" select="$delimiter" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>collections</xsl:otherwise>
  </xsl:choose>
</xsl:template> 

<xsl:template name="unqualifyClassName">
  <xsl:param name="string" />
  <xsl:param name="delimiter" select="'.'" />
  <xsl:choose>
    <xsl:when test="$delimiter and contains($string, $delimiter)"><xsl:call-template name="unqualifyClassName">
        <xsl:with-param name="string" 
                        select="substring-after($string, $delimiter)" />
        <xsl:with-param name="delimiter" select="$delimiter" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise><xsl:value-of select="$string" /></xsl:otherwise>
  </xsl:choose>
</xsl:template> 
  
</xsl:stylesheet>
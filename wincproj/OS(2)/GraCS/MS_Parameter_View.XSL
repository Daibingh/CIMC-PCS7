<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" encoding="UTF-8" version="4.0" indent="yes"/>
	
	<xsl:template name="transform-menues">
		<xsl:param name="menulayer"/>
			<tr bgcolor="#33FFFF">
				<xsl:element name="tr">
					<xsl:attribute name="title"><xsl:value-of select="LABEL/string"/>: 
<xsl:value-of select="HELP/string"/></xsl:attribute>
					<xsl:attribute name="bgcolor">#33FFFF</xsl:attribute>
					<td colspan="4">
						<xsl:value-of select="$menulayer"/>
						<xsl:text>  </xsl:text>
						<xsl:value-of select="LABEL/string"/>
					</td>
				</xsl:element>
			</tr>
			<xsl:for-each select="ITEMS/VARIABLE">
				<xsl:element name="tr">
					<xsl:attribute name="title"><xsl:value-of select="LABEL/string"/>: 
<xsl:value-of select="HELP/string"/></xsl:attribute>
					<xsl:attribute name="bgcolor">#D0D0D0</xsl:attribute>
					<xsl:element name="td">
						<xsl:attribute name="class">text</xsl:attribute>
						<xsl:choose>
							<xsl:when test="string-length(normalize-space(LABEL/string))">
								<xsl:value-of select="LABEL/string"/>
							</xsl:when>
							<xsl:otherwise> - </xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">text</xsl:attribute>
						<xsl:choose>
							<xsl:when test="string-length(normalize-space(variable_instance_data/DISPLAY_VALUE))">
								<xsl:value-of select="variable_instance_data/DISPLAY_VALUE"/>
							</xsl:when>
							<xsl:otherwise> - </xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">text</xsl:attribute>
						<xsl:choose>
							<xsl:when test="string-length(normalize-space(variable_instance_data/VARIABLE_UNIT))">
								<xsl:value-of select="variable_instance_data/VARIABLE_UNIT"/>
							</xsl:when>
							<xsl:otherwise> - </xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">text</xsl:attribute>
						<xsl:choose>
							<xsl:when test="string-length(normalize-space(variable_instance_data/VARIABLE_STATUS))">
								<xsl:value-of select="variable_instance_data/VARIABLE_STATUS"/>
							</xsl:when>
							<xsl:otherwise> - </xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
			<xsl:for-each select="ITEMS/MENU">
				<xsl:call-template name="transform-menues">
					<xsl:with-param name="menulayer">
						<xsl:value-of select="$menulayer"/> # </xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
	</xsl:template>

	<xsl:template match="/">
		<html>

			<script type="text/javascript">//<![CDATA[
				var oStatus=""			// =resize => resize iz started.				Send info from MouseDownOnTH() to BodyTrackMouse() and BodyMouseUp().
				var oSourceEle;		// source element of the mouse click.	Send info from MouseDownOnTH() to BodyTrackMouse().
				var oOldPos;			// old position of the mouse.				Send info from MouseDownOnTH() to BodyTrackMouse().
				var oColumnIndex;	// column index on which mouse down event has occured. Send info from MouseDownOnTH() to BodyTrackMouse() and BodyMouseUp().
				oResizeCursorState="NoResize" //is cursor left-right arrow?	
				
				//ie:ColResize
				//Variables that contains column width. 
				//	BodyTrackMouse() functon write width-values to this variables.
				//	Variables are through style-definition dynamically linked with two table headers: DataTable-header and Floating-header
				arySirinaCol = new Array()
				//set initial values for table width
				arySirinaCol[0]=0;		//array index 0 - not used.
				arySirinaCol[1]=150;
				arySirinaCol[2]=120;
				arySirinaCol[3]=100;
				arySirinaCol[4]=100;
				arySirinaCol[5]=300;
				arySirinaCol[6]=100;
				arySirinaCol[7]=80;
				arySirinaCol[8]=120;
				arySirinaCol[9]=150;
				
				//ie:ColResize
				//ie:	handlers for mouse-click on table header
				//		Table is ready-to-resize if mouse cursor is left-right arrow (mouse close to the cell-right). That is controlled onmousemove in a 	header.
				//OUTPUT:
				//		Set status to resize: oStatus="resize"
				//		Store column index on which mouse click has occured and SourceElement of the mouse click.
				function MouseDownOnTH( columnIndex )
				{
					if( oResizeCursorState=="Ready4Resize" )
					{
						oColumnIndex=columnIndex;			// remember column
						document.body.setCapture();
						oOldPos=event.clientX;				// store start x position
						oStatus="resize"					// set status to culomn resize
						oSourceEle = event.srcElement ;		//ie: store element on which the mouse event has occured
					}
				}
			
				//ie:ColResize
				//ie:	if status is 'resize', that means the mouse was in the capture state
				//		Measure mouse movement, by comparing recent with an old position, and react if bigger then increment
				//		Do resize by writing a new value to the dynamically linked variable
				function BodyTrackMouse()
				{
					if( oStatus=="resize" )
					{
						diff = parseInt(oOldPos) - event.clientX;
						if( (parseInt(diff) > 10) || (parseInt(diff) < -10) )
						{
							if( (oSourceEle.tagName=="TH") || (oSourceEle.tagName=="TD") )
							{
								oOldPos=event.clientX;
								arySirinaCol[oColumnIndex] = parseInt(arySirinaCol[oColumnIndex]) - parseInt(diff);
							}
						}
					}
				}
				
				// ie:ColResize
				//		check if mouse is in capture state, and release it
				//		Set status to empty
				function BodyMouseUp()
				{
					// alert( "up" )
					if( oStatus=="resize" )
					{
						// alert( "release" )
						document.body.releaseCapture();	//stop tracking mouse
						oStatus="";							//reset status 
						oCulomnName="";
						oColumnIndex=0;
					}
				}
				
				//ie:ColResize
				//Function returns width for table columns.
				//It is used in a style-expressions with the expression() keyword
				//For each table header one style is defined: Style names: stylWidthCol1, stylWidthCol2...
				//Styles are applied to the DataTable header and to the FloatingHeader
				function fnGetWidthCol( index )
				{ 	
					return arySirinaCol[index];		
				}
				
				//ie:FloatingHeader 
				//keep top position. Function return position at the visible window-top.
				function fnGetCurrentTop()
				{
					return document.body.scrollTop;
				}
				
				//ie:ColResize
				//When mouse is close to the header-cell-right <th> element, change it to the left/right arrow.
				//Limit this action only when mouse-click occurs directly on the <th> element, no subelement.
				//return:
				//	Function returns value in the global variable oResizeCursorState, that will be used OnMouseDown
				function SetColumnCursor()
				{	
					thisObject=event.srcElement;	
					if( (thisObject.clientWidth - event.offsetX) < 9	// if mouse is close to the right end
						&& thisObject.tagName=="TH" )					// and if event occured directly on the TH element
					{
							thisObject.style.cursor="col-resize";
							oResizeCursorState="Ready4Resize"
					}
					else
					{
						thisObject.style.cursor="auto";	
						oResizeCursorState="NoResize"
					}
				}
	
				//-----------------------------------------------------------------------------
				// Functions to get and compare values during a sort.
				//-----------------------------------------------------------------------------
				
				// This code is necessary for browsers that don't reflect the DOM constants
				// (like IE).
				if (document.ELEMENT_NODE == null) 
				{
					document.ELEMENT_NODE = 1;
					document.TEXT_NODE = 3;
				}

				 function right(msg)
				{
					if ((event.button == 2) || (event.button == 3))
					{
						alert(msg);
						return false;
					}
					return true;
				}
				
			
			//]]></script>
			<STYLE>
				<!-- ie:FloatingHeader - style is applied to both FloatingHeader and DataTable header -->
				<!-- ie:ColResize - Column width is stored in an array variable and dynamically linked to the style -->
				<!-- ie: style-definition for oclumn width
				  -	Each column has its own style. Two tables have the same style for corresponding columns.
				  - Style is of expression-type. Width for each columne is stored in an array variable.
				-->
				.stylWidthCol1 {width:expression( fnGetWidthCol( 1 ) ); }
				.stylWidthCol2 {width:expression( fnGetWidthCol( 2 ) ); }
				.stylWidthCol3 {width:expression( fnGetWidthCol( 3 ) ); }
				.stylWidthCol4 {width:expression( fnGetWidthCol( 4 ) ); }
				.stylWidthCol5 {width:expression( fnGetWidthCol( 5 ) ); }
				.stylWidthCol6 {width:expression( fnGetWidthCol( 6 ) ); }
				.stylWidthCol7 {width:expression( fnGetWidthCol( 7 ) ); }
				.stylWidthCol8 {width:expression( fnGetWidthCol( 8 ) ); }
				.stylWidthCol9 {width:expression( fnGetWidthCol( 9 ) ); }
			</STYLE>
			<!-- ie: next styles were defined by the sort-table example, 				-->
			<!-- except:																	-->
			<!--		table-layout:fixed; important to synchronize width of two tables	-->
			<!-- ======================================================================= -->
			<style type="text/css">
			/* Table styles. */
			
				table {
				  border-color: #000000;
				  border-spacing: 0px;
				  border-style: solid;
				  border-width: 2px;
				  cell-spacing: 0px;
				  table-layout:fixed;	//ie:ColResize: fix table column size, so column-wodth of two tables can mirror each oder 
				}
				
				td {  font-family: Arial, Helvetica, sans-serif;  font-size: 9pt;  padding: 1px 0.2em;}
				th {  font-family: Arial, Helvetica, sans-serif;  font-size: 10pt;  padding: 4px 0.5em;}
				td.numeric {  text-align: right;}
				td.text {  text-align: left;}
				th {  background-color: #c0c0c0;}
				th.mainHeader {  background-color: #808080;  color: #ffffff;  text-align: left;}
				th a {  color: #000080;  text-decoration: none;}
				th a:visited {  color: #000080;}
				th a:active {  color: #800000; text-decoration: underline;}
				th a:hover {  color: green;  text-decoration: underline;}
				th.sortedColumnUp {  background-image:url(sortup.bmp); background-repeat:no-repeat;}
				th.sortedColumnDown {  background-image:url(sortdown.bmp); background-repeat:no-repeat;}
				tr.alternateRow {  background-color: #e0e0e0;}
				td.sortedColumn {  background-color: #8080ff;}
				th.sortedColumn {  background-color: #b0b0ff;}
				tr.alternateRow td.sortedColumn {  background-color: #d0d0ff;}
			</style>
			<head>
				<!--
					MSXML generiert unmittelbar nach diesem <head> ein
						<META http-equiv="Content-Type" content="text/html; charset=UTF-8">
					(natuerlich) ohne schliessendes Tag. Damit entsteht aber nicht-wohlgeformtes
					XML, und wenn dieses Stylesheet per Script und transformNodeToObject()
					aufgerufen wird, so schlaegt die Transformation fehl und die Zieldatei bleibt leer.
					(Statischer Einbindung als Stylesheet funktioniert.)
					Wir erzeugen deshalb hier ein schliessendes </META>:
				-->
				<xsl:text disable-output-escaping="yes">&lt;/META&gt;</xsl:text>
				<!-- Hier muessen wir ebenfalls tricksen: -->
				<xsl:element name="link">
					<xsl:attribute name="rel">stylesheet</xsl:attribute>
					<xsl:attribute name="type">text/css</xsl:attribute>
					<xsl:attribute name="href">pdm.css</xsl:attribute>
				</xsl:element>
				<xsl:text disable-output-escaping="yes">&lt;/link&gt;</xsl:text>
			</head>
			<!-- body element has two handlers to be used for column-resize -->
			<body onmousemove="BodyTrackMouse()" onmouseup="BodyMouseUp()">
				<!--	Important: div-style must match the div-style of the FloatingHeader, with the exception of the top attribute that is for this data-table fixed 	-->
				<div style="position: absolute; left:10; top:1; ">
					<table z-index="-1" scrollTop="0" height="document.body.clientHeight" border="10" rules="all" cellpadding="0" cellspacing="0">
						<thead height="0">
							<tr>
								<!-- ie:ColResize -->
								<!-- th element must provide onmousedown handler to handle resize actions, and a style-class  -->
								<!-- the same style-class must be set to the floating-header -->
								<!-- for table sort, there is a onclick() handler. It is defied in TH or in child element of TH, if one exists. -->
								<!-- NOTE that this header is not visible. It scrolls-out of the visible window, or is overlaped with the FloatingHeader -->
								<th onmousedown="MouseDownOnTH(1)" class="stylWidthCol1">Name</th>
								<th onmousedown="MouseDownOnTH(2)" class="stylWidthCol2">Value</th>
								<th onmousedown="MouseDownOnTH(3)" class="stylWidthCol3">Unit</th>
								<th onmousedown="MouseDownOnTH(4)" class="stylWidthCol4">Status</th>
							</tr>
						</thead>
						<tbody id="offTblBdy">
							<xsl:for-each select="//Object/EDDL/description/MENU[(@id='Table_Main_Maintenance')]">
								<xsl:call-template name="transform-menues">
									<xsl:with-param name="menulayer"/>
								</xsl:call-template>
							</xsl:for-each>
						</tbody>
					</table>
				</div>
				<!-- ie:FloatingHeader -->
				<!-- Top-atribute is calculated from the scrollbar position and keeps header always on window top -->
				<!--	ie: this header line stays always on the window top -->
				<!--	Important: style must be equal to the data-table style, with the exception of the top attribute that positions floating header alway on top -->
				<div style="position: absolute; left:10; top: expression(fnGetCurrentTop());	">
					<table border="10" cellpadding="0" cellspacing="0">
						<thead z-index="9" id="fixTblHead">
							<tr>
								<!-- ie:ColResize -->
								<!-- th element must provide onmousedown handler to handle resize actions, and a style-class  -->
								<!-- the same style-class must be set to the floating-header -->
								<!-- for table sort, there is a onclick() handler. It is defied in TH or in child element of TH, if one exists. -->
								<!-- This header is visible. It controls the table resize and sort. Its style must be mostly equal to the DataTable header, to overlap it. -->
								<th onmousedown="MouseDownOnTH(1)" onmousemove="SetColumnCursor()" class="stylWidthCol1">Name</th>
								<th onmousedown="MouseDownOnTH(2)" onmousemove="SetColumnCursor()" class="stylWidthCol2">Value
</th>
								<th onmousedown="MouseDownOnTH(3)" onmousemove="SetColumnCursor()" class="stylWidthCol3">Unit</th>
								<th onmousedown="MouseDownOnTH(4)" onmousemove="SetColumnCursor()" class="stylWidthCol4">Status</th>
							</tr>
						</thead>
					</table>
				</div>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>

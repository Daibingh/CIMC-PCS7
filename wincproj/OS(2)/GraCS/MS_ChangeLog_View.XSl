<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" encoding="UTF-8" version="4.0" indent="yes"/>
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
				arySirinaCol[2]=130;
				arySirinaCol[3]=300;
				arySirinaCol[4]=300;
				arySirinaCol[5]=100;
				arySirinaCol[6]=80;
				arySirinaCol[7]=250;
				arySirinaCol[8]=150;
				
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
				// sortTable(id, col, rev)
				//
				//  id  - ID of the TABLE, TBODY, THEAD or TFOOT element to be sorted.
				//  col - Index of the column to sort, 0 = first column, 1 = second column,
				//        etc.
				//  rev - If true, the column is sorted in reverse (descending) order
				//        initially.
				//
				// Note: the team name column (index 1) is used as a secondary sort column and
				// always sorted in ascending order.
				//-----------------------------------------------------------------------------
				
				function sortTable(id, col, rev) 
				{
					// Get the table or table section to sort.
					var tblEl = document.getElementById(id);

					// The first time this function is called for a given table, set up an
					// array of reverse sort flags.
					if (tblEl.reverseSort == null) 
					{
						tblEl.reverseSort = new Array();
						// Also, assume the team name column is initially sorted.
						tblEl.lastColumn = 0;	//AM
					}

					// If this column has not been sorted before, set the initial sort direction.
					if (tblEl.reverseSort[col] == null)
						tblEl.reverseSort[col] = rev;

					// If this column was the last one sorted, reverse its sort direction.
					if (col == tblEl.lastColumn)
						tblEl.reverseSort[col] = !tblEl.reverseSort[col];

					// AM for secondary sort column
					var lastcol = col;	
					if (!(tblEl.lastColumn == undefined))
						lastcol = tblEl.lastColumn;

					// Remember this column as the last one sorted.
					tblEl.lastColumn = col;

					// Set the table display style to "none" - necessary for Netscape 6 
					// browsers.
					var oldDsply = tblEl.style.display;
					tblEl.style.display = "none";

					// Sort the rows based on the content of the specified column using a
					// selection sort.

					var tmpEl;
					var i, j;
					var minVal, minIdx;
					var testVal;
					var cmp;

					for (i = 0; i < tblEl.rows.length - 1; i++) 
					{
						// Assume the current row has the minimum value.
						minIdx = i;
						minVal = getTextValue(tblEl.rows[i].cells[col]);

						// Search the rows that follow the current one for a smaller value.
						for (j = i + 1; j < tblEl.rows.length; j++) 
						{
							testVal = getTextValue(tblEl.rows[j].cells[col]);
							cmp = compareValues(minVal, testVal);
							// Negate the comparison result if the reverse sort flag is set.
							if (tblEl.reverseSort[col])
								cmp = -cmp;
							// Sort by the secondary column (last sort column) if those values are equal.
							if (cmp == 0 && col != lastcol)
							{
								cmp = compareValues(getTextValue(tblEl.rows[minIdx].cells[lastcol]), getTextValue(tblEl.rows[j].cells[lastcol]));
								if (tblEl.reverseSort[lastcol])
									cmp = -cmp;
							}

							// If this row has a smaller value than the current minimum, remember its
							// position and update the current minimum value.
							if (cmp > 0) 
							{
								minIdx = j;
								minVal = testVal;
							}
						}

						// By now, we have the row with the smallest value. Remove it from the
						// table and insert it before the current row.
						if (minIdx > i) 
						{
							tmpEl = tblEl.removeChild(tblEl.rows[minIdx]);
							tblEl.insertBefore(tmpEl, tblEl.rows[i]);
						}
					}

					// Make it look pretty.
					makePretty(tblEl, col, (tblEl.reverseSort[col]));

					// Set team rankings.
					// setRanks(tblEl, col, rev);		AM: auskommentiert

					// Restore the table's display style.
					tblEl.style.display = oldDsply;

					return false;
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
				
				function getTextValue(el) 
				{
					var i;
					var s;

					// Find and concatenate the values of all text nodes contained within the
					// element.
					s = "";
					for (i = 0; i < el.childNodes.length; i++)
						if (el.childNodes[i].nodeType == document.TEXT_NODE)
							s += el.childNodes[i].nodeValue;
						else if (el.childNodes[i].nodeType == document.ELEMENT_NODE && el.childNodes[i].tagName == "BR")
						s += " ";
						else
						// Use recursion to get text within sub-elements.
							s += getTextValue(el.childNodes[i]);

					return normalizeString(s);
				}
				
				function compareValues(v1, v2) 
				{
					var f1, f2;

					// If the values are numeric, convert them to floats.
					f1 = parseFloat(v1);
					f2 = parseFloat(v2);
					if (!isNaN(f1) && !isNaN(f2) && (v1.search(":") == -1) && (v2.search(":") == -1)) 
					{
						v1 = f1;
						v2 = f2;
					}

					// Compare the two values.
					if (v1 == v2)
						return 0;
					if (v1 > v2)
						return 1
					return -1;
				}
				
				// Regular expressions for normalizing white space.
				var whtSpEnds = new RegExp("^\\s*|\\s*$", "g");
				var whtSpMult = new RegExp("\\s\\s+", "g");
				
				function normalizeString(s) 
				{
					s = s.replace(whtSpMult, " ");  // Collapse any multiple whites space.
					s = s.replace(whtSpEnds, "");   // Remove leading or trailing white space.

					return s;
				}
				
				//-----------------------------------------------------------------------------
				// Functions to update the table appearance after a sort.
				//-----------------------------------------------------------------------------
				
				// Style class names.
				var rowClsNm = "alternateRow";
				var colClsNm = "sortedColumn";
				var colClsNmUp   = "sortedColumnUp";
				var colClsNmDown = "sortedColumnDown";
				
				// Regular expressions for setting class names.
				var rowTest = new RegExp(rowClsNm, "gi");
				var colTest = new RegExp(colClsNm, "gi");
				var colTestUp   = new RegExp(colClsNmUp,   "gi");
				var colTestDown = new RegExp(colClsNmDown, "gi");


				function makePretty(tblEl, col, reverseSort) 
				{
					var i, j;
					var rowEl, cellEl;

					// Set style classes on each row to alternate their appearance.
					for (i = 0; i < tblEl.rows.length; i++) 
					{
						rowEl = tblEl.rows[i];
						rowEl.className = rowEl.className.replace(rowTest, "");
						if (i % 2 != 0)
							rowEl.className += " " + rowClsNm;
						rowEl.className = normalizeString(rowEl.className);
						// Set style classes on each column (other than the name column) to
						// highlight the one that was sorted.
						for (j = 0; j < tblEl.rows[i].cells.length; j++) 
						{
							cellEl = rowEl.cells[j];
							cellEl.className = cellEl.className.replace(colTest, "");
							if (j == col)
								cellEl.className += " " + colClsNm;
							cellEl.className = normalizeString(cellEl.className);
						}
					}

					// Find the table header and highlight the column that was sorted.
					var fixtblhdEl = document.getElementById("fixTblHead");
					rowEl = fixtblhdEl.rows[fixtblhdEl.rows.length - 1];
					// Set style classes for each column as above.
					for (i = 0; i < rowEl.cells.length; i++) 
					{
						cellEl = rowEl.cells[i];
						cellEl.className = cellEl.className.replace(colTestUp, "");
						cellEl.className = cellEl.className.replace(colTestDown, "");
						// Highlight the header of the sorted column.
						if (i == col)
						{
							if (reverseSort)
								cellEl.className += " " + colClsNmDown;
							else
								cellEl.className += " " + colClsNmUp;
						}
						cellEl.className = normalizeString(cellEl.className);
					}
				}
				
				function setRanks(tblEl, col, rev) 
				{
					// Determine whether to start at the top row of the table and go down or
					// at the bottom row and work up. This is based on the current sort
					// direction of the column and its reversed flag.

					var i    = 0;
					var incr = 1;
					if (tblEl.reverseSort[col])
						rev = !rev;
					if (rev) 
					{
						incr = -1;
						i = tblEl.rows.length - 1;
					}

					// Now go through each row in that direction and assign it a rank by
					// counting 1, 2, 3...

					var count   = 1;
					var rank    = count;
					var curVal;
					var lastVal = null;

					// Note that this loop is skipped if the table was sorted on the name
					// column.
					while (i >= 0 && i < tblEl.rows.length) 
					{
						// Get the value of the sort column in this row.
						curVal = getTextValue(tblEl.rows[i].cells[col]);

						// On rows after the first, compare the sort value of this row to the
						// previous one. If they differ, update the rank to match the current row
						// count. (If they are the same, this row will get the same rank as the
						// previous one.)
						if (lastVal != null && compareValues(curVal, lastVal) != 0)
							rank = count;
						// Set the rank for this row.
						tblEl.rows[i].rank = rank;

						// Save the sort value of the current row for the next time around and bump
						// the row counter and index.
						lastVal = curVal;
						count++;
						i += incr;
					}

					// Now go through each row (from top to bottom) and display its rank. Note
					// that when two or more rows are tied, the rank is shown on the first of
					// those rows only.

					var rowEl, cellEl;
					var lastRank = 0;

					// Go through the rows from top to bottom.
					for (i = 0; i < tblEl.rows.length; i++) 
					{
						rowEl = tblEl.rows[i];
						cellEl = rowEl.cells[0];
						// Delete anything currently in the rank column.
						while (cellEl.lastChild != null)
							cellEl.removeChild(cellEl.lastChild);
						// If this row's rank is different from the previous one, Insert a new text
						// node with that rank.
						if (col > 1 && rowEl.rank != lastRank) 
						{
							cellEl.appendChild(document.createTextNode(rowEl.rank));
							lastRank = rowEl.rank;
						}
					}
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
			<body onmousemove="BodyTrackMouse()"  onmouseup="BodyMouseUp()">
				
				<!--	Important: div-style must match the div-style of the FloatingHeader, with the exception of the top attribute that is for this data-table fixed 	-->
				<div style="position: absolute; left:10; top:1; ">
					<table z-index="-1" scrollTop="0" height="document.body.clientHeight" border="10" rules="all" cellpadding="0" cellspacing="0">
						<thead height="0">
							<tr >
								<!-- ie:ColResize -->
								<!-- th element must provide onmousedown handler to handle resize actions, and a style-class  -->
								<!-- the same style-class must be set to the floating-header -->
								<!-- for table sort, there is a onclick() handler. It is defied in TH or in child element of TH, if one exists. -->
								<!-- NOTE that this header is not visible. It scrolls-out of the visible window, or is overlaped with the FloatingHeader -->
								<th onmousedown="MouseDownOnTH(1)" class="stylWidthCol1"><a href="" onclick="this.blur(); return sortTable('offTblBdy',  0, true);" title="Date and Time">Datum</a></th>
								<th onmousedown="MouseDownOnTH(2)" class="stylWidthCol2"><a href="" onclick="this.blur(); return sortTable('offTblBdy',  1, true);" title="Action Name">Aktion</a></th>
								<th onmousedown="MouseDownOnTH(3)" class="stylWidthCol3"><a href="" onclick="this.blur(); return sortTable('offTblBdy',  2, true);" title="Kommentar Text">Kommentar</a></th>
								<th onmousedown="MouseDownOnTH(4)" class="stylWidthCol4"><a href="" onclick="this.blur(); return sortTable('offTblBdy',  3, true);" title="Details Text">Details</a></th>
								<th onmousedown="MouseDownOnTH(5)" class="stylWidthCol5"><a href="" onclick="this.blur(); return sortTable('offTblBdy',  4, true);" title="Benutzer Name"  >Benutzer</a></th>
								<th onmousedown="MouseDownOnTH(6)" class="stylWidthCol6"><a href="" onclick="this.blur(); return sortTable('offTblBdy',  5, true);" title="Computer Name">Computer</a></th>
								<th onmousedown="MouseDownOnTH(7)" class="stylWidthCol7"><a href="" onclick="this.blur(); return sortTable('offTblBdy',  6, true);" title="Object Path Name">Pfad</a></th>
								<th onmousedown="MouseDownOnTH(8)" class="stylWidthCol8"><a href="" onclick="this.blur(); return sortTable('offTblBdy',  7, true);" title="Import Date Name">Import-Datum</a></th>
							</tr>
						</thead>
						<tbody id="offTblBdy">
							<xsl:for-each select="//LOG/ENTRY">
<!--								<xsl:sort order="ascending" select="DATETIME"/>				-->
								<xsl:element name="tr">
									<xsl:choose>
	               						<xsl:when test="(position()+1) mod 2"> 
											<xsl:attribute name="class">alternateRow</xsl:attribute> 
										</xsl:when>
									</xsl:choose>
									<xsl:element name="td">
										<xsl:attribute name="class">text</xsl:attribute>
										<xsl:choose>	               							
	               							<xsl:when test="string-length(normalize-space(DATETIME))"> <xsl:value-of select="DATETIME"/> </xsl:when>
  											<xsl:otherwise> - </xsl:otherwise>
										</xsl:choose>
									</xsl:element>
									<xsl:element name="td">
										<xsl:attribute name="class">text</xsl:attribute>
										<xsl:choose>
	               							<xsl:when test="string-length(normalize-space(ACTION))"> <xsl:value-of select="ACTION"/> </xsl:when>
  											<xsl:otherwise> - </xsl:otherwise>
										</xsl:choose>
									</xsl:element>
									<xsl:element name="td">
										<xsl:attribute name="class">numeric</xsl:attribute>
										<xsl:choose>
	               							<xsl:when test="string-length(normalize-space(EVENT))"> <xsl:value-of select="EVENT"/> </xsl:when>
  											<xsl:otherwise> - </xsl:otherwise>
										</xsl:choose>
									</xsl:element>
									<xsl:element name="td">
										<xsl:attribute name="class">text</xsl:attribute>
										<xsl:choose>
	               							<xsl:when test="string-length(normalize-space(CAUSE))"> <xsl:value-of select="CAUSE"/> </xsl:when>
  											<xsl:otherwise> - </xsl:otherwise>
										</xsl:choose>
									</xsl:element>
									<xsl:element name="td">
										<xsl:attribute name="class">text</xsl:attribute>
										<xsl:choose>
	               							<xsl:when test="string-length(normalize-space(USER))"> <xsl:value-of select="USER"/> </xsl:when>
  											<xsl:otherwise> - </xsl:otherwise>
										</xsl:choose>
									</xsl:element>
									<xsl:element name="td">
										<xsl:attribute name="class">text</xsl:attribute>
										<xsl:choose>
	               							<xsl:when test="string-length(normalize-space(COMPUTER))"> <xsl:value-of select="COMPUTER"/> </xsl:when>
  											<xsl:otherwise> - </xsl:otherwise>
										</xsl:choose>
									</xsl:element>
									<xsl:element name="td">
										<xsl:attribute name="class">text</xsl:attribute>
										<xsl:choose>
	               							<xsl:when test="string-length(normalize-space(OBJECTPATH))"> <xsl:value-of select="OBJECTPATH"/> </xsl:when>
  											<xsl:otherwise> - </xsl:otherwise>
										</xsl:choose>
									</xsl:element>									
									<xsl:element name="td">
										<xsl:attribute name="class">text</xsl:attribute>
										<xsl:choose>
	               							<xsl:when test="string-length(normalize-space(IMPORTDT))"> <xsl:value-of select="IMPORTDT"/> </xsl:when>
  											<xsl:otherwise> - </xsl:otherwise>
										</xsl:choose>
									</xsl:element>
								</xsl:element>
							</xsl:for-each>
						</tbody>
					</table>
				</div>
					
					
				<!-- ie:FloatingHeader -->
				<!-- Top-atribute is calculated from the scrollbar position and keeps header always on window top -->
				<!--	ie: this header line stays always on the window top -->
				<!--	Important: style must be equal to the data-table style, with the exception of the top attribute that positions floating header alway on top -->
				<div style="position: absolute; left:10; top: expression(fnGetCurrentTop());	">
					<table  border="10" cellpadding="0" cellspacing="0" >
						<thead z-index="9" id="fixTblHead">
							<tr >
								<!-- ie:ColResize -->
								<!-- th element must provide onmousedown handler to handle resize actions, and a style-class  -->
								<!-- the same style-class must be set to the floating-header -->
								<!-- for table sort, there is a onclick() handler. It is defied in TH or in child element of TH, if one exists. -->
								<!-- This header is visible. It controls the table resize and sort. Its style must be mostly equal to the DataTable header, to overlap it. -->
								<th onmousedown="MouseDownOnTH(1)" onmousemove="SetColumnCursor()" class="stylWidthCol1"><a href="" onclick="this.blur(); return sortTable('offTblBdy',  0, true);" title="Date Time">Datum</a></th>
								<th onmousedown="MouseDownOnTH(2)" onmousemove="SetColumnCursor()" class="stylWidthCol2"><a href="" onclick="this.blur(); return sortTable('offTblBdy',  1, true);" title="Action">Aktion</a></th>
								<th onmousedown="MouseDownOnTH(3)" onmousemove="SetColumnCursor()" class="stylWidthCol3"><a href="" onclick="this.blur(); return sortTable('offTblBdy',  2, true);" title="Kommentar">Kommentar</a></th>
								<th onmousedown="MouseDownOnTH(4)" onmousemove="SetColumnCursor()" class="stylWidthCol4"><a href="" onclick="this.blur(); return sortTable('offTblBdy',  3, true);" title="Details">Details</a></th>
								<th onmousedown="MouseDownOnTH(5)" onmousemove="SetColumnCursor()" class="stylWidthCol5"><a href="" onclick="this.blur(); return sortTable('offTblBdy',  4, true);" title="Benutzer">Benutzer</a></th>
								<th onmousedown="MouseDownOnTH(6)" onmousemove="SetColumnCursor()" class="stylWidthCol6"><a href="" onclick="this.blur(); return sortTable('offTblBdy',  5, true);" title="Computer">Computer</a></th>
								<th onmousedown="MouseDownOnTH(7)" onmousemove="SetColumnCursor()" class="stylWidthCol7"><a href="" onclick="this.blur(); return sortTable('offTblBdy',  6, true);" title="Object Path">Pfad</a></th>
								<th onmousedown="MouseDownOnTH(8)" onmousemove="SetColumnCursor()" class="stylWidthCol8"><a href="" onclick="this.blur(); return sortTable('offTblBdy',  7, true);" title="Import Date">Import-Datum</a></th>
							</tr>
						</thead>
					</table>
				</div>

			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>

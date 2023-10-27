#Include "Thor_Proc_IntellisenseX.h"

*	Columns in toISX.aList (only the first is required)
*		[, 1] = Property Name (UPPER -- not displayed)
*		[, 2] = Display (1st column)
*		[, 3] = Display (2nd column)
*		[, 4] = Display (3rd column)
*		[, 5] = Image name
*		[, 6] = Parameters (in parens)

* --------------------------------------------------------------------------------

*====================================================================
* The following class displays a popup window at the current cursor
* position and lets the user continue to type.
*
* The characters a-z, A-Z, 0-9 and _ are inserted into the active
* edit window as the user types. The previous position is saved in
* order to restore the text if necessary.
*
* ESC terminates the popup and doesn't change the text.
*
* TAB inserts the current selection and terminates the popup.
*
* SPACEBAR inserts the current selection, adds a blank and terminates
* the popup.
*
* Any other key terminates the popup and is repeated so it is handled
* properly by VFP. If the user enters the first character that
* doesn't match an item in the list, or entered a full item where
* none exists that has the same name, but additional characters, the
* list is terminated as well.
*
*====================================================================
Define Class isxForm As Form
	AlwaysOnTop = .T.
	WindowType = 1
	TitleBar = 0
	* ================================================================================ 
	BorderStyle = 3
	* ================================================================================ 
	nWHandle = 0
	nCurrentPos = 0
	cSearchString = ""
	cVarString = ""
	Dimension aItems[1,3]
	Dimension aItemsSource[1,3]
	lScrolled = .F.
	*Mike Yearwood - these support reducing screen caption flicker
	cScreenCaption = ""
	cWindowCaption = ""
	lMaximized = .F.
	cOnKeyLabelDocActivation = ''
	oISX = null
	oISXOptions = .Null.
	lSearchSecondColumn  = .F.
	lDotIsTerminator = .T.
	lRemoveDot = .F.
	nWidthDifference = 0
	lResized = .F.
	
	Add Object isxList As ListBox With ;
		ColumnCount = 2, ;
		ColumnLines = .F., ;
		IncrementalSearch = .F., ;
		AutoHideScrollBar = 1
	* ================================================================================ 
	Procedure Resize
		This.lResized = .T.
		This.ResizeListBox()
	EndProc 


	Procedure ResizeListBox
		Local lcColumnWidths
		With This.ISXList
			.Height	= This.Height
			.Width	= This.Width
	
			lcColumnWidths = .ColumnWidths
			If Val(GetWordNum(lcColumnWidths, 4, ',')) = 0
				.ColumnWidths  = Left(m.lcColumnWidths, At(',', m.lcColumnWidths, 2)) + Alltrim(Str(Max(1,This.Width - This.nWidthDifference))) + Substr(m.lcColumnWidths, At(',', m.lcColumnWidths, 3))
			Else
				.ColumnWidths  = Left(m.lcColumnWidths, At(',', m.lcColumnWidths, 3)) + Alltrim(Str(Max(1,This.Width - This.nWidthDifference))) + Substr(m.lcColumnWidths, At(',', m.lcColumnWidths, 4))
			EndIf
		Endwith
	Endproc
		
	* ================================================================================ 
	
	Procedure Load
		This.lMaximized = Wmaximum()
		If This.lMaximized
			This.cWindowCaption = Lower(Wtitle())
			This.cScreenCaption = _Screen.Caption
		Endif
		Return DoDefault()
	Endproc
	Procedure Show
		*====================================================================
		* Mike Yearwood
		* When the edit window is maximized, the screen caption reads
		* currentedit.prg * - current vfp system window caption
		* When this window goes active, the screen caption changes
		* which causes a flicker. To stop that flicker, set the screen
		* caption to what it was before.
		*====================================================================
		If This.lMaximized
			_Screen.Caption = This.cWindowCaption + " * - " + This.cScreenCaption
		Endif
		*** JRN 9/11/2011 : remove dot activation while this form is active
		#Ifdef DOT_ACTIVATION
			This.cOnKeyLabelDocActivation = On('Key', [DOT_ACTIVATION])
			On Key Label DOT_ACTIVATION
		#Endif
	Endproc
	Procedure Destroy
	
		*!* ******** JRN Removed 2022-11-24 ********
		*!* If This.lResized
		*!* 	Execscript(_Screen.cThorDispatcher, 'Set Option=', 'Height', 'ISX Window', This.Height)
		*!* 	Execscript(_Screen.cThorDispatcher, 'Set Option=', 'Width', 'ISX Window', This.Width)
		*!* EndIf 

		*Mike Yearwood
		*Prevent screen caption flicker.
		If This.lMaximized
			_Screen.Caption = This.cScreenCaption
		Endif
		*** JRN 9/11/2011 : restore dot activation
		#Ifdef DOT_ACTIVATION
			Local lcOnKeyLabelDocActivation
			lcOnKeyLabelDocActivation = This.cOnKeyLabelDocActivation
			On Key Label DOT_ACTIVATION  &lcOnKeyLabelDocActivation
		#Endif
	Endproc
	*====================================================================
	* When the form is initialized, we have to determine its position
	* and get a handle to the current edit window. Pass an array to this
	* form that contains all possible values the user can enter.
	*====================================================================
	Procedure Init
		Lparameter toISX
		Local laValues[1], lcInput, lcValue, lcVarString, lnAvgCharWidth, lnCol, lnColumnCount, lnEndPos
		Local lnHeight, lnIndex, lnLeft, lnLineHeight, lnMaxColumn2Width, lnMaxColumn3Width, lnMaxWidth, lnStartPos, lnTop
		Local lnTotalWidth, lnValue, lnWidth
		With This
			*-----------------------------------------------------------------
			* Get the handle for the current window.
			*-----------------------------------------------------------------
			.oISX        = toISX
			.nWHandle	 = m.toISX.nWHandle
			.nCurrentPos = This.oIsx.GetFileCursorPos( .nWHandle )
			*-----------------------------------------------------------------
			* Copy the array and sort it case-insensitive
			*-----------------------------------------------------------------
			If 0 = Alen(m.toISX.aList, 2)
				Dimension m.toISX.aList[Alen(m.toISX.aList, 1), 1]
			Endif
			If m.toISX.lSortList
				*!* * Removed 8/25/2012 / JRN
				*!* If Version(4) >= "07.00"
				Asort( m.toISX.aList, -1, -1, 0, 1 )
				*!* * Removed 8/25/2012 / JRN
				*!* Else
				*!* 	Dimension laValues[toISX.nCount,2]
				*!* 	For lnValue = 1 to toISX.nCount
				*!* 		laValues[m.lnValue,1] = Upper(toISX.aList[m.lnValue])
				*!* 		laValues[m.lnValue,2] = m.lnValue
				*!* 	EndFor
				*!* 	Asort( laValues, 1 )
				*!* EndIf
			Else
			Endif
			*--------------------------------------------------------------------------------------
			* Fill the listbox with all possible values.
			*--------------------------------------------------------------------------------------
			With .isxList
				.FontName = m.toISX.ISXOptions.FontName
				.FontSize = m.toISX.ISXOptions.FontSize
			Endwith
			.oISXOptions = m.toISX.ISXOptions
			.lSearchSecondColumn = m.toISX.lSearchSecondColumn
			.lDotIsTerminator = m.toISX.lDotIsTerminator
			.lRemoveDot = m.toISX.lRemoveDot
			lnMaxWidth		   = 0
			lnMaxColumn2Width = 0
			lnMaxColumn3Width = 0
			lcVarString		   = ''
			Dimension .aItems[m.toISX.nCount, 6]
			.aItems		   = ''
			lnColumnCount  = Min(5, Alen(m.toISX.aList, 2))
			lnAvgCharWidth = Fontmetric(6, .isxList.FontName, .isxList.FontSize)

			*** JRN 5/6/2014 : remove items that end in "_Def"
			For lnValue = m.toISX.nCount to 1 step -1
				lcValue = Alltrim(m.toISX.aList[m.lnValue, 1])
				If Upper(Right(lcValue, 4)) == Upper(ObjectAnnotation)
					m.toISX.nCount = m.toISX.nCount - 1
					Adel(m.toISX.aList, m.lnValue)
				EndIf 
			Endfor

			For lnValue = 1 To m.toISX.nCount
				*!* * Removed 8/26/2012 / JRN
				*!* If Version(4) >= "07.00"
				lcValue = Alltrim(m.toISX.aList[m.lnValue, 1])
				*!* * Removed 8/26/2012 / JRN
				*!* Else
				*!* 	lcValue = toISX.aList[laValues[m.lnValue,2]]
				*!* EndIf
				If ccTAB $ m.lcValue
					.aItems[m.lnValue, 3] = Getwordnum(m.lcValue, 2, ccTAB)
					lcValue				  = Getwordnum(m.lcValue, 1, ccTAB)
				Endif
				.aItems[m.lnValue, 1] = Upper(m.lcValue)
				.aItems[m.lnValue, 2] = m.lcValue
				lcVarString			  = m.lcVarString + ':' + Padr(Upper(m.lcValue), 128)
				lnWidth				  = Txtwidth(m.lcValue, .isxList.FontName, .isxList.FontSize) * m.lnAvgCharWidth
				lnMaxWidth			  = Max( m.lnMaxWidth, m.lnWidth )
				For lnCol = 2 To m.lnColumnCount
					.aItems[m.lnValue, m.lnCol + 1] = Alltrim(Evl(m.toISX.aList[m.lnValue, m.lnCol], ''))
				Endfor
				If Not Empty(.aItems[m.lnValue, 3])
					lnWidth				  = Txtwidth(.aItems[m.lnValue, 3], .isxList.FontName, .isxList.FontSize) * m.lnAvgCharWidth
					lnMaxColumn2Width	  = Min(cnMaxColumn2Width, Max( m.lnMaxColumn2Width, m.lnWidth ))
				Endif
				If Not Empty(.aItems[m.lnValue, 4])
					lnWidth				  = Txtwidth(.aItems[m.lnValue, 4], .isxList.FontName, .isxList.FontSize) * m.lnAvgCharWidth
					lnMaxColumn3Width	  = Min(cnMaxColumn2Width, Max( m.lnMaxColumn3Width, m.lnWidth ))
				Endif
			Endfor
			Dimension .aItemsSource(Alen(.aItems, 1), Alen(.aItems, 2))
			Acopy(.aItems, .aItemsSource)
			.cVarString = m.lcVarString
			*** JRN 9/11/2011 : Add a little more to width
			lnMaxWidth = m.lnMaxWidth + 30
			If m.toISX.ISXOptions.ShowFieldDefs And m.lnMaxColumn2Width > 0
				lnMaxColumn2Width = m.lnMaxColumn2Width + 40
			Else
				lnMaxColumn2Width = 0
			Endif
			If m.lnMaxColumn3Width > 0
				lnMaxColumn3Width = m.lnMaxColumn3Width + 40
			Else
				lnMaxColumn3Width = 0
			Endif
			*!* * Removed 8/11/2012 / JRN
			*!* Local lnIndex, lnMatchRowCount, lnRow
			*!* lcInput = toISX.cName
			*!* If Len (m.lcInput) > 0
			*!* 	lnMatchRowCount = 0
			*!* 	lcNewVarString = ''
			*!* 	For lnRow = 1 To Alen (This.aItems, 1)
			*!* 		lnIndex = At ( ':' + Upper (m.lcInput), .cVarString, lnRow )
			*!* 		If m.lnIndex # 0
			*!* 			lnMatchRowCount					  = lnMatchRowCount + 1
			*!* 			lnSourceRow 					  = (m.lnIndex/129) + 1
			*!* 			This.aItems[m.lnMatchRowCount, 1] = This.aItems[m.lnSourceRow, 1]
			*!* 			This.aItems[m.lnMatchRowCount, 2] = This.aItems[m.lnSourceRow, 2]
			*!* 			lcNewVarString = m.lcNewVarString + ":" + Padr(This.aItems[m.lnSourceRow, 1],128)
			*!* 		Else
			*!* 			Exit
			*!* 		Endif
			*!* 	EndFor
			*!* 	If m.lnMatchRowCount > 0
			*!* 		Dimension This.aItems[m.lnMatchRowCount, Alen(This.aItems, 2)]
			*!* 		.isxList.Requery()
			*!* 		This.cVarString = lcNewVarString
			*!* 	EndIf
			*!* 	.cSearchString	   = m.lcInput
			*!* Endif
			With .isxList
				.ColumnWidths  = '0,' + Alltrim(Str(m.lnMaxWidth)) + ',' + Alltrim(Str(m.lnMaxColumn2Width)) + ',' + Alltrim(Str(m.lnMaxColumn3Width))
				.ColumnCount   = 4
				.RowSource	   = 'Thisform.aItems'
				.RowSourceType = 5
				.Requery()
				*** JRN 9/11/2011 : Compute height, up to 24 at a time
				lnTotalWidth = m.lnMaxWidth + m.lnMaxColumn2Width + m.lnMaxColumn3Width + Iif(.ListCount > m.toISX.ISXOptions.DisplayCount, Sysmetric(5), 0)
				*** JRN 2022-11-24 : On a short screen, calc max number of lines that will fit in half the screen
				* as the box will have to go either above or below.
				lnLineHeight = (Fontmetric(1, .FontName, .FontSize) + 2)
				lnHeight	 = Min(Max(.ListCount, 5), m.toISX.ISXOptions.DisplayCount, Int((_Screen.Height - 30) / lnLineHeight / 2)) * lnLineHeight + 4
				.Move( 0, 0, m.lnTotalWidth, m.lnHeight )
				*!* ******** JRN Removed 2022-11-24 ********
				*!* If .ListCount < 6
				*!* 	.Height = m.lnHeight
				*!* Endif
			Endwith
			.Width	= m.lnTotalWidth
			* ================================================================================
			.nWidthDifference = m.lnTotalWidth - Evl(m.lnMaxColumn3Width, m.lnMaxColumn2Width)
			* ================================================================================
			
			.Height	= .isxList.Height
			*-----------------------------------------------------------------
			* LDZ: Try to find this variable name in the list of variables we
			* assembled above. If we find it, we select this entry and save
			* what has been entered so far.
			*-----------------------------------------------------------------
			lcInput			   = m.toISX.cName
			.cSearchString	   = m.lcInput
			.isxList.ListIndex = 1
			Do Case
				Case Len(m.lcInput) = 0
				Case This.oISXOptions.Filtering
					This.SetFilter(m.lcInput, This.lSearchSecondColumn)
				Otherwise
					lnIndex = At( ':' + Upper(m.lcInput), .cVarString )
					If m.lnIndex == 0
						.isxList.ListIndex = 0
					Else
						.isxList.ListIndex =(m.lnIndex / 129) + 1
					Endif
			Endcase
			.SetPictures()
			*-----------------------------------------------------------------
			* The original version of the following few code blocks has been
			* kindly provided by Louis D. Zelus. I've modified it to match the
			* rest of the code here. The purpose is to simulate a behavior
			* in VB. If the variable is inserted via ALT+I, everything already
			* typed is used to position the list and if the already entered
			* parts are sufficient to uniquely identify the variablem it's
			* inserted without displaying the popup at all. All blocks based
			* on his code start with LDZ.
			*-----------------------------------------------------------------
			*-----------------------------------------------------------------
			* LDZ: If a variable name has been entered, we highlight it in the
			* edit window.
			*-----------------------------------------------------------------
			If Len(m.lcInput) > 0
				lnEndPos   = This.oIsx.GetFileCursorPos( .nWHandle )
				lnStartPos = m.lnEndPos - Len(m.lcInput)
				_EdSelect( .nWHandle, m.lnStartPos, m.lnEndPos )
			Endif
		Endwith

		*-----------------------------------------------------------------
		* LDZ: If there's no second instance of this start, accept it
		* immediately without displaying the popup. The full variable name
		* is inserted with the proper case at the current position
		* replacing the selection.
		*-----------------------------------------------------------------
		Do Case
			Case Len(m.lcInput) = 0
			Case Not m.toISX.ISXOptions.SelectIfOne
				This.lScrolled = .T.
			Case m.toISX.ISXOptions.Filtering
				If Alen(This.aItems, 1) = 1													;
						And(Not This.isxList.List[this.isxList.ListIndex, 2] == NOMATCHFOUND)		;
						And(Not Lower(This.isxList.List[this.isxList.ListIndex, 2] ) == Lower(m.lcInput))
					Thisform.oIsx.Inserttext( This.nWHandle, '', , 'R' )
					Thisform.oIsx.Inserttext( This.nWHandle, This.isxList.List[this.isxList.ListIndex, 2] )
					Return .F.
				Else
					This.lScrolled = .T.
				Endif
			Case At( ':' + Upper(m.lcInput), This.cVarString, 2 ) == 0		;
					And Not m.lnIndex == 0
				Thisform.oIsx.Inserttext( This.nWHandle, '', , 'R' )
				Thisform.oIsx.Inserttext( This.nWHandle, This.isxList.List[this.isxList.ListIndex, 2] )
				Return .F.
			Otherwise
				This.lScrolled = .T.
		Endcase

		*-----------------------------------------------------------------
		* Determine the cursor position in _SCREEN coordinates
		*-----------------------------------------------------------------
		If Not This.oISX.GetCaretPosition( This.nWHandle, @m.lnTop, @m.lnLeft )
			Return .F.
		Endif

		*-----------------------------------------------------------------
		* As we position the popup BELOW the current line, we need to
		* know the height of this line in pixels.
		*-----------------------------------------------------------------
		Local lcFontName, lnAvgCharWidth, lnFontSize, lnLineHeight
		lcFontName = ''
		lnFontSize = 9
		If Not This.oISX.WGetFontInfo ( This.nWHandle, @m.lcFontName, @m.lnFontSize )
			Return .F.
		Endif
		lnLineHeight   = Fontmetric ( 1, m.lcFontName, m.lnFontSize )
		lnAvgCharWidth = Fontmetric(6, m.lcFontName, m.lnFontSize)
		
		* ================================================================================
		*!* ******** JRN Removed 2022-11-24 ********
		*!* This.Height = Nvl(Execscript(_Screen.cThorDispatcher, 'Get Option=', 'Height', 'ISX Window'), This.Height)
		*!* This.Width = Nvl(Execscript(_Screen.cThorDispatcher, 'Get Option=', 'Width', 'ISX Window'), This.Width)
		This.ResizeListBox()

		* ================================================================================
		
		*-----------------------------------------------------------------
		* We make sure that the popup doesn't move below the VFP window to
		* keep it visible all the time. If it doesn't fit into the area
		* below the cursor, we move it upwards.
		*-----------------------------------------------------------------
		If m.lnTop + This.Height + m.lnLineHeight > _Screen.Height
			lnTop = m.lnTop - This.Height - 14
		Else
			lnTop = m.lnTop + m.lnLineHeight
		Endif
		This.Top = m.lnTop
		*------------------------------------------------------------------
		* As for the height of the VFP window, we do the same for the
		* width. If the popup won't fit into the VFP _Screen, we flip
		* it horizontally.
		*------------------------------------------------------------------
		*!* ******************** Removed 05/05/2020 *****************
		*!* If m.lnLeft + This.Width + m.lnAvgCharWidth > _Screen.Width
		*!* 	lnLeft = m.lnLeft - This.Width
		*!* Else
		*!* 	lnLeft = m.lnLeft + m.lnAvgCharWidth
		*!* Endif
		This.Left = Max(Min(m.lnLeft + m.lnAvgCharWidth, _Screen.Width - This.Width - 14), 0)
	Endproc
	*========================================================================================
	* Filter the listbox
	*========================================================================================
	Procedure SetFilter(tcInput, tlSearchSecondColumn)
		Local lcMatch, lcNewVarString, llLeadingMatch, llMatch, lnCol, lnColCount, lnListIndex
		Local lnMatchRowCount, lnPos, lnRow, lnRowCount, lnStartIndex
		With This
			*!* * Removed 9/22/2012 / JRN
			*!* m.lnStartIndex = .ISXList.ListIndex
			*!* If m.lnStartIndex > 0
			*!* 	m.lcMatch =  .ISXList.List[m.lnStartIndex]
			*!* Endif
			lnRowCount = Alen(.aItemsSource, 1)
			lnColCount = Alen(.aItemsSource, 2)
			Dimension .aItems(m.lnRowCount, m.lnColCount)
			.aItems			  = ''
			.aItems[1, 2]	  = NOMATCHFOUND
			.ISXList.ListIndex = 1
			lnMatchRowCount = 0
			lcNewVarString  = ''
			lnListIndex	  = 0
			For lnRow = 1 To m.lnRowCount
				If Empty(m.tcInput)
					llMatch = .T.
					llLeadingMatch = .T.
				Else
					lnPos = Atc(m.tcInput, Chrtran(This.aItemsSource[m.lnRow, 2], Iif(Thisform.lDotIsTerminator, '.', ''), ''))
					Do Case
						Case m.lnPos = 1
							llMatch		 = .T.
							llLeadingMatch = .T.
						Case m.lnPos > 0 And This.oISXOptions.FilterType = 2
							llMatch = .T.
						Case m.tlSearchSecondColumn
							lnPos = Atc(m.tcInput, Chrtran(Evl(This.aItemsSource[m.lnRow, 3], ''), '.', ''))
							If m.lnPos = 1 Or(m.lnPos > 0 And This.oISXOptions.FilterType = 2)
								llMatch = .T.
							Else
								llMatch = .F.
							Endif
						Otherwise
							llMatch = .F.
					Endcase
				Endif && Empty(m.tcInput)
				If m.llMatch
					lnMatchRowCount					  = m.lnMatchRowCount + 1
					For lnCol = 1 To m.lnColCount
						This.aItems[m.lnMatchRowCount, m.lnCol] = This.aItemsSource[m.lnRow, m.lnCol]
					Endfor
					If m.llLeadingMatch And m.lnListIndex = 0
						lnListIndex = m.lnMatchRowCount
						.ISXList.ListIndex = m.lnListIndex
					Endif
				Endif
				*!* * Removed 8/29/2012 / JRN
				*!* lnPos = Atc(m.tcInput, This.aItemsSource[lnRow, 1])
				*!* If Empty(m.tcInput) Or lnPos = 1 Or (lnPos > 0 And This.oISXOptions.FilterType = 2)
				*!* 	lnMatchRowCount					  = lnMatchRowCount + 1
				*!* 	For lnCol = 1 To lnColCount
				*!* 		This.aItems[m.lnMatchRowCount, lnCol] = This.aItemsSource[m.lnRow, lnCol]
				*!* 	Endfor
				*!* Endif
			Endfor
			lnMatchRowCount = Max(m.lnMatchRowCount, 1)
			Dimension This.aItems[m.lnMatchRowCount, m.lnColCount ]
			.ISXList.Requery()
			.cSearchString	   = m.tcInput
			.SetPictures()
		Endwith
	Endproc

	Procedure SetPictures
		Local lnI
		For lnI = 1 To Alen(This.aItems, 1)
			If Not (Empty(This.ISXList.Picture[m.lnI]) And Empty(This.aItems[m.lnI, 5]))
				This.ISXList.Picture[m.lnI] = Alltrim(Evl(This.aItems[m.lnI, 5], ''))
			Endif
		Endfor
	Endproc

	*========================================================================================
	* If we don't hide the popup before releasing it, the focus might not go back to the
	* edit window. This happens when we have a Data Session window docked on one side and
	* a code editing window maximized. In this case the focus switches to the datasession
	* window and Aliases listbox disappears.
	*========================================================================================
	Procedure Release
		This.Hide()
	EndProc
	
	Procedure isxList.KeyPress
		Lparameter tnKeyCode, tnSAC
		Local lcSearch, lcTextToInsert, lckey, llClearInput, llQualifier, llResendKey, llScrolled
		Local lnCurrentPos, lnIndex, lnPos
		Local tnKeyCode
		
		*-----------------------------------------------------------------
		* A blatant lie! Treat left arrow exactly like backspace!!!
		*-----------------------------------------------------------------
		If m.tnSAC == 0 And m.tnKeyCode == LEFTARROW
			m.tnKeyCode = BACKSPACE
		EndIf
		
		*-----------------------------------------------------------------
		* Another blatant lie! If dot is not a terminator, but user
		* has entered .F. or .T., make it a terminator
		*-----------------------------------------------------------------
		If m.tnSAC == 0 And m.tnKeyCode = Asc('.') && And Not Thisform.lDotIsTerminator
			If InList(Upper('.' + This.Parent.cSearchString + '.'), '.F.', '.T.', '.NULL.')
				lnPos = This.Parent.nCurrentPos + Len(This.Parent.cSearchString)
				_EdSelect(this.Parent.nWHandle,	lnPos, lnPos)
				Keyboard('.')
				Thisform.Release()
				Return
			EndIf 
		Endif
		
		*-----------------------------------------------------------------
		* If FilterToggled key has been pressed
		*-----------------------------------------------------------------
		If This.Parent.oISXOptions.Filtering And m.tnKeyCode = Asc (This.Parent.oISXOptions.FilterToggle)
			This.Parent.oISXOptions.FilterType = Iif (This.Parent.oISXOptions.FilterType = 1, 2, 1)
			This.Parent.SetFilter (This.Parent.cSearchString, This.Parent.lSearchSecondColumn)
			* Main Thor Engine
			Execscript (_Screen.cThorDispatcher, 'Set Option=', 'FilterType', 'IntellisenseX', This.Parent.oISXOptions.FilterType)
			Nodefault
			Return
		Endif
		*-----------------------------------------------------------------
		* If the Up or Down Arrow has been pressed, we do nothing, but
		* remember that the user scrolled in the list, because this acti-
		* vates the enter key.
		*-----------------------------------------------------------------
		*** JRN 9/11/2011 : Added 3 (PgDn) and 18 (PgUp)
		If m.tnSAC == 0 And Inlist( m.tnKeyCode, 5, 24, 3, 18 )
			This.Parent.lScrolled = .T.
			Return
		Endif
		llScrolled			  = This.Parent.lScrolled
		This.Parent.lScrolled = .F.

		With This
			*-----------------------------------------------------------------
			* Determines whether a name qualifier has been entered.
			*-----------------------------------------------------------------
			llQualifier = .F.
			If m.tnSAC == 0 And Between(m.tnKeyCode, Asc('a'), Asc('z'))
				llQualifier = .T.
			Endif
			If m.tnSAC == 1 And Between(m.tnKeyCode, Asc('A'), Asc('Z'))
				llQualifier = .T.
			Endif
			If m.tnSAC == 0 And Between(m.tnKeyCode, Asc('0'), Asc('9'))
				llQualifier = .T.
			Endif
			If m.tnSAC == 1 And m.tnKeyCode == Asc('_')
				llQualifier = .T.
			Endif
			If m.tnSAC == 0 And m.tnKeyCode = Asc('.') And Not Thisform.lDotIsTerminator
				llQualifier = .T.
			Endif
			*-----------------------------------------------------------------
			* If a qualifier has been entered, we insert the character into
			* the current edit window. We also perform an incremental search
			* on the Text being inserted.
			*-----------------------------------------------------------------
			If m.llQualifier
				lcSearch = .Parent.cSearchString + Chr(m.tnKeyCode)
			Endif
			*-----------------------------------------------------------------
			* BACKSPACE deletes the last character.
			*-----------------------------------------------------------------
			If m.tnSAC == 0 And m.tnKeyCode == BACKSPACE
				If Len(.Parent.cSearchString) > 0
					lcSearch	= .Parent.cSearchString
					lcSearch	= Left( m.lcSearch, Len(m.lcSearch) - 1 )
					llQualifier	= .T.
				Endif
			Endif
		Endwith

		*-----------------------------------------------------------------
		* Now that we handled BACKSPACE, we can update the variable name
		* in the edit window.
		*-----------------------------------------------------------------
		If m.llQualifier
			Thisform.oIsx.Inserttext( This.Parent.nWHandle, m.lcSearch, , 'RH' )
			If This.Parent.oISXOptions.Filtering
				This.Parent.SetFilter(m.lcSearch, This.Parent.lSearchSecondColumn)
			Else
				lnIndex = At( ':' + Upper(m.lcSearch), This.Parent.cVarString )
				If m.lnIndex == 0
					This.ListIndex = 0
				Else
					This.ListIndex = (m.lnIndex / 129) + 1
				Endif
			Endif
			This.Parent.cSearchString = m.lcSearch
			Nodefault
			Return
		Endif

		With This
			*-----------------------------------------------------------------
			* The following flags determine how to procede.
			*-----------------------------------------------------------------
			lcTextToInsert = ''
			llResendKey	   = .T.
			llClearInput   = .F.
			Do Case

					*-----------------------------------------------------------------
					* If Ctrl-C has been pressed, paste 2nd visible column into clipboard
					*-----------------------------------------------------------------
			    Case m.tnKeyCode = 3 And m.tnSAC = 2 && Ctrl-C
					With This
						_Cliptext = .List[.ListIndex, 3]
						If _Cliptext = '= '
							_Cliptext = Substr(_Cliptext, 3)
						Endif
					Endwith
					llResendKey	 = .F.
					llClearInput = .T.
						
					*-----------------------------------------------------------------
					* If Ctrl-Z has been pressed, just close the pop-up and leave text as is
					* Note: have not been able to get the cursor to behave consistently after
					*-----------------------------------------------------------------
			    Case m.tnKeyCode = 26 And m.tnSAC = 2 && Ctrl-Z
					ThisForm.Release()

					*-----------------------------------------------------------------
					* If TAB has been pressed, insert the current selection and
					* release the popup
					*-----------------------------------------------------------------
				Case m.tnSAC == 0 And m.tnKeyCode == 9 And .ListIndex > 0
					lcTextToInsert = .List[.ListIndex, 2]
					llResendKey	   = .F.
					llClearInput   = .T.
					*-----------------------------------------------------------------
					* If ENTER has been pressed after the user made a selection with
					* the arrow keys, we insert the current selection and release the
					* popup, because after scrolling the user has the feeling of using
					* a plain listbox where enter performs a selection.
					*-----------------------------------------------------------------
				Case     m.tnSAC == 0				;
						And m.tnKeyCode == 13		;
						And .ListIndex > 0
					lcTextToInsert = .List[.ListIndex, 2]
					llResendKey	   = .F.
					llClearInput   = .T.
					*-----------------------------------------------------------------
					* If Ctrl+ENTER has been pressed after the user made a selection with
					* the arrow keys, we insert the column 6, else 2nd visible column
					*-----------------------------------------------------------------
				Case     m.tnSAC == 2				;
						And m.tnKeyCode == 10		;
						And .ListIndex > 0
						
					lcTextToInsert = Evl(.List[.ListIndex, 6], .List[.ListIndex, 3])
					lcTextToInsert = Strtran(m.lcTextToInsert, Chr(9), ' ')
					lcTextToInsert = Strtran(m.lcTextToInsert, ' ,', ',')
					lcTextToInsert = Strtran(m.lcTextToInsert, ',', ', ')
					Do while '  ' $ m.lcTextToInsert 
						lcTextToInsert = strtran(m.lcTextToInsert, '  ', ' ')
					EndDo 					
					
					llResendKey	   = .F.
					llClearInput   = .T.
					*-----------------------------------------------------------------
					* Several keys insert the current selection plus the typed
					* character and release the popup. These are usually keys that
					* directly follow a variable name.
					*-----------------------------------------------------------------
					*** JRN 7/26/2012 : Created separate list of keystrokes for which
					* a space is to be added after
				Case Between(m.tnKeyCode, 0, 255)												;
						And Chr(m.tnKeyCode) $ POPUP_TERMINATION_CHARS + EXTRA_SPACE_LIST		;
						And .ListIndex > 0
					lcTextToInsert = .List[.ListIndex, 2]
					*** JRN 7/26/2012 : add the extra space
					Do Case
						Case Chr(m.tnKeyCode) = '*'						;
								And Empty(.Parent.cSearchString)		;
								And Not Empty(.List[.ListIndex, 3])
							lcTextToInsert = ''
						Case Chr(m.tnKeyCode) $ EXTRA_SPACE_LIST
							lcTextToInsert = m.lcTextToInsert + ' '
					Endcase
					llClearInput = .T.
					*-----------------------------------------------------------------
					* If ESC has been pressed, the text is unselected.
					*-----------------------------------------------------------------
				Case m.tnSAC == 0 And m.tnKeyCode == 27
					llResendKey	 = .F.
					llClearInput = .T.
					*!* * Removed 12/11/2012 / JRN
					*!* *-----------------------------------------------------------------
					*!* * If LeftArrow Or Ctrl+LeftArrow Or Shift has been pressed And no text after dot, the text is unselected.
					*!* *-----------------------------------------------------------------
					*!* Case ( (m.tnSAC == 0 And m.tnKeyCode == 19 ) Or (m.tnSAC == 1 And m.tnKeyCode == 52) Or (InList(m.tnSAC,2,3) And m.tnKeyCode == 26) )
					*!* 	m.llResendKey  	= .F.
					*!* 	m.llClearInput 	= .T.
					*-----------------------------------------------------------------
					* terminate the popup for any other key and leave the text.
					*-----------------------------------------------------------------
				Otherwise
					If m.tnSAC == 0 And m.tnKeyCode == BACKSPACE
					Else
						lckey = Thisform.oIsx.GetKeyLabel( m.tnKeyCode, m.tnSAC)
						If Len(m.lckey) > 1
							lcTextToInsert = .List[.ListIndex, 2]
							llClearInput   = .T.
						Endif
					Endif
			Endcase
			If m.lcTextToInsert = '.'
				lcTextToInsert = Substr(m.lcTextToInsert, 2)
			Endif
			If Right(m.lcTextToInsert, 1) = '.' And Chr(m.tnKeyCode) = '.'
				lcTextToInsert = Left(m.lcTextToInsert, Len(m.lcTextToInsert) - 1)
			Endif
			*-----------------------------------------------------------------
			* If the currently entered Text should be deleted, insert an empty
			* string using the replace option. Insert text afterwards.
			*-----------------------------------------------------------------
			If m.llClearInput
				Thisform.oIsx.Inserttext( .Parent.nWHandle, '', , 'R' )
			Else
				Thisform.oIsx.SetFileCursorPos(											;
					.Parent.nWHandle,										;
					.Parent.nCurrentPos + Len(.Parent.cSearchString)		;
					)
			Endif
			Do Case
				Case Empty( m.lcTextToInsert )
				Case  m.lcTextToInsert == NOMATCHFOUND
					Thisform.oIsx.Inserttext( .Parent.nWHandle, This.Parent.cSearchString )
				Otherwise
					Local lcExpanded
					If Vartype(Thisform.oISX.oPostProcessor) = 'O'
						*** JRN 11/6/2014 : new code to handle 'DropDown Intellisense Script' -- expansion after selection
						lcExpanded = Thisform.oISX.oPostProcessor.Expand(m.lcTextToInsert)
						If Vartype(m.lcExpanded) = 'C'
							lcTextToInsert = m.lcExpanded + Iif(Left(m.lcExpanded, 1) = ' ', ' ', '')
							If '~' $ m.lcTextToInsert
								Thisform.oIsx.Inserttext( .Parent.nWHandle, Chrtran(m.lcTextToInsert, '~', '') )
								lnCurrentPos = Thisform.oIsx.GetFileCursorPos(.Parent.nWHandle)
								Thisform.oIsx.SetFileCursorPos(				;
									.Parent.nWHandle,			;
									m.lnCurrentPos + At('~', m.lcTextToInsert) - Len(m.lcTextToInsert)		;
									)
								m.llResendKey = .F.
							Else
								Thisform.oIsx.Inserttext( .Parent.nWHandle, m.lcTextToInsert )
							EndIf
						Else
							Thisform.oIsx.Inserttext( .Parent.nWHandle, m.lcTextToInsert )
						EndIf
					Else
						Thisform.oIsx.Inserttext( .Parent.nWHandle, m.lcTextToInsert )
					Endif
			Endcase
			*-----------------------------------------------------------------
			* Remove the dot!
			*-----------------------------------------------------------------
			If Thisform.lRemoveDot
				lnCurrentPos = Thisform.oIsx.GetFileCursorPos(.Parent.nWHandle)
				_EdSelect(.Parent.nWHandle,	.Parent.nCurrentPos - 1, .Parent.nCurrentPos)
				_EdCut(.Parent.nWHandle)
				Thisform.oIsx.SetFileCursorPos(				;
					.Parent.nWHandle,			;
					m.lnCurrentPos - 1			;
					)
			Endif
			*-----------------------------------------------------------------
			* Close the form.
			*-----------------------------------------------------------------
			Nodefault
			Thisform.Release()
			*-----------------------------------------------------------------
			* And repeat the keystroke if necessary
			*-----------------------------------------------------------------
			If m.llResendKey
				lckey = Thisform.oIsx.GetKeyLabel( m.tnKeyCode, m.tnSAC )
				If Not Empty(m.lckey)
					Clear Typeahead
					If Len(m.lckey) == 1
						Keyboard m.lckey
					Else
						Keyboard '{' + m.lckey + '}'
					Endif
				Endif
			Endif
		Endwith
	Endproc

	*====================================================================
	* Double-clicking is the same as TAB.
	*====================================================================
	Procedure isxList.DblClick
		Clear Typeahead
		Keyboard "{Tab}" Plain
	Endproc

Enddefine

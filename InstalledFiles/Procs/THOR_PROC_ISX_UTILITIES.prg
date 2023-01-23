#Include "..\Header Files\Thor_Proc_IntellisenseX.h"

Define class ISX_Utilities as Custom
	nWHandle			= 0
	nEditSource			= 0
	nCount				= 0
	cTextLeft			= ''
	cCharacterRight		= ''
	cName				= ''
	cEntity				= ''
	cInvocation			= ''
	lForceThor			= .F.
	lSortList			= .T.
	lSecondPass			= .F.
	lSearchSecondColumn	= .F.
	ISXOptions			= Null
	lDotIsTerminator	= .T.
	lRemoveDot			= .F.
	lAliased			= .F.
	CodeBlock			= ''
	CursorPosition		= ''
	cLocalAlias 		= ''
	oPostProcessor		= null

	
	Dimension aList[1] 
	Dimension aEnv[25] 
	Dimension aUsedBefore[1]
	
	
	Procedure Init(tcInvocation)
		Local laEnv[25], llResult, lnHandle
		
		If 0 = Aused(This.aUsedBefore)
			This.aUsedBefore[1] = '?'
		Endif
	
		lnHandle = _WOnTop()
	
		Try
			llResult = _EdGetEnv(m.lnHandle, @m.laEnv)
		Catch
			llResult = -1
		Endtry
	
		If m.llResult > 0
			Acopy(m.laEnv, This.aEnv)
	
			If This.ed_IsCodeWindow()
				This.nWHandle		=  This.GetCurrentWindow()
				This.CodeBlock		= _EdGetStr(This.nWHandle, 0, m.laEnv[2])
				This.nEditSource	= m.laEnv[25]
				This.ISXOptions		= This.GetISXOptions()

				This.CursorPosition	= m.laEnv[17]
				This.cCharacterRight = _EdGetStr(This.nWHandle, This.CursorPosition, This.CursorPosition)

				*====================================================================
				* If we are in the middle of a name and not invoked with a dot,
				* move to the end of the name
				*====================================================================
				Do While This.IsNameCharacter(This.cCharacterRight) and Empty(m.tcInvocation)
					This.CursorPosition	= This.CursorPosition + 1
					This.SetFileCursorPos(This.nWHandle, This.CursorPosition)			
					This.cCharacterRight = _EdGetStr(This.nWHandle, This.CursorPosition, This.CursorPosition)
				EndDo 

				This.cTextLeft		= This.GetLineLeftFromCursor(This.nWHandle)
			EndIf 
		Else
			This.aEnv = -1
		EndIf
	Endproc
		

	*======================================================
 	Function Destroy
 		This.oPostProcessor		= null
		This.CloseTables()
	EndFunc 


	*======================================================
 	Function CloseTables
 		If (Not IsNull(This.ISXOptions)) and Nvl(This.ISXOptions.LeaveTablesOpen, .F.) = .F.
 			lnUsed = Aused(laUsedAfter)
 			For lnI = 1 To m.lnUsed
 				If 0 = Ascan(This.aUsedBefore, m.laUsedAfter[m.lnI, 1], 1, -1, 1, 15)
 					Use In (m.laUsedAfter[m.lnI, 2])
 				Endif
 			Endfor
 		Endif
 	Endfunc
 	 	

	*======================================================
 	Function ed_IsCodeWindow
		Return This.ed_GetWindowType() >= 0 
	EndFunc 


	*======================================================
	Function ed_GetWindowType
		Return This.aEnv[25]
	EndFunc 


	*====================================================================
	* The FoxTools function _AGetEnv() doesn't return proper font infor-
	* mation. Instead it claims that "MS Sans Serif", 8 pt. is the 
	* current font. This function returns font information for the speci-
	* fied window by accessing the GDI.
	*====================================================================
	Procedure WGetFontInfo
		Lparameter tnWHandle, rcFontName, rnFontSize, rnStyle

		*-----------------------------------------------------------------
		* In addition to the window handle of this window we also need
		* the HWND of the child window that contains the actual editor.
		* The GetClientWindow() function retrieves this window handle.
		*-----------------------------------------------------------------
		Local lcLogFont, lcName, lnHDC, lnHFONT, lnHWND, lnResolution, lnSize, lnStyle
		Local rcFontName, rnFontSize, rnStyle
		lnHWND = This.GetClientWindow( m.tnWHandle )
		If m.lnHWND == 0
			Return .F.
		Endif

		*-----------------------------------------------------------------
		* Using this HWND we can then get a Device Context. 
		*-----------------------------------------------------------------
		Declare Long GetDC In Win32API Long
		lnHDC = GetDC( m.lnHWND )
		If m.lnHDC == 0
			Return .F.
		Endif

		*-----------------------------------------------------------------
		* With this device context we can now get an object handle to the
		* currently selected font.
		*-----------------------------------------------------------------
		Declare Long GetCurrentObject In Win32API Long, Long
		lnHFONT = GetCurrentObject( m.lnHDC, 6 )  && OBJ_FONT
		If m.lnHFONT == 0
			Return .F.
		Endif

		*-----------------------------------------------------------------
		* The HFONT handle to the current font can be used to obtain more
		* detailled information about the selected font. We need to rename
		* the API function GetObject(), because it interferes with VFP's
		* GETOBJECT() function
		*-----------------------------------------------------------------
		Declare Integer GetObject in Win32API as GDI_GetObject ;
			LONG, Integer, String@
		lcLogFont = Replicate( Chr(0), 1024 )
		If GDI_GetObject( m.lnHFONT, 1024, @m.lcLogFont ) == 0
			Return .F.
		Endif

		*-----------------------------------------------------------------
		* Now to extract the font information from the LOGFONT structure.
		*-----------------------------------------------------------------
		lnSize	= Abs( This.FromInt(Left(m.lcLogFont, 4)) - 2^32 )
		lcName	= Substr( m.lcLogFont, 29 )
		lcName	= Left( m.lcName, At(Chr(0), m.lcName) - 1 )
		lnStyle	= 0
		If This.FromInt(Substr(m.lcLogFont, 17, 4)) == 700
			lnStyle = m.lnStyle + 1
		Endif
		If This.FromInt(Substr(m.lcLogFont, 21, 4)) # 0
			lnStyle = m.lnStyle + 2
		Endif

		*-----------------------------------------------------------------
		* We now have the height of the font in pixels but what we need 
		* are points.
		*-----------------------------------------------------------------
		Declare Integer GetDeviceCaps In Win32API Integer, Integer
		lnResolution = GetDeviceCaps( m.lnHDC, 90 ) && LOGPIXELSY
		lnSize		 = m.lnSize / m.lnResolution * 72
		lnSize		 = Round( m.lnSize, 0 )

		*-----------------------------------------------------------------
		* Finally release the device context
		*-----------------------------------------------------------------
		Declare Integer ReleaseDC In Win32API Long, Long
		ReleaseDC( m.lnHWND, m.lnHDC )

		*-----------------------------------------------------------------
		* And pass the values pack as parameters
		*-----------------------------------------------------------------
		m.rcFontName = m.lcName
		m.rnFontSize = m.lnSize
		m.rnStyle	 = m.lnStyle

		Return .T.
	Endproc


	*====================================================================
	* Determines the source of the window identified by the passed 
	* WHandle. It returns the following values:
	*
	* -1     The window is not an edit window
	*  0     Command Window
	*  1     MODIFY COMMAND window
	*  2     MODIFY FILE window
	*  8     Menu Designer code window
	* 10     Method Edit Window in Class or Form Designer
	* 12     MODIFY PROCEDURE window
	*
	* This procedure uses _EdGetEnv() from the FoxTools.Fll to determine
	* the edit source. Passing an invalid handle causes an exception in
	* VFP 5 and VFP 3. In VFP 6 this raises an error 2028 (API function
	* caused an exception). Therefore we return -1 in this case, too.
	*====================================================================
	Procedure GetEditSource
		Lparameter tnWHandle

		Local laEnv[25], lcError, lnOK, lnSource
		lcError = On( 'Error' )
		On Error m.lnOK = 0
		lnOK = _EdGetEnv( m.tnWHandle, @m.laEnv )
		On Error &lcError
		If m.lnOK == 0
			lnSource = -1
		Else
			lnSource = m.laEnv[25]
		Endif

		Return m.lnSource
	Endproc


	*====================================================================
	* Returns the WHandle of the current edit window or 0, if no edit
	* window is available.
	*====================================================================
	Procedure GetCurrentWindow

		Local lnWindowOnTop
		lnWindowOnTop = _WOnTop()
		If m.lnWindowOnTop <= 0
			Return 0
		Endif
		If This.GetEditSource( m.lnWindowOnTop ) == -1
			lnWindowOnTop = 0
		Endif

		Return m.lnWindowOnTop
	Endproc


	*====================================================================
	* Returns the current cursor position in the edit window identified
	* by the WHandle. On error -1 is returned.
	*====================================================================
	Procedure GetFileCursorPos
		Lparameters tnWHandle

		Local lnCursorPos
		lnCursorPos = _EdGetPos( m.tnWHandle )

		Return m.lnCursorPos
	Endproc


	*====================================================================
	* Changes the current cursor position in the edit window identified
	* by the WHandle.
	*====================================================================
	Procedure SetFileCursorPos
		Lparameter tnWHandle, tnPosition

		_EdSetPos( m.tnWHandle, m.tnPosition )

	Endproc


	*====================================================================
	* Returns the current line of the edit window identified by the
	* WHandle. The line number is zero based. On Error -1 is returned.
	*====================================================================
	Procedure GetCurrentLine
		Lparameters tnWHandle

		Local lnCursorPos, lnLineNo
		lnCursorPos = This.GetFileCursorPos( m.tnWHandle )
		If m.lnCursorPos < 0
			lnLineNo = -1
		Else
			lnLineNo = _EdGetLNum( m.tnWHandle, m.lnCursorPos )
		Endif

		Return m.lnLineNo
	Endproc


	*====================================================================
	* Returns the cursor position within the current line of the edit
	* window identified by the WHandle. The cursor position is 0 based.
	* On error -1 is returned.
	*====================================================================
	Procedure GetCurrentCol
		Lparameters tnWHandle

		Local lnColumn, lnCursorPos, lnLineNo, lnLineStart
		lnCursorPos = This.GetFileCursorPos( m.tnWHandle )
		If m.lnCursorPos < 0
			Return - 1
		Endif
		lnLineNo = This.GetCurrentLine( m.tnWHandle )
		If m.lnLineNo < 0
			Return - 1
		Endif
		lnLineStart	= This.GetLineStart( m.tnWHandle, m.lnLineNo )
		lnColumn	= m.lnCursorPos - m.lnLineStart

		Return m.lnColumn
	Endproc


	*====================================================================
	* Returns the beginning of the specific line in the edit window
	* identified by WHandle. Returns -1 on error.
	*====================================================================
	Procedure GetLineStart
		Lparameter tnWHandle, tnLineNo

		Local lnLineStart
		lnLineStart = _EdGetLPos( m.tnWHandle, m.tnLineNo )

		Return m.lnLineStart
	Endproc


	*====================================================================
	* Returns the text of the specified line in the edit window 
	* identified by the WHandle. A terminating carriage return is 
	* removed. Returns an empty string on error. The line must be zero
	* based.
	*====================================================================
	Procedure GetLine
		Lparameters tnWHandle, tnLine

		Local lcString, lnEndPos, lnStartPos
		lnStartPos = This.GetLineStart( m.tnWHandle, m.tnLine )
		lnEndPos   = This.GetLineStart( m.tnWHandle, m.tnLine + 1 )
		If m.lnStartPos == m.lnEndPos
			lcString = ''
		Else
			lnEndPos = m.lnEndPos - 1
			lcString = _EdGetStr( m.tnWHandle, m.lnStartPos, m.lnEndPos )
			lcString = Chrtran( m.lcString, Chr(13), '' )
		Endif

		Return m.lcString
	Endproc


	*====================================================================
	* Returns the text in the current line that is to the left of the 
	* cursor in the edit window identified by the WHandle. Returns "" on
	* error.
	*====================================================================
	Procedure GetLineLeftFromCursor
		Lparameters tnWHandle

		Local lcLine, lnCurCol, lnCurLine
		lnCurLine = This.GetCurrentLine( m.tnWHandle )
		If m.lnCurLine < 0
			Return ''
		Endif
		lnCurCol = This.GetCurrentCol( m.tnWHandle )
		If m.lnCurCol < 0
			Return ''
		Endif
		If m.lnCurCol == 0
			lcLine = ''
		Else
			lcLine = This.GetLine( m.tnWHandle, m.lnCurLine )
			lcLine = Left( m.lcLine, m.lnCurCol )
		Endif

		Return m.lcLine
	Endproc


	*====================================================================
	* Inserts text in the edit window identified by WHandle. The text is
	* stored in tcText, the position is optional. tcOptions can contains
	* a combination of the following values:
	*
	*  R   The current selection is replaced
	*  B   The cursor is positioned at the beginning of the inserted
	*      text.
	*  E   (default) The cursor is positioned at the end of the inserted 
	*      text.
	*  H   The inserted text is highlighted.
	*====================================================================
	Procedure InsertText
		Lparameters tnWHandle, tcText, tnPosition, tcOptions

		*-----------------------------------------------------------------
		* Normalize options
		*-----------------------------------------------------------------
		Local lcOptions, lnEndPosition, lnStartPosition
		If Vartype(m.tcOptions) == 'C'
			lcOptions = Upper( Alltrim(m.tcOptions) )
		Else
			lcOptions = ''
		Endif

		*-----------------------------------------------------------------
		* If a position is passed, Change the current cursor position
		* accordingly.
		*-----------------------------------------------------------------
		If Vartype(m.tnPosition) == 'N'
			This.SetFileCursorPos( m.tnWHandle, m.tnPosition )
		Endif

		*-----------------------------------------------------------------
		* Insert the Text at the current position. If the "R" option is
		* used, delete the current selection.
		*-----------------------------------------------------------------
		If 'R' $ m.lcOptions
			_EdDelete( m.tnWHandle )
		Endif
		lnStartPosition = This.GetFileCursorPos( m.tnWHandle )
		_EdInsert( m.tnWHandle, m.tcText, Len(m.tcText) )
		lnEndPosition = This.GetFileCursorPos( m.tnWHandle )

		*-----------------------------------------------------------------
		* Set the cursor accordingly. "E" is the default of VFP. We don't
		* need any action for that.
		*-----------------------------------------------------------------
		Do Case
			Case 'B' $ m.lcOptions
				This.SetFileCursorPos( m.tnWHandle, m.lnStartPosition )
			Case 'H' $ m.lcOptions
				_EdSelect( m.tnWHandle, m.lnStartPosition, m.lnEndPosition )
		Endcase

	Endproc


	*====================================================================
	* The editor only works on the editor window and you can only get the
	* HWND of this window using the Window Handle. For many Windows ope-
	* rations, however, you need the HWND of the child window that con-
	* tains the actual editor area. This function returns the HWND of 
	* this window. It's not that easy, because Method snippet windows
	* actually have two child windows, one for the text editor and one
	* with the method and object dropdown combos.
	*====================================================================
	Procedure GetClientWindow
		Lparameter tnWHandle

		*-----------------------------------------------------------------
		* Convert the Window Handle into a HWND
		*-----------------------------------------------------------------
		Local lnChild, lnHWND
		lnHWND = _WhToHWND( m.tnWHandle )

		*-----------------------------------------------------------------
		* FindWindowEx returns all child windows of a given parent window.
		* We use it to find a child of the edit window that doesn't have
		* another child window, because method edit windows have a second 
		* which we can identify since it has another child window.
		*-----------------------------------------------------------------
		Declare Integer FindWindowEx In Win32API		;
			Integer, Integer, String, String
		lnChild = 0
		Do While .T.
			lnChild = FindWindowEx( m.lnHWND, m.lnChild, Null, Null )
			If m.lnChild == 0
				Exit
			Endif
			If FindWindowEx( m.lnChild, 0, Null, Null ) == 0
				Exit
			Endif
		Enddo

		Return m.lnChild
	EndProc


		*====================================================================
		* Returns the position of the text cursor (caret) in _SCREEN coordi-
		* nates. If the window identified by the passed window handle doesn't
		* have the focus, or the position can't be determined, this function
		* returns .F.
		*====================================================================
	Procedure GetCaretPosition
		Lparameter tnWHandle, rnTop, rnLeft

		*-----------------------------------------------------------------
		* Check whether this window has got the focus.
		*-----------------------------------------------------------------
		Local lcPOINT, lcRect, lnChild, lnChildLeft, lnChildTop, lnLeft, lnScreen, lnScreenLeft, lnScreenTop
		Local lnTop
		Local rnLeft, rnTop
		Declare Integer GetFocus In Win32API
		If GetFocus() # _WhToHWND( m.tnWHandle )
			Return .F.
		Endif

		*-----------------------------------------------------------------
		* Determine the cursor position. This position is relative to the
		** OK
		* client area of the editing subwindow of the actual editing win-
		* dow.
		*-----------------------------------------------------------------
		Declare Integer GetCaretPos In Win32API String@
		lcPOINT = Space(8)
		If GetCaretPos( @m.lcPOINT ) == 0
			lnLeft = Mcol(3)
			lnTop  = Mrow(3)
		Else
			lnLeft = Asc(Left(m.lcPOINT, 1)) + 256 * Asc(Substr(m.lcPOINT, 2, 1))
			lnTop  = Asc(Substr(m.lcPOINT, 5, 1)) + 256 * Asc(Substr(m.lcPOINT, 6, 1))
		Endif

		*-----------------------------------------------------------------
		* To convert this postion to _SCREEN coordinates, we have to 
		* determine the position of the client window relative to the 
		* desktop window and correlate this with the absolute position of
		* the _SCREEN window. Hence, we need first the HWNDs of both 
		* windows.
		*-----------------------------------------------------------------
		Declare Integer GetParent In Win32API Integer
		lnChild = This.GetClientWindow( m.tnWHandle )
		If m.lnChild == 0
			Return .F.
		Endif
		lnScreen = GetParent( _WhToHWND(m.tnWHandle) )
		If m.lnScreen == 0
			Return .F.
		Endif

		*-----------------------------------------------------------------
		* Now we can determine the position of both windows.
		*-----------------------------------------------------------------
		lcRect = Replicate( Chr(0), 16 )
		Declare Integer GetWindowRect In Win32API Long, String@
		GetWindowRect( m.lnChild, @m.lcRect )
		lnChildLeft	= This.FromInt( Left(m.lcRect, 4) )
		lnChildTop	= This.FromInt( Substr(m.lcRect, 5, 4) )
		GetWindowRect( m.lnScreen, @m.lcRect )
		lnScreenLeft = This.FromInt( Left(m.lcRect, 4) )
		lnScreenTop	 = This.FromInt( Substr(m.lcRect, 5, 4) )

		*-----------------------------------------------------------------
		* Now combine the position of the edit window and the cursor
		* position.
		*-----------------------------------------------------------------
		m.rnLeft = m.lnLeft + m.lnChildLeft - m.lnScreenLeft
		m.rnTop	 = m.lnTop + m.lnChildTop - m.lnScreenTop

	Endproc


	*====================================================================
	* Fills an array with all lines between nStart and nEnd. 
	*====================================================================
	Procedure AGetLines
		Lparameter tnWHandle, raText, tnStart, tnEnd

		*-----------------------------------------------------------------
		* Copy the text between nStart and nEnd into a string variable.
		*-----------------------------------------------------------------
		Local lcString, lnCount, lnEndPos, lnStartPos
		lnStartPos = This.GetLineStart( m.tnWHandle, m.tnStart )
		lnEndPos   = This.GetLineStart( m.tnWHandle, m.tnEnd + 1 ) - 1
		If m.lnEndPos >= m.lnStartPos
			lcString = _EdGetStr( m.tnWHandle, m.lnStartPos, m.lnEndPos )
		Else
			lcString = ''
		Endif

		*-----------------------------------------------------------------
		* And parse this into an array
		*-----------------------------------------------------------------
		lnCount = Alines( raText, m.lcString )

		Return m.lnCount
	Endproc
	 
	*========================================================================================
	Procedure StripQuotes(lcTEXT)
		If Left(m.lcTEXT, 1 ) $ ['"] + '['
			Return Chrtran(m.lcTEXT, ['"] + '[]', '')
		Else
			Return .F.
		Endif
	Endproc


	*========================================================================================
	* Get object with Thor Options
	Procedure GetISXOptions
		Return Execscript (_Screen.cThorDispatcher, 'Thor_Proc_GetISXOptions')
	Endproc


	*========================================================================================
	Procedure FromInt
		Parameter tcString
		Private m.nValue, m.nT
		Local nT, nValue
		m.nValue = 0
		For m.nT = 1 To Len(m.tcString)
			m.nValue = m.nValue + Asc(Substr(m.tcString, m.nT, 1)) * 256^(m.nT - 1)
		Endfor
		Return m.nValue
	Endproc

	*====================================================================
	* GetKeyLabel takes the parameters passed to the KeyPress event and
	* returns the label name that can be used for KEYBOARD or ON KEY
	* LABEL, etc.
	*====================================================================
	Procedure GetKeyLabel
		Lparameter tnKeyCode, tnSAC

		Local lcLabel
		Do Case

				* ================================================================================ 
				*** JRN 11/17/2012 : Function keys added 
			Case m.tnSAC == 0 And m.tnKeyCode < 0
				lcLabel = 'F' + Transform(1 - m.tnKeyCode)
			Case m.tnKeyCode = 133 And m.tnSAC = 0
				lcLabel = 'F11'
			Case m.tnKeyCode = 134 And m.tnSAC = 0
				lcLabel = 'F12'

			Case Between(m.tnKeyCode, 84, 93) And m.tnSAC = 1
				lcLabel = 'Shift+F' + Transform(m.tnKeyCode - 83)
			Case m.tnKeyCode = 135 And m.tnSAC = 1
				lcLabel = 'Shift+F11'
			Case m.tnKeyCode = 136 And m.tnSAC = 1
				lcLabel = 'Shift+F12'

			Case Between(m.tnKeyCode, 94, 103) And m.tnSAC = 2
				lcLabel = 'Ctrl+F' + Transform(m.tnKeyCode - 93)
			Case m.tnKeyCode = 137 And m.tnSAC = 2
				lcLabel = 'Ctrl+F11'
			Case m.tnKeyCode = 138 And m.tnSAC = 2
				lcLabel = 'Ctrl+F12'

			Case Between(m.tnKeyCode, 104, 113) And m.tnSAC = 4
				lcLabel = 'Alt+F' + Transform(m.tnKeyCode - 103)
			Case m.tnKeyCode = 139 And m.tnSAC = 4
				lcLabel = 'Alt+F11'
			Case m.tnKeyCode = 140 And m.tnSAC = 4
				lcLabel = 'Alt+F12'

				* -------------------------------------------------------------------------------- 
			Case Between(m.tnKeyCode, 33, 126)
				lcLabel = Chr(m.tnKeyCode)
			Case Between(m.tnKeyCode, 128, 255)
				lcLabel = Chr(m.tnKeyCode)
			Case m.tnSAC == 2 And Between(m.tnKeyCode, 1, 26)
				Do Case
					Case m.tnKeyCode == 2
						lcLabel = 'CTRL+RIGHTARROW'
					Case m.tnKeyCode == 8
						lcLabel = ''
					Case m.tnKeyCode == 10
						lcLabel = 'CTRL+ENTER'
					Case m.tnKeyCode == 23
						lcLabel = 'CTRL+END'
					Case m.tnKeyCode == 26
						lcLabel = 'CTRL+LEFTARROW'
					Otherwise
						lcLabel = 'CTRL+' + Chr(m.tnKeyCode + 64)
				Endcase
			Case m.tnSAC == 0 And m.tnKeyCode == 22
				lcLabel = 'INS'
			Case m.tnSAC == 1 And m.tnKeyCode == 22
				lcLabel = 'SHIFT+INS'
			Case m.tnSAC == 0 And m.tnKeyCode == 1
				lcLabel = 'HOME'
			Case m.tnSAC == 0 And m.tnKeyCode == 7
				lcLabel = 'DEL'
			Case m.tnSAC == 0 And m.tnKeyCode == 28
				lcLabel = 'F1'
			Case m.tnSAC == 0 And m.tnKeyCode == 6
				lcLabel = 'END'
			Case m.tnSAC == 0 And m.tnKeyCode == 18
				lcLabel = 'PGUP'
			Case m.tnSAC == 0 And m.tnKeyCode == 3
				lcLabel = 'PGDN'
			Case m.tnSAC == 0 And m.tnKeyCode == 5
				lcLabel = 'UPARROW'
			Case m.tnSAC == 0 And m.tnKeyCode == 28
				lcLabel = 'F1'
			Case m.tnSAC == 0 And m.tnKeyCode == 24
				lcLabel = 'DNARROW'
			Case m.tnSAC == 0 And m.tnKeyCode == 4
				lcLabel = 'RIGHTARROW'
			Case m.tnSAC == 0 And m.tnKeyCode == LEFTARROW
				lcLabel = 'LEFTARROW'
			Case m.tnSAC == 0 And m.tnKeyCode == 27
				lcLabel = 'ESC'
			Case m.tnSAC == 0 And m.tnKeyCode == 13
				lcLabel = 'ENTER'
			Case m.tnSAC == 0 And m.tnKeyCode == BACKSPACE
				lcLabel = 'BACKSPACE'
			Case m.tnSAC == 0 And m.tnKeyCode == 9
				lcLabel = 'TAB'
			Case m.tnSAC == 0 And m.tnKeyCode == 32
				lcLabel = 'SPACEBAR'
			Case m.tnSAC == 1 And m.tnKeyCode == 13
				lcLabel = 'SHIFT+ENTER'
			Case m.tnSAC == 1 And m.tnKeyCode == BACKSPACE
				lcLabel = 'SHIFT+BACKSPACE'
			Case m.tnSAC == 1 And m.tnKeyCode == 15
				lcLabel = 'SHIFT+TAB'
			Case m.tnSAC == 1 And m.tnKeyCode == 32
				lcLabel = 'SHIFT+SPACEBAR'
			Case m.tnSAC == 2 And m.tnKeyCode == 29
				lcLabel = 'CTRL+HOME'
			Case m.tnSAC == 2 And m.tnKeyCode == 31
				lcLabel = 'CTRL+PGUP'
			Case m.tnSAC == 2 And m.tnKeyCode == 30
				lcLabel = 'CTRL+PGDN'
			Case m.tnSAC == 2 And m.tnKeyCode == 128
				lcLabel = 'CTRL+BACKSPACE'
			Case m.tnSAC == 2 And m.tnKeyCode == 32
				lcLabel = 'CTRL+SPACEBAR'
			Otherwise
				lcLabel = ''
		Endcase

		Return m.lcLabel
	Endproc


	*========================================================================================
	* Returns .T., when the first string is a FoxPro command.
	*========================================================================================
	 
	 Procedure IsFoxProCommand
		Lparameter tcCommand, tcCommandList

		Local laList[1], llFound, lnLine

		llFound = .F.
		For lnLine = 1 To Alines(laList, Chrtran(m.tcCommandList, ',', Chr(13) + Chr(10)))
			If Left(Upper(m.laList[m.lnLine]), Len(m.tcCommand)) == Upper(m.tcCommand)
				llFound = .T.
				Exit
			Endif
		Endfor

		Return m.llFound
	Endproc


	*====================================================================
	* Normalizes a line. This means: All tabs are converted to single
	* blanks, leading or trailing blanks are removed. Comments starting
	* with && are removed.
	*====================================================================
	 Procedure NormalizeLine
		Lparameters tcLine

		Local lcLine, lnPos
		lcLine = Chrtran( m.tcLine, Chr(9), ' ' )
		If '&' + '&' $ m.lcLine
			lnPos  = At( '&' + '&', m.lcLine )
			lcLine = Left( m.lcLine, m.lnPos - 1 )
		Endif
		lcLine = Alltrim(m.lcLine)

		Return m.lcLine
	EndProc
	
	*========================================================================================
	* Returns .T. when the character can be part of a name
	*========================================================================================
	Procedure IsNameCharacter(lcCharacterRight)
		Return IsAlpha(m.lcCharacterRight) or IsDigit(m.lcCharacterRight) or m.lcCharacterRight = '_'
	EndProc

EndDefine 
*	#Include "..\Header Files\Thor_Proc_IntellisenseX.h"
#Include "Thor_Proc_IntellisenseX.h"

*========================================================================================
*
* Version: 20PRGCode0-02Feb-20
*
*========================================================================================
*
* This program implements partial IntelliSense in VFP 6-9. To enable 
* IntelliSenseX, simply execute this program at any time when using
* Visual FoxPro or put it into your startup program.
*
* To configure ISX please see the section just below the comment block.
*
* To stop IntelliSenseX run this program again and pass "QUIT" as a
* parameter. Alternatively, you can simply remove the ON KEY LABEL
* macros for the ALT+I and the "." key.
*
* Currently only IntelliSense for variable names is implemented. This
* means that whenever you enter "m." in a MODIFY COMMAND window or
* in a Method edit window, you get a list of all variables declared
* in the current procedure. ISX doesn't parse the entire sourcecode 
* for memory variables, but only the current procedure or method and
* only those variables listed in a LOCAL, PRIVATE, PUBLIC, LPARAMETER
* and PARAMETER statement.  ALT+I can be used to trigger this list.
*
* ALT+RIGHTARROW triggers a universal autocomplete function that tries to determine the
* type of what you have entered and offers a list of all possible values.
*
* Please note that I haven't written this program as an excercise for
* good coding styles <g>, rather as an excercise to see if 
* IntelliSense is possible within Visual FoxPro itself. Therefore
* you won't find the Assertions you would otherwise find in my code.
*
*========================================================================================
*
* Acknowledgements
*
* Thanks to George Tasker for his really helpful documentation on the
* FoxTools.Fll. You can download his ToolHelp.Hlp file from the
* UniversalThread and the CompuServe MSDEVAPP forum. George also made
* some suggestions to improve this program.
*
* Also thanks to Ken Levy, who couldn't implement an inline Intelli-
* Sense feature in his SuperCls and thereby convinced me that there 
* must be a way to do it, even only for the purpose of doing 
* something that Ken Levy couldn't do. <bg>
*
* Thanks to all the folks that posted me bug reports, especially
* Frank Cazabon. Thanks to Gerry Hughes for correcting the typos in 
* my comments.
*
* Louis D. Zelus added a nifty feature to my version to make ISX 
* even more useful. Thanks for that! The code based on his work is
* marked with "LDZ:".
*
* Sietse Wijnkler added a lot of new cool features: He added the
* ability to distinguish different types that all are triggered by
* a period and the code to display variables, object properties and
* field names. Code based on his work is marked with "SW:".
*
* Jürgen "wOOdy" Wondzinski pointed out that special characters like
* "ö" are valid variable names and IsAlpha() returns .T. for them.
* Therefore any of these characters is detected by ISX, as well.
*
* Tamar E. Granor and Peter Steinke, both requested the list DEFINE 
* features which is why I finally added it.
*
* Thanks to Eddy Maue for his contributions:
*
*   Ce qu'ile fait de plus maintenant
*    -  Alt-Q pour arrêter Isx
*    -  Alt-Q pour redemarrer Isx
*    - Ouvre automatiquements :
*            -Les tables présentes dans les répertoires courants et de recherches
*             (set path to)
*            -Les vues présentes dans le projet actif
*            -Les query présents dans les répertoires courants et de recherches
*             (set path to)
*              Petit point à ne pas négliger. Le curseur produit par le fichier 
*              MyQuery.qpr doit être du même nom que le fichier
*
* In English:
* 
*    - ALT+Q enables/disables ISX
*    - files are opened automatically:
*        - tables available in the current directory or the search path (SET PATH TO)
*        - Views available in the current project
*        - Queries available in the current directory or the search path (SET PATH TO)
*          Minor, but important restriction: The cursor created by the query program
*          must have the same alias as the filename.

* Mike Yearwood added supported for maximized editing windows which caused a lot
* of flickering everytime the popup came up.
* 
* Thanks to all those who pointed out bugs in ISX's releases: 
* 
*  - Nina Schwanzer
*  - Del Lee
*  - Pamela Thalacker
*  - Christophe Chenavier
*  - Aragorn Rockstroh
*  - Claude Hebert 
*  - Jens Kippnich
*  - Stefan Wübbe
*
*========================================================================================
*
* This program has been written in 1999-2005 by Christof Wollenhaupt
* and is placed into Public Domain. You can use the entire
* code or parts of it as you like in any private or commercial
* application. None of the contributors to this programm can be hold 
* liable for any damage or problems, using this program may cause.
*
* If you added a new feature, please let me know. If you want I add
* your feature to my master copy of ISX to let others use your 
* feature, as well. Please note that since the entire program is 
* placed into Public Domain, this places your code into Public 
* Domain, as well. Of course, your contributions are acknlowdeged in
* the comment at the beginning of this file.
*
*========================================================================================
*
* Known problems:
*
* - So far ISX has not been tested with different Display appearance
*   settings, like wider scrollbars or form borders, large fonts and
*   the like. Some values are hardcoded and might be wrong for non-
*   standard Windows settings.
*
* - When you enter a period into a textbox, the cursor is set to the first character of
*   the textbox and then the period entered. If SelectOnEntry is true, everything is
*   replaced by the period. This is caused by a bug in VFP that makes all ON KEY LABEL
*   behave this way. You can disable this behavior by commenting out the lines starting 
*   with "ON KEY LABEL .". In this case, you must use ALT+I or ALT+RIGHTARROW do expand
*   the variable.
*
*========================================================================================


*========================================================================================
* Configuration. 
*
* Over the time I got many enhanced versions of ISX, many of which include new hotkeys.
* To give everyone control over the hotkey assignment and to disable/enable particular
* features, I added the following configuration section. By commenting out a #DEFINE, you
* disable a particular feature. Changing the value changes the hotkey.
*
*========================================================================================


*========================================================================================
* Main program
*========================================================================================
Lparameters tcProviders, tcInvocation, tlForceThor, TOList, tlSearchSecondColumn, toPostProcessor, tlReturnResult, tcEntity

Local loISX, loResult

Push Key Clear

*========================================================================================

LoadFoxTools()

loISX = Execscript(_Screen.cThorDispatcher, 'class= ISX_Utilities from Thor_Proc_ISX_Utilities', m.tcInvocation)

loISX.oPostProcessor = m.toPostProcessor

If m.loISX.ed_IsCodeWindow() Then
	Execscript (_Screen.cThorDispatcher, 'PEMEditor_StartIDETools')
	loResult = Autocomplete(m.tcProviders, m.tcInvocation, m.tlForceThor, m.TOList, m.tlSearchSecondColumn, m.loISX, tlReturnResult, tcEntity)
Else
	Keyboard m.tcInvocation Plain Clear
Endif

*========================================================================================

Pop Key

Return ExecScript(_Screen.cThorDispatcher, 'Result=', loResult)



*========================================================================================
* Provides a generic autocomplete function. AutoComplete checks all content providers 
* if they have something to add to the global list and displays the list as a popup
*========================================================================================
Procedure Autocomplete
	Lparameters tcProviders, tcInvocation, tlForceThor, toList, tlSearchSecondColumn, toISX, tlReturnResult, tcEntity

	Local laEnv[25], lnEditSource, lnWHandle

	*-----------------------------------------------------------------
	* Get the current window and verify that it is a valid window.
	*-----------------------------------------------------------------
	lnWHandle = m.toISX.GetCurrentWindow()
	If m.lnWHandle == 0
		NotEditWindow(m.tcInvocation)
		Return
	Endif

	*-----------------------------------------------------------------
	* Verify that the current window is indeed an edit window.
	*-----------------------------------------------------------------
	lnEditSource = m.toISX.GetEditSource(m.lnWHandle)
	If Not Inlist( m.lnEditSource, PRGFile, MenuCode, MethodCode, DBCCode, Iif(Wdockable('Command'), PRGFile, CommandWindow))
		NotEditWindow(m.tcInvocation)
		Return
	Endif

	If IsNameCharacter(m.toISX.cCharacterRight)
		NotEditWindow(m.tcInvocation)
		Return
	Endif

	*--------------------------------------------------------------------------------------
	With m.toISX
		.nEditSource		 = m.lnEditSource
		.cInvocation		 = m.tcInvocation
		.lForceThor			 = m.tlForceThor
		.lSearchSecondColumn = m.tlSearchSecondColumn
	Endwith

	*--------------------------------------------------------------------------------------
	GetNameEnteredSoFar(m.tcInvocation, m.toISX)
	If not Empty(m.tcEntity)
		m.toISX.cEntity = m.tcEntity 
	EndIf 

	If 'C' = Type ('toList.aList[1]')
		Acopy (toList.aList, m.toISX.aList)
		toISX.nCount = Alen (m.toISX.aList, 1)
	Else
		Private poISXObject
		poISXObject = Null

		FindAlias(m.toISX)
		
		*** JRN 11/18/2014 : Return result object for Go To Definition
		If m.tlReturnResult and Vartype(poISXObject) = 'O'
			Return poISXObject
		Endif
				
		ProcessProviders(m.toISX, m.tcProviders)

		If m.toISX.nCount == 0
			DoSecondPass(m.toISX, m.toISX.cEntity)
		Endif

		*** JRN 11/18/2014 : Return result object for Go To Definition
		If m.tlReturnResult
			Return poISXObject
		Endif
	Endif

	*--------------------------------------------------------------------------------------
	* If there's anything in the list, display the popup
	*--------------------------------------------------------------------------------------

	If m.toISX.nCount = 0
		InsertInvocation(m.tcInvocation)
		Return
	Endif

	If Not Empty(m.tcInvocation)
		m.toISX.InsertText( m.lnWHandle, m.tcInvocation )
	EndIf
	
	m.toISX.CloseTables()

	DisplayPopup(m.toISX)

EndProc


Procedure NotEditWindow(tcInvocation)
	If Not Empty(m.tcInvocation)
		Clear Typeahead
		Keyboard m.tcInvocation Plain
	Endif
Endproc
 

Procedure ProcessProviders
	Lparameters toISX, tcProviders

	* If no content providers, only the top four are used; otherwise only those supplied

	*--------------------------------------------------------------------------------------
	* This array lists all the providers
	*--------------------------------------------------------------------------------------
	Local laProvider[6, 2], laRequest[1], lcProviders, lnLineCount, lnRequest, lnRow

	lcProviders	= Evl(m.tcProviders, 'VAR,DEFINE,TABLE,OBJ,THOR')
	laProvider	= '<not used>'
	
	* ================================================================================
	* VAR (default)
	*	Handles MDots
	If m.toISX.nEditSource # CommandWindow
		laProvider[1, 1] = 'VAR'
		laProvider[1, 2] = 'CP_Variables'
	Endif

	* ================================================================================
	* TABLE (default)
	*	Fields in table, cursor, view, etc
	laProvider[2, 1] = 'TABLE'
	laProvider[2, 2] = 'CP_Tables'

	* ================================================================================
	* OBJ (default), also visited on second pass (need for this unclear)
	*	PEMs for existing objects, THISFORM or THIS controls, or an object from the Thor Alias Table
	laProvider[3, 1] = 'OBJ'
	laProvider[3, 2] = 'CP_Objects'

	* ================================================================================
	* THOR (default), also visited on second pass (need for this unclear)
	*	
	If m.toISX.nEditSource # CommandWindow
		laProvider[4, 1] = 'THOR'
		laProvider[4, 2] = 'CP_THOROBJECTS'
	Endif

	* ================================================================================
	* Provider DBC (only if explicitly supplied in provider list)
	*	List of tables and view in a DBC (see tool 'DBC Tables by !')
	laProvider[5, 1] = 'DBC'
	laProvider[5, 2] = 'CP_DBCOBJECTS'

	* ================================================================================
	* Provider ALLNAMES  (only if explicitly supplied in provider list)
	* 	List of all names in a code window (parameters, locals, tables referenced, etc.)
	*	Exception: In a code window, list of current aliases
	laProvider[6, 1] = 'ALLNAMES'
	laProvider[6, 2] = 'CP_ALLNAMES'

	*--------------------------------------------------------------------------------------
	* Get data from each provider and merge it into the list
	*--------------------------------------------------------------------------------------
	lnLineCount = Alines(laRequest, m.lcProviders, 5, ',')
	For lnRequest = 1 To m.lnLineCount
		lnRow = Ascan(m.laProvider, m.laRequest[m.lnRequest], 1, -1, 1, 15)
		If m.lnRow # 0
			&laProvider[m.lnRow, 2](m.toISX)
		Endif
		If m.toISX.nCount # 0
			Exit
		Endif
	Endfor

	If m.toISX.nCount = 0 And Atc('CustomISX_', m.lcProviders) = 1
		CP_Custom(m.toISX, m.tcProviders)
	Endif

Endproc


Procedure DoSecondPass(toISX, tcEntity)
	Local laList[1], lcParentEntity, lcPropertyName, lnAt, lnRow
	If Not '.' $ m.tcEntity
		Return
	Endif

	lnAt		   = Rat('.', m.tcEntity)
	lcParentEntity = Left(m.tcEntity, m.lnAt - 1)
	lcPropertyName = Substr(m.tcEntity, m.lnAt + 1)

	toISX.cEntity	  = m.lcParentEntity
	toISX.lSecondPass = .T.

	FindAlias(m.toISX)
	ProcessProviders(m.toISX, 'OBJ,THOR')

	* note that this recursion will reset m.toISX.nCount if it finds anything
	If m.toISX.nCount = 0
		DoSecondPass(m.toISX, m.lcParentEntity)
	Endif

	*--------------------------------------------------------------------------------------
	* Get the object description, if any, for this property, create the object,
	* and populate the dropdown list
	*--------------------------------------------------------------------------------------
	If m.toISX.nCount # 0
		lnRow = Ascan(m.toISX.aList, m.lcPropertyName, 1, -1, 1, 15)
		If m.lnRow # 0 And Alen(m.toISX.aList, 2) >= 6
			If PopulateArrayFromDescription(m.toISX, m.toISX.aList[m.lnRow, 6])
				Return
			Endif
		Endif
		*--------------------------------------------------------------------------------------
		* Else call plug-in which may populate the drop-down for us
		*--------------------------------------------------------------------------------------
		Acopy(m.toISX.aList, m.laList)
		If DoDataObjectPlugIn(toISX, @m.laList, m.lcPropertyName)
			Return
		Endif
	Endif
	toISX.nCount = 0
Endproc


Procedure PopulateArrayFromDescription(toISX, lcDescription)
	Local loObject, loPEMs
	If Vartype(lcDescription) # 'C'
		Return
	EndIf 
	loObject	  = Execscript(_Screen.cThorDispatcher, 'THOR_PROC_ISX_GETNEWOBJECT', m.lcDescription)
	If Vartype(m.loObject) = 'O'
		loPEMs	   = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetPropertyList', m.loObject)
		Dimension m.toISX.aList[1]
		Acopy(loPEMs.aList, m.toISX.aList)
		toISX.nCount = Alen(m.toISX.aList, 1)
		poISXObject = m.loObject && poISXObject is Private!
		Return .T.
	Else
		Return .F.
	Endif
Endproc


Procedure DoDataObjectPlugIn(toISX, taList, lcPropertyName)

	Local lnCount, loPEMs, lxObjectInfo
	loPEMs		 = Createobject('DataObjectPlugIn', @m.taList)
	lxObjectInfo = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_DataObjectPlugIn', m.loPEMs, m.lcPropertyName)

	* remove && from start of text; these are used when entering values using Property Window
	If Vartype(lxObjectInfo) = 'C' and Left(lxObjectInfo, 2) == DoubleAmps
		lxObjectInfo = Alltrim(Substr(lxObjectInfo, 3))
	EndIf 

	Do Case
		Case Isnull(m.lxObjectInfo) Or Vartype(m.lxObjectInfo) = 'L'
			Return .F.

		Case Vartype(m.lxObjectInfo) = 'C'
			If PopulateArrayFromDescription(m.toISX, m.lxObjectInfo)
				Return .T.
			Else 
				toISX.nCount  = 0
				toISX.cEntity = m.lxObjectInfo
				CP_Tables(m.toISX)
				Return m.toISX.nCount # 0
			EndIf
		
		Case Vartype(m.lxObjectInfo) # 'O'
			Return .F.

			* for an object with an array Property aList
		Case 'C' = Type('m.lxObjectInfo.aList[1]')
			Dimension m.toISX.aList[1]
			Acopy(lxObjectInfo.aList, m.toISX.aList)
			toISX.nCount	= Alen(m.lxObjectInfo.aList, 1)
			toISX.lSortList	= m.toISX.ISXOptions.AlphaSort
			Return .T.

			* for a collection, return the contents of the collection
		Case Vartype(m.lxObjectInfo.BaseClass) = 'C' And Lower(m.lxObjectInfo.BaseClass) = 'collection'
			toISX.nCount	= m.lxObjectInfo.Count
			toISX.lSortList	= m.toISX.ISXOptions.AlphaSort
			Dimension m.toISX.aList[m.lxObjectInfo.Count]
			For lnCount = 1 To m.lxObjectInfo.Count
				toISX.aList[m.lnCount] = m.lxObjectInfo.Item[m.lnCount]
			Endfor
			Return m.toISX.nCount # 0

			* for all other objects, return the list of PEMs
		Otherwise
			loPEMs	   = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetPropertyList', m.lxObjectInfo)
			Dimension m.toISX.aList[1]
			Acopy(loPEMs.aList, m.toISX.aList)
			toISX.nCount = Alen(m.toISX.aList, 1)
			Return .T.

		Otherwise
			Return .F.

	Endcase

Endproc


Procedure InsertInvocation(tcInvocation)
	Local lcTypeAhead, llDot, lnKey
	If Not Empty(m.tcInvocation)
		lcTypeAhead	= '{Mouse}{Mouse}' + m.tcInvocation
		llDot		= .F.
		Do While Chrsaw()
			lnKey = Inkey(0)
			Do Case
				Case m.lnKey = 46
					llDot = .T.
				Case Between(m.lnKey, 32, 126) Or m.lnKey = 13
					lcTypeAhead = m.lcTypeAhead + Chr(m.lnKey)
			Endcase
		Enddo
		Keyboard (m.lcTypeAhead + Iif(m.llDot, '.', '')) Plain Clear
	Endif
Endproc

*========================================================================================
* Displays a popup with all the values from taList, lets the user incrementally approach
* the desired item and inserts it into the editor.
*========================================================================================
 Procedure DisplayPopup
	Lparameter toISX

	Local loPopupForm
	If m.toISX.nCount > 0
		loPopupForm = Execscript(_Screen.cThorDispatcher, 'class= isxForm from Thor_Proc_ISXform.PRG', m.toISX )
		If Vartype(m.loPopupForm) == 'O'
			m.loPopupForm.Show()
		Endif
		loPopupForm = Null
	Endif
	Clear Class isxForm

EndProc


Procedure IsNameCharacter(lcCharacterRight)
	Return IsAlpha(m.lcCharacterRight) or IsDigit(m.lcCharacterRight) or m.lcCharacterRight = '_'
EndProc


Procedure GetNameEnteredSoFar(m.tcInvocation, m.loISX)
	*--------------------------------------------------------------------------------------
	* Determine the part of the name that has been entered so far. This code has been 
	* kindly provided by Louis D. Zelus.
	*--------------------------------------------------------------------------------------
	Local lcChar
	If Empty(m.tcInvocation)
		Do While Len(m.loISX.cTextLeft) > 0
			lcChar = Right( m.loISX.cTextLeft, 1 )
			If Isalpha(m.lcChar) Or Isdigit(m.lcChar) Or m.lcChar == '_'
				loISX.cTextLeft	= Left( m.loISX.cTextLeft, Len(m.loISX.cTextLeft) - 1 )
				loISX.cName		= m.lcChar + m.loISX.cName
			Else
				Exit
			Endif
		Enddo
	Endif

	*--------------------------------------------------------------------------------------
	* Determines the name of the entity. This code is courtesy of Sietse Wijnkler. 
	*--------------------------------------------------------------------------------------
	Do While Len(m.loISX.cTextLeft) > 0
		lcChar = Right( m.loISX.cTextLeft, 1 )
		If Isalpha(m.lcChar) Or Isdigit(m.lcChar) Or m.lcChar == '_' Or m.lcChar == '.'
			loISX.cTextLeft	= Left( m.loISX.cTextLeft, Len(m.loISX.cTextLeft) - 1 )
			loISX.cEntity	= m.lcChar + m.loISX.cEntity
		Else
			Exit
		Endif
	Enddo
	If Right(m.loISX.cEntity, 1) == Evl(m.tcInvocation, '.')
		loISX.cEntity = Left( m.loISX.cEntity, Len(m.loISX.cEntity) - 1 )
	Endif
Endproc





#Define _____________ 0
#Define __EvaluatingTextBeforeDot
*========================================================================================
* Handling for MDot
* Fills an array with all variable declarations in the current procedure of the edit 
* window identified by the WHandle, including parameters and variables referenced
* later in the same procedure
*========================================================================================
Procedure CP_Variables
	Lparameters toISX
	Local loVariables As Object
	Local laEnv[25], lcCodeBlock, lcCommand, lcLine, lcPrefix, lcValidCmds, lcVar, llIsVariable
	Local lnCurrentLine, lnPos

	*--------------------------------------------------------------------------------------
	* Check if the current entity is a variable
	*--------------------------------------------------------------------------------------
	Do Case
		Case Upper(m.toISX.cEntity) == 'M'
			m.llIsVariable = m.toISX.nEditSource > 0
		Case Empty(m.toISX.cEntity)
			If Empty(m.toISX.cInvocation)
				m.llIsVariable = .T.
			Else
				m.llIsVariable = .F.
			Endif
		Otherwise
			m.llIsVariable = .F.
	Endcase
	If Not m.llIsVariable
		Return
	Endif

	m.lcCodeBlock = m.toISX.CodeBlock
	If m.toISX.Neditsource = PRGFile && PRG
		m.lcCodeBlock = Execscript(_Screen.cThorDispatcher, 'THOR_PROC_GetProcFromPRG', m.lcCodeBlock, m.toISX.CursorPosition)
	EndIf
	
	m.loVariables = _oPEMEditor.oUtils.oBeautifyX.GetVariablesList(m.lcCodeBlock)
	Do Case
		Case m.toISX.ISXOptions.MDotsUsage = 2 And m.toISX.lForceThor
			m.lcPrefix = 'm.'
		Case m.toISX.ISXOptions.MDotsUsage = 3 And m.toISX.lForceThor
			m.lcPrefix = 'M.'
		Otherwise
			m.lcPrefix = ''
	Endcase

	For Each m.lcVar In m.loVariables FoxObject
		m.toISX.nCount = m.toISX.nCount + 1
		Dimension m.toISX.aList[m.toISX.nCount]
		m.toISX.aList[m.toISX.nCount] = m.lcPrefix + m.lcVar
	Endfor
	Return
Endproc


*====================================================================
* SW: Fills an array with all Fields for the cursor typed in.
* Returns the number of Fields. The cursor has to be open to work
*====================================================================
Procedure CP_Tables
	Lparameters toISX
	SAVEDEBUGINFO
	
	Local laEnv[25], laFields[1], laList[1], lcChar, lcDatabase, lcName, lnPos

	m.lcName = Juststem(m.toISX.cEntity)

	Do Case
		Case '.' $ m.toISX.cEntity
			Return

		Case 'm.' == Lower(m.toISX.cEntity + '.')
			Return

		Case Empty(m.toISX.cEntity) And AddAllSelectFieldNames(m.toISX)
			m.toISX.lDotIsTerminator = .F.
			m.toISX.lRemoveDot = .T.
			Return

		Case Used(m.lcName)

		Case CP_Tables_OpenView(m.lcName)

		Case File(m.lcName + '.qpr')
			CP_Tables_ExecQuery(m.lcName)

			*!* * Removed 10/15/2012 / JRN
			*!* Otherwise
			*!* 	m.lcName = OpenThorTable(m.lcName)
			*!* 	If 'C' # Vartype(m.lcName) Or Not Used(m.lcName)
			*!* 		Return
			*!* 	Endif

		Otherwise
			*-- MJP -- 10/15/2012 02:53:52 PM

			m.lcDatabase = Space(0)
			If Right( m.toISX.cTextLeft, 1 ) = '!'
				*-- It looks like the table name is preceded by a database
				*-- name, so scan backward until we find the beginning of
				*-- the name.
				m.lnPos = Len( m.toISX.cTextLeft ) - 1

				Do While m.lnPos > 0
					m.lcChar = Substr( m.toISX.cTextLeft, m.lnPos, 1 )
					If Isalpha( m.lcChar )				;
							Or Isdigit( m.lcChar )		;
							Or m.lcChar = '_'
						m.lcDatabase = m.lcChar + m.lcDatabase
					Else
						*-- Found the beginning of the database name.
						Exit
					Endif

					m.lnPos = m.lnPos - 1
				Enddo

				*-- If a database name was found, append the exclamation
				*-- mark to it.
				If Not Empty( m.lcDatabase )
					m.lcDatabase = m.lcDatabase + '!'
				Endif
			Endif

			*-- Add the database name to the table name when attempting to
			*-- open the table.
			*!*             m.lcName = OpenThorTable(m.lcName)
			m.lcName = CP_Tables_OpenThorTable( m.lcDatabase + m.lcName)
			Do Case
				Case 'C' = Vartype(m.lcName) And Used(m.lcName)

				Case 'O' = Vartype(m.lcName) And 'N' = Type('ALen(m.lcName.aList)')
					m.toISX.nCount = Alen(m.lcName.aList, 1)
					Dimension m.toISX.aList(m.toISX.nCount, Alen(m.lcName.aList, 2))
					Acopy(lcName.aList, m.toISX.aList)
					Return

				Case 'O' = Vartype(m.lcName)
					Private loPrivateObject
					m.loPrivateObject = m.lcName
					CP_Objects(m.toISX, 'loPrivateObject')
					Return

				Otherwise
					Return

			Endcase

	EndCase
	
	CP_Tables_ShowTable(m.toISX, m.lcName)

Endproc
  

Procedure CP_Tables_ShowTable(toISX, lcName)
	Local laFields[1], laList[1]

	toISX.lSortList	= m.toISX.ISXOptions.AlphaSort
	toISX.NCount	= Afields(laFields, m.lcName)
	Dimension m.laList[1]
	Execscript(_Screen.cThorDispatcher, 'THOR_PROC_GetFieldNames', @m.laFields, @m.laList, m.toISX.ISXOptions.Fieldnamescase, m.lcName)
	toISX.NCount = Alen(m.laList, 1)
	Dimension m.toISX.aList(m.toISX.NCount, Alen(m.laList, 2))
	Acopy(laList, m.toISX.aList)
	toISX.lDotIsTerminator = .F.
Endproc

*====================================================================
* Open a view
*====================================================================
* Eddy Maue
* November 11, 2004
*====================================================================
Procedure CP_Tables_OpenView
	Lparameters lcName, lcSafety, lcConsol
	If Type('_vfp.ActiveProject') = 'U' .Or. Empty(Dbc())
		Return .F.
	Endif
	lcSafety = 'Set Safety ' + Set('safety')
	Set Safety Off
	List Views To File _view.tmp Noconsole
	If ':' + Alltrim(Lower(m.lcName)) + '(' $ Strtran(Lower(Filetostr('_view.tmp')), ' ', '')
		Use (m.lcName) In 0 Nodata
	Endif
	&lcSafety
	Return Used(m.lcName)
Endproc

 
*====================================================================
* Open a query
*====================================================================
* Eddy Maue
* November 11, 2004
*====================================================================
Procedure CP_Tables_ExecQuery
	Lparameters lcName
	Do (m.lcName + '.qpr')
	Return Used(m.lcName)
Endproc

*====================================================================
* Call standard Thor Proc to open a Thor table
* JRN: Jim Nelson
* July 25, 2012
*====================================================================
Procedure CP_Tables_OpenThorTable
	Lparameters lcName
	Local lcResult
	Do Case
		Case Empty (m.lcName)
			Return .F.
		Case Type ('_Screen.cThorDispatcher') = 'C'
			lcResult = Execscript (_Screen.cThorDispatcher, 'PEME_OpenTable', m.lcName)
			Return (m.lcResult)
		Otherwise
			Return .F.
	Endcase
Endproc



*====================================================================
* SW: Fills an array with all PEMs for the objectname typed in
* Returns the number of PEMs. The object has to exist to work
*====================================================================
Procedure CP_Objects
	Lparameters toISX, tcName

	Local loTools As Pemeditor_tools Of 'c:\visual foxpro\programs\MyThor\thor\tools\apps\pem editor\source\peme_tools.vcx'
	Local lcFullName, lcName, lcNewName, lcObjectName, loList, loObject, loPEMs, loThis, loThisForm

	SAVEDEBUGINFO
	lcName	 = Evl(m.tcName, m.toISX.cEntity)
	loObject = .F.
	Do Case
		Case Type(m.lcName) = [O]
			SAVEDEBUGINFO
			loObject = Evaluate(m.lcName)
		Case m.toISX.nEditSource = MethodCode And m.toISX.ISXOptions.OverrideThisform = 1

		Case m.toISX.nEditSource = MethodCode And(Left(m.lcName, 1) = '.' Or Empty(m.lcName) Or m.toISX.lSecondPass Or m.toISX.ISXOptions.OverrideThisform > 1)
			* tools home page = https://github.com/VFPX/Thor/blob/master/Docs/Thor_tools_object.md
			SAVEDEBUGINFO
			loTools		 = Execscript(_Screen.cThorDispatcher, 'Class= tools from pemeditor')
			If m.toISX.lSecondPass Or m.toISX.nEditSource = CommandWindow Or m.toISX.lAliased
				lcFullName = m.lcName
			Else
				lcFullName = m.loTools.oUtils.oIDEx.GetCurrentHighlightedText(.T.)
			Endif
			AddDebuggerText(m.lcFullName)
			Do Case
				Case Atc('thisform.', m.lcFullName + '.') = 1
					SAVEDEBUGINFO
					loThisForm	 = m.loTools.GetCurrentObject(.T.)
					lcObjectName = 'lo' + m.lcFullName
					If Type(m.lcObjectName) = [O] And Lower(m.loThisForm.BaseClass) == 'form'
						loObject = Evaluate(m.lcObjectName)
					Endif
					#If DEBUGGING
						AddDebuggerText('Thisform = ' + Transform(m.loThisForm))
						AddDebuggerText('ObjectName = ' + Transform(m.lcObjectName))
						AddDebuggerText('Object = ' + Transform(m.loObject))
					#Endif
				Case Atc('this.', m.lcFullName + '.') = 1 And		;
						(m.toISX.ISXOptions.OverrideThisform > 1 Or (Not Lower(m.lcFullName) == Lower('this' + m.lcName)))
					SAVEDEBUGINFO
					loThis		 = m.loTools.GetThis()
					lcObjectName = 'lo' + m.lcFullName
					If Type(m.lcObjectName) = [O]
						loObject = Evaluate(m.lcObjectName)
					Endif
			Endcase
		Case m.toISX.nEditSource = PRGFile And(m.toISX.ISXOptions.PRGBasedClasses > 1  Or m.toISX.lSecondPass)
			* tools home page = https://github.com/VFPX/Thor/blob/master/Docs/Thor_tools_object.md
			SAVEDEBUGINFO
			loTools		 = Execscript(_Screen.cThorDispatcher, 'Class= tools from pemeditor')
			If m.toISX.lSecondPass Or m.toISX.nEditSource = CommandWindow
				lcFullName = m.lcName
			Else
				lcFullName = m.loTools.oUtils.oIDEx.GetCurrentHighlightedText(.T.)
			Endif

			If 'this' == Lower(m.lcFullName)
				loList = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetPRGBasedClassPEMs', m.toISX.ISXOptions.PRGBasedClasses)
				If 'C' = Type('loList.aList[1]')
					Acopy(loList.aList, m.toISX.aList)
					toISX.NCount = Alen(m.toISX.aList, 1)
				Endif
			Endif

		Otherwise
			lcNewName = Execscript (_Screen.cThorDispatcher, 'Thor_Proc_GetThorTableAlias', m.lcName)
			Do Case
				Case Vartype(m.lcNewName) = 'C' and not Used(m.lcNewName)
					loObject = Execscript(_Screen.cThorDispatcher, 'THOR_PROC_ISX_GetNewObject', m.lcNewName)
				Case Vartype(m.lcNewName) = 'C' and Used(m.lcNewName)
					CP_Tables_ShowTable(m.toISX, m.lcNewName)
			Endcase
	Endcase

	If Vartype(m.loObject) = 'O' && VarType fails here if object has been nulled out
		SAVEDEBUGINFO
		Try 
			loPEMs	   = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetPropertyList', m.loObject)
			If Type('m.loPEMs.aList[1, 1]') = 'C'
				Dimension m.toISX.aList[1]
				Acopy(loPEMs.aList, m.toISX.aList)
				toISX.NCount = Alen(m.toISX.aList, 1)
			Endif
		Catch to loException
			
		EndTry
	Endif

Endproc
 

*====================================================================
*** JRN 7/26/2012 : Calls a Thor PROC that can interpret the supplied
* name, which is some presumed to be some kind of object reference
* to a table, and adds the field names from the table
* Returns the number of PEMs. The object has to exist to work
*====================================================================
Procedure CP_ThorObjects
Lparameters toISX
	
	SAVEDEBUGINFO
	Local lnCount, loCollection
	If Type('_Screen.cThorDispatcher') = 'C'
		m.loCollection = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetFieldsFromObjectName', m.toISX)
		Do Case
			Case 'C' = Type("loCollection.aList[1]")
				Dimension m.toISX.aList[1]
				Acopy(loCollection.aList, m.toISX.aList)
				m.toISX.nCount = Alen(m.loCollection.aList, 1)
				m.toISX.lSortList = m.toISX.ISXOptions.AlphaSort

			Case 'O' = Vartype(m.loCollection)
				m.toISX.nCount = m.loCollection.Count
				m.toISX.lSortList = m.toISX.ISXOptions.AlphaSort
				Dimension m.toISX.aList[m.loCollection.Count]
				For m.lnCount = 1 To m.loCollection.Count
					m.toISX.aList[m.lnCount] = m.loCollection.Item[m.lnCount]
				EndFor 
				Return m.loCollection.Count

			Otherwise 
				Return 0
		Endcase
	Else
		Return 0
	Endif
		
EndProc 


*=================================================================
* Fills the array with tables and views in database 
* Searches for database: used / in path / in pjx
*=================================================================
Procedure CP_DbcObjects
	Lparameters toISX
	SAVEDEBUGINFO

	*-- open; path; project ?
	Local llFailed, lcFile, lnCountTables, lnCountViews, lnCountResult, lnI, lcDbcName
	Local Array laDbTables[1], laDbViews[1], laResult[1]

	m.lcDbcName = Juststem(m.toISX.cEntity)

	Do Case
		Case Dbused(m.lcDbcName)					&& dbc is open -> make active
			Set Database To (m.lcDbcName)
		Case File( Forceext(m.lcDbcName,'dbc') )		&& dbc in path -> open (will make it active)
			Open Database (m.lcDbcName)
		Otherwise								&& try to grab it from active project, if not mark as failed
			Try
				m.lcFile = _vfp.ActiveProject.Files( Forceext(m.lcDbcName,'dbc') ).Name
				Open Database (m.lcFile)
			Catch
				m.llFailed = .T.
			Endtry
	Endcase

	If m.llFailed Then 
		Return .F.
	EndIf

	m.lnCountTables	= Adbobjects(laDbTables	,"TABLE")
	m.lnCountViews	= Adbobjects(laDbViews	,"VIEW"	)
	*--?: individual sorted, tables and then views 

	m.lnCountResult	= m.lnCountTables + m.lnCountViews
	Dimension laResult[ m.lnCountResult ]
	If m.lnCountTables > 0
		Acopy(laDbTables, laResult, 1, m.lnCountTables	, 1	)
	EndIf 
	If lnCountViews > 0 
		Acopy(laDbViews	, laResult, 1, m.lnCountViews	, m.lnCountTables + 1	)
	EndIf 
	*--?: mixed sorted, tables + views 

	*--!: should lowercase all 
	For m.lnI = 1 To m.lnCountResult
		m.laResult[m.lnI] = Lower(m.laResult[m.lnI])
	EndFor 

	m.toISX.lSortList = .T.
	m.toISX.nCount	  = m.lnCountResult
	Dimension m.toISX.Alist( Alen(m.laResult, 1), Evl(Alen(m.laResult, 2),1) )
	Acopy(laResult, m.toISX.Alist)

EndProc 


Procedure CP_AllNames
	Lparameters toISX
	Local laEnv[1], laList[1], laUsed[1], lcAlias, lcCodeBlock, lcExt, lcLen, lcPrefix, lnCount, lnI
	Local loFixCase, loNames

	lcCodeBlock	= m.toISX.CodeBlock
	lcLen		= Len(m.toISX.cName)
	lcCodeBlock	= Stuff(m.lcCodeBlock, m.toISX.CursorPosition - m.lcLen + 1, m.lcLen, Space(m.lcLen))

	Do Case
		Case m.toISX.nEditSource = PRGFile And Not m.toISX.ISXOptions.AllProcedures
			lcCodeBlock = Execscript(_Screen.cThorDispatcher, 'THOR_PROC_GetProcFromPRG', m.lcCodeBlock, m.toISX.CursorPosition)
		Case m.toISX.nEditSource = CommandWindow
			lnCount = Aused(laUsed)

			If m.lnCount > 0
				Dimension m.laList[m.lnCount, 2]

				Execscript (_Screen.cThorDispatcher, 'Thor_Proc_GetISXOptions')
				loFixCase = _Screen.oISXOptions.oKeyWordList

				For lnI = 1 To m.lnCount
					lcAlias			 = m.laUsed[m.lnI, 1]
					laList[m.lnI, 1] = Evl(m.loFixCase.FixCase(m.lcAlias, .T.), m.lcAlias)
					lcExt			 = Upper(Justext(Dbf(m.lcAlias)))
					laList[m.lnI, 2] = Icase(					;
						  m.lcExt = 'DBF', '',					;
						  m.lcExt = 'PJX', 'Project',			;
						  m.lcExt = 'SCX', 'Form',				;
						  m.lcExt = 'VCX', 'Class Lib',			;
						  m.lcExt = 'FRX', 'Report',			;
						  'Cursor')
				Endfor
				toISX.NCount = m.lnCount
				Dimension m.toISX.aList[1]
				Acopy(laList, m.toISX.aList)
				toISX.lSortList = .T.
				Return

			Else
				lcCodeBlock = ''
			Endif

		Otherwise
	Endcase

	Do Case
		Case m.toISX.ISXOptions.MDotsUsage = 2 And m.toISX.lForceThor
			lcPrefix = 'm.'
		Case m.toISX.ISXOptions.MDotsUsage = 3 And m.toISX.lForceThor
			lcPrefix = 'M.'
		Otherwise
			lcPrefix = ''
	Endcase


	lcCodeBlock	= Strtran(m.lcCodeBlock, '#Define', Space(7))
	loNames		= Execscript(_Screen.cThorDispatcher, 'THOR_PROC_GetNamesFromCodeBlock', m.lcCodeBlock, m.lcPrefix)
	If 'O' = Vartype(m.loNames)
		toISX.NCount = Alen(m.loNames.aList, 1)
		Dimension m.toISX.aList[1]
		Acopy(m.loNames.aList, m.toISX.aList)
		toISX.lSortList = .F.
	Endif
	Return

Endproc


Procedure CP_Custom
	Lparameters toISX, tcCustomName
	Local laEnv[1], lcCodeBlock, loNames
	m.lcCodeBlock = m.toISX.CodeBlock
	If m.toISX.nEditSource = PRGFile And Not toISX.isxoptions.AllProcedures
		m.lcCodeBlock = Execscript(_Screen.cThorDispatcher, 'THOR_PROC_GetProcFromPRG', m.lcCodeBlock, m.toISX.CursorPosition)
	Endif

	m.loNames = Execscript(_Screen.cThorDispatcher, 'THOR_PROC_' + tcCustomName, m.lcCodeBlock)
	If 'O' = Vartype(m.loNames)
		m.toISX.nCount = Alen(m.loNames.aList, 1)
		Dimension m.toISX.aList[1]
		Acopy(m.loNames.aList, m.toISX.aList)
		m.toISX.lSortList = .F.
	Endif
	Return

Endproc


#Define ____________ 0
#Define __ProcessingAliases 0
*========================================================================================
Procedure FindAlias(loISX)
	*--------------------------------------------------------------------------------------
	* Look for aliases such as *#Alias x = y  or loObject = This.oData
	*--------------------------------------------------------------------------------------
	Local lcAliasName, lcName, lcWord1, loTools
	m.lcName = m.loISX.cEntity
	If m.loISX.nCount = 0 And m.loISX.nEditSource # CommandWindow
		If (Left(m.lcName, 1) = '.') Or Empty(m.lcName)
			* tools home page = https://github.com/VFPX/Thor/blob/master/Docs/Thor_tools_object.md
			m.loTools = Execscript(_Screen.cThorDispatcher, 'Class= tools from pemeditor')
			m.lcName  = m.loTools.oUtils.oIDEx.GetCurrentHighlightedText(.T.)
			m.loISX.cEntity = m.lcName
		Endif
		lcAliasName = GetAliasFor(m.loISX, m.lcName)
		If Not Empty(m.lcAliasName)
			loISX.lAliased = .T.
			loISX.cEntity  = m.lcAliasName
		Else
			If m.loISX.nEditSource = PRGFile
				lcAliasName = GetDoubleBracketsAliasFor(m.loISX, m.lcName)
				If Not Empty(m.lcAliasName)
					loISX.lAliased = .T.
					loISX.cEntity  = m.lcAliasName
				Endif
			Endif
		EndIf
		*!* ******************** End of duplicated text *********************
	Endif
				
Endproc
				

Procedure GetAliasFor
	Lparameters toISX, tcAlias

	Local laClass[1], laText[1], lcAlias, lcAltResult, lcClass, lcClassLib, lcCommand, lcCurrentLine
	Local lcLine, lcQuote, lcResult, lcText, llSelectOK, llSingleAlias, llTextBlockOK, lnCount
	Local lnCurrentLine, lnEnd, lnLineCount, lnStart, lxResult
	* poISXObject is a private variable to main routine
	Dimension m.laText[1]

	lcResult	  = ''
	llSingleAlias = Vartype(m.tcAlias) = 'C'
	If Empty(m.tcAlias) And m.llSingleAlias
		Return m.lcResult
	Endif

	If m.toISX.nEditSource = CommandWindow
		Return m.lcResult
	Endif

	lcAlias		  = RemoveMDot(m.tcAlias)
	lnStart		  = 0
	lnEnd		  = m.toISX.GetCurrentLine( m.toISX.nWHandle )
	llSelectOK	  = .T.
	llTextBlockOK = .T.
	lcAltResult	  = ''

	*** JRN 2023-12-22 : It will only read at most the first 64K characters
	lnLineCount = m.toISX.AGetLines(m.toISX.nWHandle, @m.laText, Max(m.lnStart, m.lnEnd - 64000), m.lnEnd)
	For lnCurrentLine = m.lnLineCount To 1 Step - 1
		lcCurrentLine = m.laText[m.lnCurrentLine]
		lcCommand	  = RemoveMDot(Alltrim(Getwordnum(m.lcCurrentLine, 1, '=('), ' ', Chr[9]))

		If m.llSingleAlias And Atc(m.lcAlias, m.lcCurrentLine) # 0 And m.lnCurrentLine < m.lnLineCount
			If Upper(m.lcAlias) == Upper(m.lcCommand)
				lcText	= Alltrim(Getwordnum(m.lcCurrentLine, 2, '=('))
				lnCount	= Alines(laClass, Strextract(m.lcCurrentLine, '(', ')'), 5, ',')
				If m.lnCount # 0
					lcClass = Evl(m.toISX.StripQuotes(m.laClass[1]), '')
					If m.lnCount = 1
						lcClassLib = ''
					Else
						lcClassLib = Evl(m.toISX.StripQuotes(m.laClass[2]), '')
					Endif
					Do Case
						Case Upper(m.lcText) == 'CREATEOBJECT' And Not Empty(m.lcClass)
							lxResult = GetLocalClassPEMs(m.lcClass, '', m.toISX)
							Do Case
								Case Vartype(m.lxResult) = 'C'
									Return m.lxResult
								Case m.lxResult
									Return .F.
							Endcase
						Case Upper(m.lcText) == 'NEWOBJECT' And Not Empty(m.lcClass)
							If 'C' = Vartype(m.lcClassLib)
								lxResult = GetLocalClassPEMs(m.lcClass, m.lcClassLib, m.toISX)
								Do Case
									Case Vartype(m.lxResult) = 'C'
										Return m.lxResult
									Case m.lxResult
										Return .F.
								Endcase
							Endif
						Otherwise
							poISXObject = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_NewObject', m.lcText, m.lcClass, Iif('C' = Vartype(m.lcClassLib), m.lcClassLib, ''))
							If Vartype(m.poISXObject) = 'O'
								Return 'm.poISXObject'
							Endif
					Endcase
				Endif
				If '=' $ m.lcCurrentLine
					lcAltResult =  Alltrim(Substr(m.lcCurrentLine, 1 + At('=', m.lcCurrentLine)))
				Endif
			Endif

			lcLine = ExtractAliasLine(m.lcAlias, m.lcCommand, m.lcCurrentLine)			
			If Not Empty(m.lcLine)
				lcResult	= Alltrim(Substr(m.lcLine, At('=', m.lcLine) + 1))
				poISXObject	= Execscript(_Screen.cThorDispatcher, 'THOR_PROC_ISX_GetNewObject', m.lcResult)
				If Vartype(m.poISXObject) = 'O'
					Return 'm.poISXObject'
				Endif
				Exit
			Endif

			If Upper(Getwordnum(m.lcCommand, 1)) == 'USE'
				lcResult = GetAliasFromUSE(m.lcCurrentLine, m.tcAlias)
				If Not Empty(m.lcResult)
					Exit
				Endif
			Endif

			If Upper(m.lcCommand) == Upper(m.toISX.ISXOptions.AliasMethodName)
				lcResult = GetAliasFromAliasMethod(m.toISX, m.lcCurrentLine, m.tcAlias, m.toISX.ISXOptions.AliasPosition, m.toISX.ISXOptions.AliasNamePosition)
				If Not Empty(m.lcResult)
					Exit
				Endif
			Endif

		Endif

		* don't move this. Aliases may be shorter
		If Len(m.lcCommand) < 4
			Loop
		Endif

		If m.llSingleAlias ;
				And (m.toISX.IsFoxProCommand( Getwordnum(m.lcCommand, 1), 'LOCAL' ) ;
					or m.toISX.IsFoxProCommand( Getwordnum(m.lcCommand, 1), 'PUBLIC')) ;
				And Upper(m.lcAlias) == Upper(Getwordnum(m.lcCommand, 2))
			lcClass	   = Chrtran(Getwordnum(m.lcCommand, 4), ['"] + '[]', '')
			lcClassLib = ''
			If Upper(Getwordnum(m.lcCommand, 5)) == 'OF'
				lcClassLib = Getwordnum(m.lcCommand, 6)
				lcQuote	   = Left(m.lcClassLib, 1)
				If m.lcQuote $  ['"] + '['
					lcClassLib = Substr(m.lcCommand, Atc(m.lcClassLib, m.lcCommand))
					lcClassLib = Strextract(m.lcClassLib, m.lcQuote, Chrtran(m.lcQuote, '[', ']'))
				Endif
			Endif
			lcResult = GetLocalClassPEMs(m.lcClass, m.lcClassLib, m.toISX)
			Do Case
				Case Vartype(m.lcResult) = 'C'
					Return m.lcResult
				Case m.lcResult
					Return .F.
			Endcase
			poISXObject = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_NewObject', 'Local', m.lcClass)
			If Vartype(m.poISXObject) = 'O'
				Return 'm.poISXObject'
			Endif
		Endif

		If m.toISX.IsFoxProCommand( Getwordnum(m.lcCommand, 1), 'PROCEDURE,FUNCTION,PROTECTED,HIDDEN' )
			Exit
		Endif

		If m.llTextBlockOK And m.toISX.IsFoxProCommand( Getwordnum(m.lcCommand, 1), 'TEXT')
			lcResult = GetAliasForSQLSelect(m.toISX, m.lcAlias, m.lnCurrentLine)
			If Vartype(m.lcResult) # 'L'
				lcAlias = m.lcResult
				Exit
			Else
				llTextBlockOK = .F.
			Endif
		Endif

		If m.toISX.IsFoxProCommand( Getwordnum(m.lcCommand, 1), 'ENDTEXT')
			llTextBlockOK = .F.
		Endif

		If m.llSelectOK And m.toISX.IsFoxProCommand( Getwordnum(m.lcCommand, 1), 'SELECT,UPDATE,DELETE' )
			lcResult = GetAliasForSelect(m.toISX, m.lcAlias, m.lnCurrentLine, m.lnLineCount)
			If Vartype(m.lcResult) # 'L'
				lcAlias = m.lcResult
				Exit
			Endif
		Endif

		* check for continuation lines, needed if we are within a SELECT
		If m.llSelectOK And m.lnCurrentLine > 1
			lcText = m.laText[m.lnCurrentLine - 1]
			If DoubleAmps $ m.lcText
				lcText = Left(m.lcText, At(DoubleAmps, m.lcText) - 1)
			Endif
			lcText	   = Alltrim(m.lcText, ' ', Chr[9])
			llSelectOK = ';' = Right(m.lcText, 1)
		Endif

	Endfor

	If 'C' = Vartype(m.lcResult)
		Return Evl(m.lcResult, m.lcAltResult)
	Else
		Return m.lcResult
	Endif

Endproc


Procedure RemoveMDot(tcText)
	If Vartype(tcText) = 'C' and Upper(tcText) = 'M.'
		Return Substr(tcText, 3)
	Else
		Return tcText
	endif
EndProc


Procedure ExtractAliasLine(lcAlias, lcCommand, lcCurrentLine)
	Local lcLine
	If Upper(m.lcCommand) = '*#ALIAS'		;
			And Upper(m.lcAlias) == RemoveMDot(Upper(Alltrim(Substr(m.lcCommand, 8))))
		Return Substr(m.lcCurrentLine, 8)
	Endif

	If DoubleAmps + '#ALIAS' $ Upper(m.lcCurrentLine)
		Return Substr(m.lcCurrentLine, At(DoubleAmps, m.lcCurrentLine) + 9)
	Endif

	lcLine = Strextract(m.lcCurrentLine, '{{', '}}')
	If Upper(m.lcAlias) == RemoveMDot(Upper(Alltrim(Getwordnum(m.lcLine, 1, '=('))))
		Return m.lcLine
	Endif

	Return ''
Endproc


	
	

Procedure GetAliasFromUSE(tcCurrentLine, tcAlias)
	Local lcFileName, lcLeftDelim, lcLine, lcRightDelim, lnI

	lcLine		= m.tcCurrentLine
	lcFileName	= Getwordnum(m.lcLine, 2)
	lcLeftDelim	= Left(m.lcFileName, 1)

	Do Case
		Case m.lcLeftDelim $ '&('
			Return ''
		Case m.lcLeftDelim $ ['"] + '['
			lcRightDelim = Iif(m.lcLeftDelim = '[', ']', m.lcLeftDelim)
			lcFileName	 = Strextract(m.lcLine, m.lcLeftDelim, m.lcRightDelim)
			lcLine		 = Strtran(m.lcLine, m.lcLeftDelim + m.lcFileName + m.lcRightDelim, 'Filler')
	Endcase

	For lnI = 3 To Getwordcount(m.lcLine) - 1
		If Upper(Getwordnum(m.lcLine, m.lnI)) == 'ALIAS'
			If Upper(Getwordnum(m.lcLine, m.lnI + 1)) == Upper(m.tcAlias)
				Return m.lcFileName
				Exit
			Endif
		Endif
	Endfor
	Return ''
EndProc


Procedure GetAliasFromAliasMethod(toISX, tcCurrentLine, tcAlias, tnAliasPosition, tnAliasNamePosition)
	Local laText[1], lcAliasX, lcNameX, lnCount
	lnCount = Alines(laText, Upper(Strextract(m.tcCurrentLine, '(', ')')), 1, ',')
	If Between(tnAliasPosition, 1, lnCount)			;
			And Between(tnAliasNamePosition, 1, lnCount)
		lcAliasX = m.toISX.StripQuotes(laText[tnAliasPosition])
		lcNameX	 = m.toISX.StripQuotes(laText[tnAliasNamePosition])
		If Evl(lcAliasX, '?') == Upper(m.tcAlias) And Vartype(lcNameX) = 'C'
			Return lcNameX
		Endif
	Endif
	Return ''
Endproc
 

Procedure GetAliasForSelect (toISX, tcAlias, tnCurrentLine, tnCursorLine)
 	Local loResult As 'Empty'
 	Local laAliases[1], laText[1], lcText, lcTextLine, lnAliasCount, lnCurrentLine, lnRow
 
 	m.lcTextLine	= ''
 	m.lnCurrentLine	= m.tnCurrentLine - 1
 	Do While .T.
 		m.toISX.AGetLines (m.toISX.nWHandle, @m.laText, m.lnCurrentLine, m.lnCurrentLine )
 		m.lcText = m.laText
 		If DoubleAmps $ m.lcText
 			m.lcText = Left (m.lcText, At (DoubleAmps, m.lcText) - 1)
 		Endif
 		m.lcText = Alltrim (m.lcText, ' ', Chr[9])
 		Do Case
 			Case Empty (m.lcText)
 				Exit
 			Case ';' = Right (m.lcText, 1) 
 				m.lcTextLine = m.lcTextLine + Substr (m.lcText, 1, Len (m.lcText) - 1) + ' '
 			Case m.lnCurrentLine = m.tnCursorLine - 1
 				m.lcTextLine = m.lcTextLine + m.lcText + ' '
 			Otherwise
 				m.lcTextLine = m.lcTextLine + m.lcText
 				Exit
 		Endcase
 		m.lnCurrentLine = m.lnCurrentLine + 1
 	Enddo
 
 	lnAliasCount = GetAliases(m.lcTextLine, @laAliases)
 	
 	If lnAliasCount # 0
 		If Vartype(tcAlias) = 'C'
 			lnRow = Ascan(laAliases, tcAlias, 1, -1, 1, 15)
 			If lnRow # 0
	 			toISX.cLocalAlias = tcAlias
 				Return laAliases[lnRow, 2]
 			Endif
 		Else
 			loResult = Createobject('Empty')
 			AddProperty(loResult, 'Aliases[1]')
 			Acopy(laAliases, loResult.Aliases)
 			Return loResult
 		Endif
 	Endif
 	Return .F.
 Endproc
  

Procedure GetAliases(lcTextLine, laResult)
	Local loAliases As 'Collection'
	Local lcAlias, lcTable, lcWord, lnCount, lnI
	lnCount = 0
	For m.lnI = 1 To Getwordcount (m.lcTextLine)
		m.lcWord = Upper (Getwordnum (m.lcTextLine, m.lnI))
		If m.lcWord == 'FROM' Or m.lcWord == 'JOIN'
			m.lcTable = Getwordnum (m.lcTextLine, m.lnI + 1)
			Do Case
				Case m.lcTable = '(' or m.lcTable = '<'
					m.lcTable = 'm.'
				Case Upper (Getwordnum (m.lcTextLine, m.lnI + 2)) == 'AS'
					m.lcAlias = Getwordnum (m.lcTextLine, m.lnI + 3)
				Otherwise 
					m.lcAlias = Getwordnum (m.lcTextLine, m.lnI + 2)
					If Atc(' ' + m.lcAlias + ' ', SQLKeywords) # 0
						m.lcAlias = ''
					EndIf 
			Endcase
			lnCount = lnCount + 1
			Dimension laResult(lnCount, 2)
			laResult[lnCount, 1] = m.lcAlias
			laResult[lnCount, 2] = m.lcTable
		Endif
	Endfor
	Return lnCount
EndProc


Procedure GetAliasForSQLSelect(toISX, tcAlias, lnLineNo)

	Local loResult As 'Empty'
	Local laAliases[1], laText[1], lcText, lcTextLine, lnAliasCount, lnBlankLines, lnRow
	lcTextLine	 = ''
	lnBlankLines = 0
	Do While .T.
		m.toISX.AGetLines (m.toISX.nWHandle, @m.laText, m.lnLineNo, m.lnLineNo)
		m.lcText = m.laText
		Do Case
			Case Empty(m.lcText)
				lnBlankLines = lnBlankLines + 1
				If lnBlankLines > 10
					Exit
				Endif
			Case Len(Getwordnum(m.lcText, 1)) >= 4 And m.toISX.ISFoxProCommand( Getwordnum(m.lcText, 1), 'ENDTEXT')
				Exit
			Otherwise
				lcTextLine	 = lcTextLine + ' ' + m.lcText
				lnBlankLines = 0
		Endcase
		lnLineNo = lnLineNo + 1
	Enddo

	lnAliasCount = GetAliases(m.lcTextLine, @laAliases)
	If lnAliasCount # 0
		If Vartype(tcAlias) = 'C'
			lnRow = Ascan(laAliases, tcAlias, 1, -1, 1, 15)
			If lnRow # 0
	 			toISX.cLocalAlias = tcAlias
				Return laAliases[lnRow, 2]
			Endif
		Else
			loResult = Createobject('Empty')
			AddProperty(loResult, 'Aliases[1]')
			Acopy(laAliases, loResult.Aliases)
			Return loResult
		Endif
	Endif
	Return .F.

EndProc


Procedure GetDoubleBracketsAliasFor(loISX, lcName)
	Local lcAlias, lcCode, lcMatch, lcPattern, loMatches, loRegExp
	* poISXObject is a private variable to main routine
	
	If not Empty(Chrtran(Upper(lcName), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', '')) 
		Return .f.
	EndIf 		

	loRegExp		 = GetRegExp(m.loISX)
	lcPattern		 = '{{\s*' + m.lcName + '\s*=.*}}'
	loRegExp.Pattern = m.lcPattern

	lcCode	  = Left(m.loISX.CodeBlock, m.loISX.CursorPosition)
	loMatches = m.loRegExp.Execute(m.lcCode)
	If m.loMatches.Count = 0
		Return .F.
	Else
		lcMatch		= m.loMatches.Item[m.loMatches.Count - 1].Value
		lcAlias		= Strextract(m.lcMatch, '=', '}}', 1)
		poISXObject	= Execscript(_Screen.cThorDispatcher, 'THOR_PROC_ISX_GetNewObject', m.lcAlias)
		If Vartype(m.poISXObject) = 'O'
			Return 'm.poISXObject'
		Else
			Return m.lcAlias
		Endif
	Endif

Endproc


Procedure GetRegExp(loISX)
	If Pemstatus(m.loISX, 'oRegExp', 5) = .F.
		m.loISX.AddProperty('oRegExp', Createobject ('VBScript.RegExp'))
		With m.loISX.oRegExp
			.IgnoreCase	= .T.
			.Global		= .T.
			.MultiLine	= .T.
		Endwith
	Endif

	Return m.loISX.oRegExp
Endproc


*========================================================================================
Procedure AddAllSelectFieldNames(toISX)
	Local laList[1], lcEntity, lcPrefix, lnI, lnJ, lnRecords, loResult

	m.loResult = GetAliasFor(m.toISX)
	m.lcEntity = m.toISX.cEntity

	Do Case
		Case Vartype(m.loResult) # 'O'
			Return .F.
		Case Alen(m.loResult.Aliases, 1) = 1
			m.toISX.cEntity	= m.loResult.Aliases[1, 2]
			CP_Tables(m.toISX)
		Otherwise
			lnRecords = 0
			For lnI = 1 To Alen(m.loResult.Aliases, 1)
				m.toISX.cEntity	= m.loResult.Aliases[lnI, 2]
				m.toISX.nCount	= 0
				CP_Tables(m.toISX)
				If m.toISX.nCount # 0
					Dimension m.laList(lnRecords + m.toISX.nCount, 3)
					lcPrefix = Evl(m.loResult.Aliases[lnI, 1], m.loResult.Aliases[lnI, 2]) + '.'
					For lnJ = 1 To m.toISX.nCount
						laList[lnRecords + lnJ, 1] = lcPrefix + m.toISX.aList[lnJ, 1]
						laList[lnRecords + lnJ, 2] = m.toISX.aList[lnJ, 2]
						laList[lnRecords + lnJ, 3] = m.toISX.aList[lnJ, 3]
					Endfor
					lnRecords = lnRecords + m.toISX.nCount
				Endif
			Endfor

			If lnRecords # 0
				m.toISX.nCount = lnRecords
				Dimension m.toISX.aList(m.toISX.nCount, Alen(m.laList, 2))
				Acopy(laList, m.toISX.aList)
			Else
				Return .F.
			Endif
	Endcase
	m.toISX.cEntity = lcEntity
	Return m.toISX.nCount # 0
Endproc


Procedure GetLocalClassPEMs(lcClass, lcClassLib, toISX)
	* look in current PRG file first?
	Local laMembers[1], loException, loList, loObject, loPEMs
	
	If Empty(lcClassLib) And m.toISX.nEditSource = PRGFile
		m.loList = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetPRGBasedClassPEMs', m.toISX.isxoptions.PRGBasedClasses, m.toISX.CodeBlock, 0, lcClass)
		If 'C' = Type('loList.aList[1]')
			Acopy(loList.aList, m.toISX.aList)
			m.toISX.nCount = Alen(m.toISX.aList, 1)
			Return .T.
		Endif
	Endif

	Try
		loObject   = Newobject(lcClass, lcClassLib, 0)
	Catch To loException
	Endtry

	If Vartype(m.loObject) = 'O'
		m.poISXObject = m.loObject
		Return 'm.poISXObject'
	Else
		Return .F.
	Endif
Endproc



#Define __________ 0
#Define __Various_Utilities 0
*========================================================================================
*========================================================================================
*	Various Utilities

*========================================================================================
* Make sure, FoxTools.Fll is loaded.
 Procedure LoadFoxTools
	If Not 'FOXTOOLS.FLL' $ Upper(Set('Library'))
		Set Library To (Home() + 'FoxTools.Fll') Additive
	Endif
Endproc

*========================================================================================
 Procedure SaveDebugger(lcProgram, lnLine1, lnLine0)
	If 'C' # Type('_Screen._ISXInfo')
		_Screen.AddProperty('_ISXInfo', '')
	Endif

	_Screen._ISXInfo = Left(_Screen._ISXInfo, 7000) + Chr[13] + Chr[10]			;
		+ Transform(m.lnLine0) + ' - ' + m.lcProgram + ' ' + Transform(m.lnLine1)

Endproc


*========================================================================================
 Procedure AddDebuggerText(lcTEXT, tlNoNL)
	#If DEBUGGING
		If 'C' # Type('_Screen._ISXInfo')
			_Screen.AddProperty('_ISXInfo', '')
		Endif

		_Screen._ISXInfo = Left(_Screen._ISXInfo, 7000) + Iif(m.tlNoNL, ' ', Chr[13] + Chr[10])	;
			+ m.lcTEXT
	#Endif
Endproc


Define Class DataObjectPlugIn As Custom
	Dimension aPEMs[1]

	Procedure Init(laPEMs)
		Acopy(laPEMs, This.aPEMs)
	Endproc


 	Procedure GetValueFor(lcPropertyName)
 		Local lcValue, lnRow, loException, lxResult
 	
 		lnRow = Ascan(This.aPEMs, m.lcPropertyName, 1, -1, 1, 15)
 		If m.lnRow = 0 Or Alen(This.aPEMs, 2) < 6
 			Return Null
 		Endif
 	
 		lcValue = This.aPEMs[m.lnRow, 6]
 		If DoubleAmps $ m.lcValue
 			lcValue = Left(m.lcValue, At(DoubleAmps, m.lcValue) - 1)
 		Endif
 	
 		If DescriptionDelimiter $ m.lcValue
 			lcValue = Left(m.lcValue, At(DescriptionDelimiter, m.lcValue) - 1)
 		Endif
 	
 		Try
 			lxResult = &lcValue
 		Catch To m.loException
 			lxResult = Null
 		Endtry
 	
 		Return m.lxResult
 	Endproc
 	

 	Procedure GetDescriptionFor(lcPropertyName)
 		Local lcValue, lnRow, lxResult
 	
 		lnRow = Ascan(This.aPEMs, m.lcPropertyName, 1, -1, 1, 15)
 		If m.lnRow = 0 Or Alen(This.aPEMs, 2) < 6
 			Return Null
 		Endif
 	
 		lcValue = This.aPEMs[m.lnRow, 6]
 		If DescriptionDelimiter $ m.lcValue
 			lxResult = Substr(m.lcValue, At(DescriptionDelimiter, m.lcValue) + Len(DescriptionDelimiter)) 
 		Else
 			lxResult = ''
 		Endif
 	
 		Return m.lxResult
 	Endproc
 	
 Enddefine
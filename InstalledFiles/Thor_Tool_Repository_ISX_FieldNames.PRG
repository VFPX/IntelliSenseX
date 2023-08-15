Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype(m.lxParam1)		;
		And 'thorinfo' == Lower(m.lxParam1.Class)

	With m.lxParam1

		* Required
		.Prompt		   = 'IntellisenseX - by hotkey' && used in menus
		.AppID 		   = 'IntellisenseX'

		* Optional
		Text To .Description Noshow && a description for the tool

While this tool isn’t deprecated, its functionality is included in these tools: IntellisenseX by Dot, Dropdown Table Names, and DBC Tables by !
		
Provides the same functionality as its twin tool, IntellisenseX By Dot, except that it is invoked by a hot key that you define. You use the hot key after typing the Dot.

Extensions to Intellisense within code editing windows:
	-- dropdown list of local variables (including those assigned but not added to the LOCAL statement)
	-- names of fields in tables (showing data type, etc):
		- for open tables
		- for SQL tables
		- for data objects which implicitly refer to tables
	-- references to objects between WITH / ENDWITH 
	
Based on ISX.Prg by Christof
		Endtext
		.StatusBarText	 = ''
		.CanRunAtStartup = .F.

		.Category = 'Code|IntellisenseX' && creates categorization of tools; defaults to .Source if empty
		.Sort	  = 98 && the sort order for all items from the same Category

		* For public tools, such as PEM Editor, etc.
		.Author			= 'Christof Wollenhaupt (enhancements for Thor by Jim Nelson)'
		.Link		   = 'https://github.com/VFPX/IntelliSenseX/blob/master/README.md' && link to a page for this tool
		.VideoLink	   = 'https://github.com/VFPX/IntelliSenseX/blob/master/documents/Thor_IntellisenseX_Videos.md'
		.OptionTool		= 'IntellisenseX'
		.OnKeyLabelOnly	= .T.
		.PlugIns 		= 'Open Table, IntellisenseX, Spell Field Names, New Object, Data Objects'
		.OptionClasses	 = 'clsSQLsFirst, clsIncludeMRUs, clsConnectionString, clsSQLRecords, clsDictionaryFileName, clsMethodName, clsNamePosition, clsAliasPosition '
	Endwith

	Return m.lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With m.lxParam1
Endif

Return

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Lparameters lxParam1

	Local lcChar, lcClipText, lcDBC, lcPrevChar, lnPos, lnSelStart, loActiveControl, loEditorWin

	lcClipText = _Cliptext

	If 'O' = Type('_Screen.ActiveForm.ActiveControl') And		;
			Pemstatus(_Screen.ActiveForm.ActiveControl, 'PEME_IntellisenseX', 5)

		m.loActiveControl = _Screen.ActiveForm.ActiveControl
		m.loActiveControl.PEME_IntellisenseX('TABLE,THOR', '', .T.)

	Else
		* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
		m.loEditorWin = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_EditorWin')

		If 0 > m.loEditorWin.FindWindow()
			Return
		Endif

		* current cursor position
		m.lnSelStart = m.loEditorWin.GetSelStart()
		If m.lnSelStart = 0
			m.lcPrevChar = ' '
		Else
			m.lcPrevChar = m.loEditorWin.GetCharacter(m.lnSelStart - 1)
		Endif

		Do Case
			Case Isalpha(m.lcPrevChar) Or Isdigit(m.lcPrevChar) Or m.lcPrevChar = '_' or Empty(m.lcPrevChar)
				IntellisenseXByDot()

			Case m.lcPrevChar = '.'
				RemovePreviousCharacter(m.loEditorWin, m.lnSelStart)
				IntellisenseXByDot()

			Case m.lcPrevChar = '!'
				m.lcDBC = ''
				For m.lnPos = m.lnSelStart - 2 To 0 Step - 1
					m.lcChar = m.loEditorWin.GetCharacter(m.lnPos)
					If Isalpha(m.lcChar) Or Isdigit(m.lcChar)
						m.lcDBC = m.lcChar + m.lcDBC
					Else
						Exit
					Endif
				Endfor && lnPos = lnSelStart - 2 To 0 Skip - 1
				If Empty(m.lcDBC)
					RemovePreviousCharacter(m.loEditorWin, m.lnSelStart)
				Endif
				Execscript(_Screen.cThorDispatcher, 'Thor_Proc_DBCTables', m.lcDBC)

			Case m.lcPrevChar = '*'
				RemovePreviousCharacter(m.loEditorWin, m.lnSelStart)
				Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ListTablesInPath')

			Case m.lcPrevChar = '('
				Execscript(_Screen.cThorDispatcher, 'Thor_Proc_QuickInfo')

			Otherwise
				Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ISX', 'OBJ,TABLE,THOR', '', .T.)
		Endcase

	Endif

	_Cliptext = lcClipText

Endproc


Procedure IntellisenseXByDot
	Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ISX', 'VAR,OBJ,TABLE,THOR', '.')
Endproc


Procedure RemovePreviousCharacter(loEditorWin, lnSelStart)
	m.loEditorWin.Select(m.lnSelStart - 1, m.lnSelStart)
	m.loEditorWin.Cut()
	DoEvents
Endproc





* --------------------------------------------------------------------------------
* --------------------------------------------------------------------------------
#Define		ccContainerName		'clsOpeningTables'

#Undef		ccTool
#Define 	ccTool 				'Opening Tables'

#Define		ccSQLsFirst			'SQLs First'
#Define		ccIncludeMRUs		'Include MRUs'
#Define		ccConnectionString	'Connection String'
#Define		ccNumberofRecords	'Number of SQL records'
#Define		ccDictionaryFile	'Dictionary File Name'

Define Class clsSQLsFirst As Custom

	Tool		  = ccTool 
	Key			  = ccSQLsFirst
	Value		  = .F.
	EditClassName = ccContainerName

Enddefine

Define Class clsIncludeMRUs As Custom

	Tool		  = ccTool 
	Key			  = ccIncludeMRUs
	Value		  = .F.
	EditClassName = ccContainerName

Enddefine

Define Class clsConnectionString As Custom

	Tool		  = ccTool 
	Key			  = ccConnectionString
	Value		  = ''
	EditClassName = ccContainerName

Enddefine

Define Class clsSQLRecords As Custom

	Tool		  = ccTool 
	Key			  = ccNumberofRecords
	Value		  = 0
	EditClassName = ccContainerName

Enddefine

Define Class clsDictionaryFileName As Custom

	Tool		  = ccTool 
	Key			  = ccDictionaryFile
	Value		  = ''
	EditClassName = ccContainerName

EndDefine


****************************************************************
****************************************************************
Define Class clsOpeningTables As Container

	Procedure Init
		Local loRenderEngine
		loRenderEngine = Execscript(_Screen.cThorDispatcher, 'Class= OptionRenderEngine')

		Text To loRenderEngine.cBodyMarkup Noshow Textmerge
		
			.cTool	  = ccTool
			.cKey	  = ccIncludeMRUs
			.Class	  = 'CheckBox'
			.AutoSize = .T.
			.Caption  = 'Include MRUs in search path'
		|
			.cTool	  = ccTool
			.cKey	  = ccSQLsFirst
			.Class	  = 'CheckBox'
			.AutoSize = .T.
			.Caption  = 'Search for SQL tables before VFP tables'
			.Top	  = (.Top - 10)
		|
			.Class	  = 'Label'
			.Caption  = 'SQL connection string'
			.AutoSize = .T.
		|
			.cTool	  = ccTool
			.cKey	  = ccConnectionString
			.Class	  = 'TextBox'
			.Width    = 300
			.Anchor	  = 10
			.Top	  = (.Top - 16)
		|
			.Class	  = 'TestCommandButton'
			.Caption  = 'Test connection string'
			.FontSize = 8
			.Autosize = .T.
			.Anchor	  = 8
			.Left     = 180
			.Top	  = (.Top - 6)
		|
			.Class	  = 'Label'
			.Caption  = 'Number of SQL records'
			.AutoSize = .T.
			.Top	  = (.Top - 26)
		|
			.cTool	  = ccTool
			.cKey	  = ccNumberofRecords
			.Class	  = 'TextBox'
			.Width    = 75
			.InputMask = '999,999'
			.Top	  = (.Top - 16)
		|
			.Class	  = 'Label'
			.Caption  = 'File name of SQL dictionary'
			.AutoSize = .T.
		|
			.Class	  = 'LinkLabel'
			.Caption  = '(See Thor TWEet #12)'
			.Row-Increment = 0
			.ForeColor = (Rgb(0,0,255))
			.FontUnderLine = .T.
			.Left = (.Left + 10)	
			.Fontsize = (.FontSize - 1)
			.Autosize = .T.		
		|
			.cTool	  = ccTool
			.cKey	  = ccDictionaryFile
			.Class	  = 'TextBox'
			.Width    = 300
			.Anchor	  = 10
			.Top	  = (.Top - 16)
		Endtext

		loRenderEngine.nControlLeft = 20
		loRenderEngine.Render(This, ccTool)

	Endproc

Enddefine

Define Class TestCommandButton as CommandButton

	Procedure Click
		ExecScript(_Screen.cThorDispatcher, 'Thor_Proc_TestConnectionString')	
	Endproc
		
Enddefine


* --------------------------------------------------------------------------------
* --------------------------------------------------------------------------------
#Undef		ccContainerName
#Define		ccContainerName		'clsTablesAliases'

#Undef		ccTool
#Define 	ccTool 				'Table Aliases'

#Define		ccMethodName		'Table Aliases Method Name'
#Define		ccFileNamePosition	'Table Aliases Name Position'
#Define		ccAliasPosition		'Table Aliases Alias Position'

Define Class clsMethodName As Custom

	Tool		  = ccTool 
	Key			  = ccMethodName
	Value		  = ''
	EditClassName = ccContainerName

Enddefine

Define Class clsNamePosition As Custom

	Tool		  = ccTool 
	Key			  = ccFileNamePosition
	Value		  = 1
	EditClassName = ccContainerName

Enddefine

Define Class clsAliasPosition As Custom

	Tool		  = ccTool 
	Key			  = ccAliasPosition
	Value		  = 2
	EditClassName = ccContainerName

Enddefine


****************************************************************
****************************************************************
Define Class clsTablesAliases As Container

	Procedure Init
		Local loRenderEngine
		loRenderEngine = Execscript(_Screen.cThorDispatcher, 'Class= OptionRenderEngine')

		Text To loRenderEngine.cBodyMarkup Noshow Textmerge
		
		|
			.Class	  = 'Label'
			.Caption  = 'Procedure name for opening tables'
			.AutoSize = .T.
		|
			.cTool	  = ccTool
			.cKey	  = ccMethodName
			.Class	  = 'TextBox'
			.Width    = 200
			.Top	  = (.Top - 16)
		|
			.Class	  = 'Label'
			.Caption  = 'Parameter number for name of table'
			.AutoSize = .T.
		|
			.cTool	  = ccTool
			.cKey	  = ccFileNamePosition
			.Class	  = 'TextBox'
			.InputMask = 999
			.Width	  = 60
			.Top	  = (.Top - 16)
		|
			.Class	  = 'Label'
			.Caption  = 'Parameter number for alias'
			.AutoSize = .T.
		|
			.cTool	  = ccTool
			.cKey	  = ccAliasPosition
			.Class	  = 'TextBox'
			.InputMask = 999
			.Width	  = 60
			.Top	  = (.Top - 16)
		|
			.Class	  = 'Label'
			.Caption  = 'Other alternatives for defining aliases:'
			.Fontbold = .T.
			.AutoSize = .T.
		|
			.Class	  = 'Label'
			.Name	  = 'Comment1'
			.AutoSize = .T.
			.Top	  = (.Top - 10)
		|
			.Class	  = 'Label'
			.Name	  = 'Comment2'
			.AutoSize = .T.
			.Top	  = (.Top - 10)
		Endtext

		loRenderEngine.nControlLeft = 20
		loRenderEngine.Render(This, ccTool)

		This.Comment1.Caption  = '    *#Alias SomeAlias = Table    ... at beginning of line'
		This.Comment2.Caption  = '    &' + '&#Alias SomeAlias = Table    ... as comment'

	Endproc

Enddefine


Define Class LinkLabel as Label

	Procedure Click
		Execscript (_Screen.cThorDispatcher, 'Thor_Proc_Shell', 'https://vfpx.codeplex.com/wikipage?title=Thor%20TWEeT%2010')		
	EndProc 
	
EndDefine

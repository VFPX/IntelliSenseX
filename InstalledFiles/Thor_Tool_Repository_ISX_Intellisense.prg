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
		.Prompt		   = 'Dropdown Intellisense Command Expansions' && used in menus
		.AppID 		   = 'IntellisenseX'

		* Optional
		Text To .Description Noshow && a description for the tool
Dropdown list of native Intellisense Command Expansions

Based on ISX.Prg by Christof
		Endtext
		.StatusBarText	 = ''
		.CanRunAtStartUp = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category = 'Code|IntellisenseX' && creates categorization of tools; defaults to .Source if empty
		.Sort	  = 40 && the sort order for all items from the same Category
		
		.Link	   = 'https://github.com/VFPX/IntelliSenseX/blob/master/documents/Tool_Dropdown_Macros.md'
		.OptionTool		= 'IntellisenseX'


		* For public tools, such as PEM Editor, etc.
		.OnKeyLabelOnly	= .T.

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

	loList = GetScripts()
	If 'C' = Type('loList.aList[1]')
		Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ISX', 'VAR', '', .T., m.loList, .T., Newobject('ExpandIntellisense'))
	Endif

Endproc


Procedure GetScripts

	Local lcAlias, loException, loList

	lcAlias = 'Foxcode' + Sys(2015)
	Try
		Use (_Foxcode) In 0 Shared Again Alias (m.lcAlias)
	Catch To m.loException

	Endtry
	If Used(m.lcAlias)
		loList = Createobject('Empty')
		AddProperty(m.loList, 'alist[1]')
		Select  Abbrev,					;
				Expanded				;
			From (m.lcAlias)			;
			Where Type = 'U'			;
				And Not Deleted()		;
			Order By 1					;
			Into Array loList.aList
		Use In (m.lcAlias)
	Endif

	Return m.loList

Endproc


Define Class ExpandIntellisense As Custom

	Procedure Expand(lcText)
		* editorwin home page = http://vfpx.codeplex.com/wikipage?title=thor%20editorwindow%20object
		Local lnWindowType, loEditorWin
		loEditorWin	 = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_EditorWin')
		lnWindowType = m.loEditorWin.FindWindow()

		Return Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetIntellisenseScript', m.lcText, m.lnWindowType)
	Endproc

Enddefine

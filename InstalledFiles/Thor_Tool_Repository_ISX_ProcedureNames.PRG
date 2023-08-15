Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1								;
		And 'O' = Vartype(lxParam1)			;
		And 'thorinfo' == Lower(lxParam1.Class)

	With lxParam1

		* Required
		.Prompt		   = 'Dropdown Procedures List' && used in menus
		.AppID 		   = 'IntellisenseX'

		* Optional
		Text To .Description Noshow && a description for the tool
Intellisense dropdown list of procedures and methods in all PRGs

Based on ISX.Prg by Christof
		Endtext
		.StatusBarText = ''
		.CanRunAtStartup = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category = 'Code|IntellisenseX' && creates categorization of tools; defaults to .Source if empty
		.Sort	  = 40 && the sort order for all items from the same Category

		* For public tools, such as PEM Editor, etc.
		.Author			= 'Christof Wollenhaupt (enhancements for Thor by Jim Nelson)'
		.Link	   = 'https://github.com/VFPX/IntelliSenseX/blob/master/documents/Tool_Dropdown_Procedures.md'
		.OptionTool = 'IntellisenseX'
		.OnKeyLabelOnly	= .T.

	Endwith

	Return lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With lxParam1
Endif

Return

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Lparameters lxParam1

	Local loList
	loList = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetAllProcedureNames')

	If 'C' = Type('loList.aList[1]')	
		Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ISX', 'VAR', '', .T., loList, .T.)
	Endif

Endproc

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
		.Prompt		   = 'Dropdown Variables List' && used in menus
		.AppID 		   = 'IntellisenseX'

		* Optional
		Text To .Description Noshow && a description for the tool

While this tool isn’t deprecated, its functionality is included in AutoComplete

Intellisense dropdown list of local variables (including those assigned but not added to the LOCAL statement)

Based on ISX.Prg by Christof
		Endtext
		.StatusBarText = ''
		.CanRunAtStartup = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category = 'Code|IntellisenseX' && creates categorization of tools; defaults to .Source if empty
		.Sort	  = 99 && the sort order for all items from the same Category

		* For public tools, such as PEM Editor, etc.
		.Author	   = 'Christof Wollenhaupt (enhancements for Thor by Jim Nelson)'
		.Link	   = 'http://vfpx.codeplex.com/wikipage?title=Thor%20IntellisenseX' && link to a page for this tool
		.VideoLink = 'http://vfpx.codeplex.com/wikipage?title=Thor%20IntellisenseX#Videos'
		.OptionTool = 'IntellisenseX'
		.OnKeyLabelOnly = .T.

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

	Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ISX', 'VAR', '', .T.) 

Endproc

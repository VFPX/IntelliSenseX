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
		.Prompt		   = 'Browse Custom Keyword List' && used in menus
		.AppID 		   = 'IntellisenseX'

		* Optional
		Text To .Description Noshow && a description for the tool
Browse your custom list of keywords, used to provide a standard list mixed case names for properties, methods, and field names.
		
Based on ISX.Prg by Christof
		Endtext
		.StatusBarText	 = ''
		.CanRunAtStartup = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category = 'Code|Custom Keyword List' && creates categorization of tools; defaults to .Source if empty
		.Sort	  = 20 && the sort order for all items from the same Category
		.Link	  = 'https://vfpx.codeplex.com/wikipage?title=Custom%20Keyword%20Lists'

		* For public tools, such as PEM Editor, etc.
		.Author	   = 'Jim Nelson'

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

	GetISXOptions()
	_Screen.oISXOptions.oKeywordList.BrowseKeywordList()

Endproc


Procedure GetISXOptions
	Return Execscript (_Screen.cThorDispatcher, 'Thor_Proc_GetISXOptions')
EndProc

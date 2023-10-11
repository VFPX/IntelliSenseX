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
		.Prompt		   = 'Browse Alias Dictionary' && used in menus
		.AppID 		   = 'IntellisenseX'

		* Optional
		Text To .Description Noshow && a description for the tool
Browse your custom list of Table Aliases (aliases recognized by IntellisenseX)
		
Based on ISX.Prg by Christof
		Endtext
		.StatusBarText	 = ''
		.CanRunAtStartup = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category = 'Code|IntellisenseX|Alias Dictionary' && creates categorization of tools; defaults to .Source if empty
		.Sort	  = 20 && the sort order for all items from the same Category
		.Link	  = 'https://github.com/VFPX/Thor/blob/master/Docs/NewsItems/Item_47.md'

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

	#Define TABLEALIAS 'Thor_TableAliases'
	Local lcToolFolder
	If Not Used(TABLEALIAS)
		lcToolFolder  = Execscript(_Screen.cThorDispatcher, 'Tool Folder=')
		Use Addbs(lcToolFolder) + '..\Tables\TableAliases' In 0 Alias (TABLEALIAS) Order alias Again Shared
	EndIf
	Goto top in TABLEALIAS
	Execscript(_Screen.cThorDispatcher, 'Thor_Proc_SuperBrowse', TABLEALIAS)
Endproc

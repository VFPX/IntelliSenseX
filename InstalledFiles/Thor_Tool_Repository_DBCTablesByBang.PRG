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
		.Prompt		   = 'DBC Tables by !' && used in menus
		.AppID 		   = 'IntellisenseX'

		* Optional
		Text To .Description Noshow && a description for the tool
Assigns hot key ! so that typing in the name of a database followed by ! gives a popup of the names of the tables and views in the database.
		
Based on ISX.Prg by Christof
		Endtext
		.StatusBarText = ''
		.CanRunAtStartup = .T.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category = 'Code|IntellisenseX' && creates categorization of tools; defaults to .Source if empty
		.Sort	  = 60 && the sort order for all items from the same Category

		* For public tools, such as PEM Editor, etc.
		.Author	   = 'Christof Wollenhaupt (enhancements for Thor by Jim Nelson and Eduard Alexandru)'

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

	Local lcPRG
	If Empty(On('key', '!')) or lxParam1
		lcPRG = Execscript(_Screen.cThorDispatcher, 'Full Path=Thor_Proc_ISX')
		On Key Label ! Do [&lcPRG] With 'DBC', '!'
		Wait Window nowait "DBC Field names by ! -  up and running..." 
	Else
		On Key Label !
		Wait Window nowait "DBC Field names by ! - terminated..." 
	Endif

Endproc

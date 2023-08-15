Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1						  ;
		And 'O' = Vartype (lxParam1)  ;
		And 'thorinfo' == Lower (lxParam1.Class)

	With lxParam1
	
		* Required
		.Prompt		   = 'Dropdown Table Names' && used in menus
		.AppID 		   = 'IntellisenseX'
		
		Text to .Description NoShow 
Dropdown list of all tables in the current path
		EndText 
		.StatusBarText	 = ''
		.CanRunAtStartup = .F.

		.Category = 'Code|IntellisenseX' && creates categorization of tools; defaults to .Source if empty
		.Sort	  = 50 && the sort order for all items from the same Category

		* For public tools, such as PEM Editor, etc.
		.Author			= 'Christof Wollenhaupt (enhancements for Thor by Jim Nelson)'
		.Link	   = 'https://github.com/VFPX/IntelliSenseX/blob/master/documents/Tool_Dropdown_Tables.md'
		.OptionTool		= 'IntellisenseX'
		.OnKeyLabelOnly	= .T.

		.PlugInClasses   = 'clsListTablesPlugIn'
		.PlugIns		 = 'List Tables'
				
	Endwith

	Return lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With lxParam1
Endif

Return

#Define ccTab  	Chr(9)
#Define ccLF	Chr(10)
#Define ccCR	Chr(13)
#Define ccCRLF	Chr(13) + Chr(10)

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Lparameters lxParam1
		Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ListTablesInPath')
EndProc 


****************************************************************
****************************************************************

Define Class clsListTablesPlugIn As Custom

	Source				= 'Dropdown Table Names'
	PlugIn				= 'List Tables'
	Description			= 'Returns the list of tables shown in "Dropdown Table Names"'
	Tools				= 'Dropdown Table Names'
	FileNames			= 'Thor_Proc_ListTablesInPath.PRG'
	DefaultFileName		= '*Thor_Proc_ListTablesInPath.PRG'
	DefaultFileContents	= ''
EndDefine 


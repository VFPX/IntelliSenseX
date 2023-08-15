#Define  	ccXToolName		'AutoComplete'


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
		.Prompt		   = ccXToolName && used in menus
		.AppID 		   = 'IntellisenseX'

		* Optional
		Text To .Description Noshow && a description for the tool
Produces a dropdown list of all names referenced in the current procedure.

This is similar in concept to the autocomplete features in modern text editors, except that it must be consciously invoked (presumably by hot key) rather than occuring automatically

The list of names includes all parameter names, local variables, global variables, names of functions, procedures, tables, aliases, fields, objects and properties -- all "words" referenced in the current procedure that are not VFP keywords.

There are a number of options available, including the ability to modify the list of keywords that are excluded.

There is also a plug-in available that allows you to change the display order of the list.

Based on a suggestion from Matt Slay.
		Endtext
		.StatusBarText = ''
		.CanRunAtStartup = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category = 'Code|IntellisenseX' && creates categorization of tools; defaults to .Source if empty
		.Sort	  = 20 && the sort order for all items from the same Category

		* For public tools, such as PEM Editor, etc.
		.Author	   = 'Christof Wollenhaupt (enhancements for Thor by Jim Nelson)'
		.Link	   = 'https://github.com/VFPX/IntelliSenseX/blob/master/documents/Tool_Dropdown_Names.md'
		.OptionTool	   = ccXToolName
		.OptionClasses = 'clsCaseSensitive, clsExcludeKeywords, clsWordList, clsCase, clsAllPRGProcedures'

		.PlugInClasses = 'clsISXPlugIn'
		.PlugIns 		= 'SortAutoComplete'

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

	Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ISX', 'ALLNAMES', '', .T., .F., .T.) 

Endproc


****************************************************************
****************************************************************

Define Class clsCaseSensitive As Custom

	Tool		  = ccXToolName
	Key			  = 'Case-sensitive sort'
	Value		  = .F.
	EditClassName = 'clsAllNames of Thor_Options_ISX.VCX'

Enddefine


Define Class clsExcludeKeywords As Custom

	Tool		  = ccXToolName
	Key			  = 'Exclude VFP Keywords'
	Value		  = .T.
	EditClassName = 'clsAllNames of Thor_Options_ISX.VCX'

Enddefine


Define Class clsAllPRGProcedures As Custom

	Tool		  = ccXToolName
	Key			  = 'All Procedures in PRGS'
	Value		  = .F.
	EditClassName = 'clsAllNames of Thor_Options_ISX.VCX'

Enddefine


Define Class clsWordList As Custom

	Tool		  = ccXToolName
	Key			  = 'Excluded Words'
	Value		  = 'ID Completed +B +C +D +I +M +N +T'
	EditClassName = 'clsAllNames of Thor_Options_ISX.VCX'

Enddefine


Define Class clsCase As Custom

	Tool		  = ccXToolName
	Key			  = 'Capitalization'
	Value		  = 4
	EditClassName = 'clsAllNames of Thor_Options_ISX.VCX'

Enddefine


****************************************************************
****************************************************************

Define Class clsISXPlugIn As Custom

	Source				= 'ISX'
	PlugIn				= 'SortAutoComplete'
	Description			= 'Allows for modification of the drop down list from AutoComplete'
	Tools				= ccXToolName
	FileNames			= 'Thor_Proc_SortAutoComplete.PRG'
	DefaultFileName		= '*Thor_Proc_SortAutoComplete.PRG'
	DefaultFileContents	= ''

	Procedure Init
		****************************************************************
		****************************************************************
		Text To This.DefaultFileContents Noshow
Lparameters laNameList
* A two column array, passed by reference so it can be directly modified
*  [,1] = Name
*  [,2] = Type (Local, Parameter, etc.)

* This example does two things:
*  (1) changes the sort order to put all assigned variables at the top
*        and local variables at the bottom
*  (2) modifies the second column in some instances based on leading
*        characters of the name

* There is also some code (commented out) that reads a customized dictionary
*   containing the list of all tables; second column is so marked when
*   one of these is encountered.

Local laTemp[1], lcCol1, lcCol2, lcCol3, lnI, lnRows
Local col2

lnRows = Alen(laNameList, 1)
Dimension laTemp(lnRows, 3)

*!* * Removed 3/4/2013 / JRN
*!* If 'C' # Type('_Screen.aTablelist')
*!* 	Usetable('TablesList')
*!* 	_Screen.AddProperty('aTableList[1]')
*!* 	Select Alias From TablesList Order By Alias Into Array _Screen.aTablelist
*!* 	Use In TablesList
*!* Endif

For lnI = 1 To lnRows
	lcCol1 = laNameList[lnI, 1]
	lcCol2 = laNameList[lnI, 2]

	Do Case
		Case 'assign' $ Lower(lcCol2)
			lcCol3 = '1'
		Case Empty(lcCol2)
			lcCol3 = '2'
			Do Case
				Case lcCol1 = 'crsr_'
					lcCol2 = 'Cursor'
				Case lcCol1 = 'ca'
					lcCol2 = 'Cursor'
				*!* * Removed 3/4/2013 / JRN
				*!* Case 0 # Ascan(_Screen.aTablelist, Padr(lcCol1, 50), 1, -1, 1, 7)
				*!* 	lcCol2 = 'Table'
				Otherwise
					lcCol3 = '3'
			Endcase
		Case 'param' $ Lower(lcCol2)
			lcCol3 = '4'
		Case 'local' $ Lower(lcCol2)
			lcCol3 = '6'
		Otherwise
			lcCol3 = '5'
	Endcase
	laTemp[lnI, 1] = lcCol1
	laTemp[lnI, 2] = lcCol2
	laTemp[lnI, 3] = lcCol3 + lcCol1
Endfor && lnI = 1 to lnRows

Asort(laTemp, 3, -1, 0, 1)

For lnI = 1 To lnRows
	laNameList[lnI, 1] = laTemp[lnI, 1]
	laNameList[lnI, 2] = laTemp[lnI, 2]
Endfor

		Endtext
		****************************************************************
		****************************************************************
	Endproc

Enddefine



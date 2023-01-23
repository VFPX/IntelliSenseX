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
		.Prompt		   = 'Dropdown Reports in Active Project'

		* Optional
		Text To .Description Noshow && a description for the tool
Dropdown list of all reports in the Active Project

Based on ISX.Prg by Christof
		Endtext
		.StatusBarText	 = ''
		.CanRunAtStartUp = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category = 'Code|IntellisenseX' && creates categorization of tools; defaults to .Source if empty
		.Sort	  = 40 && the sort order for all items from the same Category

		* For public tools, such as PEM Editor, etc.
		.Author			= 'Christof Wollenhaupt (enhancements for Thor by Jim Nelson)'
		.Link			= 'http://vfpx.codeplex.com/wikipage?title=Thor%20IntellisenseX' && link to a page for this tool
		.VideoLink		= 'http://vfpx.codeplex.com/wikipage?title=Thor%20IntellisenseX#Videos'
		.OptionTool		= 'IntellisenseX'
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

	Local laList[1], lcAlias, lcPJX

	If _vfp.Projects.Count = 0
		Return
	Endif

	lcPJX	= _vfp.ActiveProject.Name
	lcAlias	= Sys(2015)
	Use (m.lcPJX) Again In 0 Shared Alias (m.lcAlias)

	Select  Padr(Cleanse(Name), 80)			;
		From (m.lcAlias)					;
		Where Type = 'R'					;
			And Not Deleted()				;
		Into Array laList

	Use In (m.lcAlias)

	Execscript (_Screen.cThorDispatcher, 'Thor_Proc_DropDown', @m.laList)

Endproc


Procedure Cleanse(lcFormName)
	Local lcResult
	lcResult = Trim(m.lcFormName)
	lcResult = Strtran(m.lcResult,	'..\common\', 		'')
	lcResult = Strtran(m.lcResult, 	'..\commonapps\', 	'')
	lcResult = Strtran(m.lcResult, 	'.scx', 			'')
	lcResult = Strtran(m.lcResult,	Chr(0), 			'')
	If ' ' $ m.lcResult
		lcResult = '"' + m.lcResult + '"'
	Endif
	Return m.lcResult
Endproc


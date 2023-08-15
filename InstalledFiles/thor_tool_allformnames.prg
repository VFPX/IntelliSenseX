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
		.Prompt		   = 'Dropdown Form Names in Active Project'
		.AppID 		   = 'IntellisenseX'

		* Optional
		Text To .Description Noshow && a description for the tool
Dropdown list of all Form Names in the Active Project

Based on ISX.Prg by Christof
		Endtext
		.StatusBarText	 = ''
		.CanRunAtStartUp = .F.

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category = 'Code|IntellisenseX' && creates categorization of tools; defaults to .Source if empty
		.Sort	  = 40 && the sort order for all items from the same Category

		* For public tools, such as PEM Editor, etc.
		.Author			= 'Christof Wollenhaupt (enhancements for Thor by Jim Nelson)'
		.Link	   = 'https://github.com/VFPX/IntelliSenseX/blob/master/documents/Tool_Dropdown_Forms.md'
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
		Where Type = 'K'					;
			And Not Deleted()				;
		Into Array laList

	Use In (m.lcAlias)

	Execscript (_Screen.cThorDispatcher, 'Thor_Proc_DropDown', @m.laList)

Endproc


Procedure Cleanse(lcFormName)
	Local lcResult
	lcResult = JustStem(trim(m.lcFormName))
	If ' ' $ m.lcResult
		lcResult = '"' + m.lcResult + '"'
	Endif
	Return m.lcResult
Endproc


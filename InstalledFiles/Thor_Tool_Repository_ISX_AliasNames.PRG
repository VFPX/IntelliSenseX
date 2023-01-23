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
		.Prompt		   = 'Dropdown Alias List' && used in menus

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
		.Link	   = 'http://vfpx.codeplex.com/wikipage?title=Thor%20IntellisenseX' && link to a page for this tool
		.VideoLink = 'http://vfpx.codeplex.com/wikipage?title=Thor%20IntellisenseX#Videos'
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

Local laList[1], laUsed[1], lcAlias, lcExt, lnCount, lnI, loFixCase

	lnCount = Aused(laUsed)

	If m.lnCount > 0
		Dimension m.laList[m.lnCount, 2]

		Execscript (_Screen.cThorDispatcher, 'Thor_Proc_GetISXOptions')
		loFixCase = _Screen.oISXOptions.oKeyWordList

		For lnI = 1 To m.lnCount
			lcAlias			 = m.laUsed[m.lnI, 1]
			laList[m.lnI, 1] = Evl(m.loFixCase.FixCase(m.lcAlias, .T.), m.lcAlias)
			lcExt = Upper(JustExt(Dbf(m.lcAlias)))
			laList[m.lnI, 2] = Icase(lcExt = 'DBF', 'Table', lcExt = 'PJX', 'Project (as Table)', 'Cursor')
		Endfor

		Execscript (_Screen.cThorDispatcher, 'Thor_Proc_DropDown', @m.laList)
	Endif

Endproc
 
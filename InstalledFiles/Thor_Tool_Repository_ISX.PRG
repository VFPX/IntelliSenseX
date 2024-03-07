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
		.Prompt		   = 'IntellisenseX - by dot' && used in menus
		.AppID 		   = 'IntellisenseX'

		* Optional
		Text To .Description Noshow && a description for the tool
Extensions to Intellisense within code editing windows:
	-- dropdown list of local variables (including those assigned but not added to the LOCAL statement)
	-- names of fields in tables (showing data type, etc):
		- for open tables
		- for SQL tables
		- for data objects which implicitly refer to tables
	-- references to objects between WITH / ENDWITH 

Based on ISX.Prg by Christof
		Endtext
		.StatusBarText = ''

		* These are used to group and sort tools when they are displayed in menus or the Thor form
		.Category = 'Code|IntellisenseX' && creates categorization of tools; defaults to .Source if empty
		.Sort	  = 10 && the sort order for all items from the same Category

		* For public tools, such as PEM Editor, etc.
		.Author		   = 'Christof Wollenhaupt (enhancements for Thor by Jim Nelson)'
		.Sort	  	   = 10
		.Link		   = 'https://github.com/VFPX/IntelliSenseX/blob/master/README.md' && link to a page for this tool
		.VideoLink	   = 'https://github.com/VFPX/IntelliSenseX/blob/master/documents/Thor_IntellisenseX_Videos.md'
		.OptionTool	   = 'IntellisenseX'
		.OptionClasses = 'clsAlphaSort, clsShowFieldDefs, clsFontName, clsFontSize, clsDisplayCount, clsFieldNamesCase, clsFiltering, clsDebuggerOpen, clsFilterType, clsFilterToggle, clsSelectIfOne, clsPRGBasedClasses, clsOverrideThisform, clsCKL'
		.PlugIns 		= 'Open Table, IntellisenseX, Spell Field Names, New Object, Data Objects'
		.PlugInClasses   = 'clsISXPlugIn, clsISXNewObject, clsISXDataObject'
		
		.ForumName = 'IntellisenseX'
		.ForumLink = 'https://github.com/VFPX/IntellisenseX/issues'
		
		.MenuMarkExpression = [Not Empty(On('key', '.'))]
		
	Endwith

	Return lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With lxParam1
Endif

Return


#Define	ccStarting 	'IntellisenseX up and running...'
#Define ccEnding 	'IntellisenseX terminated...'

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
	Lparameters lxParam1

	#Define cTool 'IntellisenseX'
	#Define cKey  'DebuggerOpen'
	Local lcOnKeyDot, lcPRG

	_Screen.AddProperty('lThorDebuggerOpen', Execscript(_Screen.cThorDispatcher, 'Get Option=', cKey, cTool))

	If _Screen.lThorDebuggerOpen && oddly named property, it means "close ISX when debugger is opened"
		If Execscript(_Screen.cThorDispatcher, 'THOR_PROC_IntellisenseXTimer', 'Toggle')
			Wait Window Nowait ccStarting + ' (using timer)' at 10, 25
		Else
			Wait Window Nowait ccEnding at 10, 25
		Endif
	Else
		lcOnKeyDot	 = On('Key', '.')
		If Empty(m.lcOnKeyDot)
			lcPRG = Execscript(_Screen.cThorDispatcher, 'Full Path=Thor_Proc_ISX')
			On Key Label . Do [&lcPRG] With 'VAR,OBJ,TABLE,THOR', '.'
			Wait Window Nowait ccStarting at 10, 25
		Else
			On Key Label .
			Wait Window Nowait ccEnding at 10, 25
		Endif
	Endif

	ExecScript(_Screen.cThorDispatcher, 'THOR_PROC_FixThorMenuMarks')
		
Endproc

****************************************************************
****************************************************************

Define Class clsAlphaSort As Custom

	Tool		  = 'IntellisenseX'
	Key			  = 'Alpha Sort'
	Value		  = .T.
	EditClassName = 'clsISX of Thor_Options_ISX.VCX'

Enddefine


Define Class clsShowFieldDefs As Custom

	Tool		  = 'IntellisenseX'
	Key			  = 'Show Fields Defs'
	Value		  = .T.
	EditClassName = 'clsISX of Thor_Options_ISX.VCX'

Enddefine


Define Class clsFontName As Custom

	Tool		  = 'IntellisenseX'
	Key			  = 'Font Name'
	Value		  = 'Tahoma'
	EditClassName = 'clsISX of Thor_Options_ISX.VCX'

Enddefine


Define Class clsFontSize As Custom

	Tool		  = 'IntellisenseX'
	Key			  = 'Font Size'
	Value		  = 8
	EditClassName = 'clsISX of Thor_Options_ISX.VCX'

Enddefine


Define Class clsDisplayCount As Custom

	Tool		  = 'IntellisenseX'
	Key			  = 'Display Count'
	Value		  = 15
	EditClassName = 'clsISX of Thor_Options_ISX.VCX'

Enddefine


Define Class clsFieldNamesCase As Custom

	Tool		  = 'IntellisenseX'
	Key			  = 'FieldNames Case'
	Value		  = 1
	EditClassName = 'clsISX of Thor_Options_ISX.VCX'

Enddefine


Define Class clsFiltering As Custom

	Tool		  = 'IntellisenseX'
	Key			  = 'Filtering'
	Value		  = .T.
	EditClassName = 'clsISX of Thor_Options_ISX.VCX'

Enddefine


Define Class clsDebuggerOpen As Custom

	Tool		  = 'IntellisenseX'
	Key			  = 'DebuggerOpen'
	Value		  = .F.
	EditClassName = 'clsISX of Thor_Options_ISX.VCX'

Enddefine


Define Class clsFilterType As Custom

	Tool		  = 'IntellisenseX'
	Key			  = 'FilterType'
	Value		  = 1
	EditClassName = 'clsISX of Thor_Options_ISX.VCX'

Enddefine


Define Class clsFilterToggle As Custom

	Tool		  = 'IntellisenseX'
	Key			  = 'FilterToggle'
	Value		  = '@'
	EditClassName = 'clsISX of Thor_Options_ISX.VCX'

Enddefine


Define Class clsSelectIfOne As Custom

	Tool		  = 'IntellisenseX'
	Key			  = 'SelectIfOne'
	Value		  = .F.
	EditClassName = 'clsISX of Thor_Options_ISX.VCX'

Enddefine


Define Class clsPRGBasedClasses As Custom

	Tool		  = 'IntellisenseX'
	Key			  = 'PRGBasedClasses'
	Value		  = 1
	EditClassName = 'clsISX of Thor_Options_ISX.VCX'

Enddefine


Define Class clsOverrideThisform As Custom

	Tool		  = 'IntellisenseX'
	Key			  = 'OverrideThisform'
	Value		  = 1
	EditClassName = 'clsISX of Thor_Options_ISX.VCX'

Enddefine


Define Class clsCKL As Custom

	Tool		  = 'IntellisenseX'
	Key			  = 'UseCKLforPEMs'
	Value		  = .F.
	EditClassName = 'clsISX of Thor_Options_ISX.VCX'

Enddefine


****************************************************************
****************************************************************

Define Class clsISXPlugIn As Custom

	Source				= 'ISX'
	PlugIn				= 'IntellisenseX'
	Description			= 'Called to provide dropdown lists for strings that cannot otherwise be resolved into objects, such as  Thisform.oBusObj.oData'
	Tools				= 'IntellisenseX and editing ControlSource in PEM Editor'
	FileNames			= 'Thor_Proc_GetTableFromObject.PRG'
	DefaultFileName		= '*Thor_Proc_GetTableFromObject.PRG'
	DefaultFileContents	= ''

	Procedure Init
		****************************************************************
		****************************************************************
		Text To This.DefaultFileContents Noshow
* This procedure analyzes the name entered to see if it looks
* like a name that would contain fields (such as This.oData
* from West Wind) and returns a result with field or property
* names to populate the listbox in IntellisenseX

* Local variables extracted from the parameter toParameters
* 	lcEntityName	= the full name preceding the just-entered DOT
* 	lcName       	= the text following the just-entered dot
*   					(non-empty only for IntellisenseX by hot key)
*   lcTextLeft      = full text of the line to the left of the entity name
*   loForm			= the form or class being edited (but not the current
*   					object in that form or class ... this is the top 
*						level object)
*	llForceit       = .T. if called by Intellisense by hot key

* This sample looks for two alternatives:
*   (1) If the name is a table name for an SQL table. Definitions
*       for these tables are contained in a free table, but could
*       just as well use SQLColumns()
*   (2) Looks for a property in the form/class being edited
*       that contains the implicit name of a table from
*       which fields are to be selected.

* Result may be any of:
*   .null. or logical -- no match found

*   An Object with a two dimensional array named aList:
*           aList[, 1] = Display Text (first column)
*           aList[, 2] = Second Column
*           aList[, 3] = Filter text
*           aList[, 4] = Icon file name

*   Character         -- alias for table from which fields are to be listed

*   Collection        -- collection of simple character data, each item to
*                        be displayed as a separate row. A single tab character
*                        may be used to create a two column display.

*   An Object         -- all properties, methods, and objects in the object 
*						 are displayed

* Note that the result MUST be passed with this peculiar construction,
* 	required because of the way Plug-Ins interact with their calling PRG:
* Return Execscript(_Screen.cThorDispatcher, 'Result=', lcAlias)

Lparameters toParameters

Local lcAlias, lcEntityName, lcName, lcTextLeft, llForceit, loForm, lxResult

With toParameters

	* the full name preceding the just-entered DOT
	lcEntityName  = Lower(.cEntityName)

	* the text following the just-entered dot
	*   non-empty only for IntellisenseX by hot key
	lcName       = .cName

	* text to the left of the entity name
	lcTextLeft    = .cTextLeft

	*  the form or class being edited (but not the current
	*   object in that form or class ... this is the top level object)
	loForm	      = .oTopOfForm

	* .T. if called by Intellisense by hot key
	llForceit     = .lForceIt

Endwith

*******************************************************************************
***  End of setup section
*******************************************************************************

	lxResult = GetSQLStructure(lcEntityName)
	If Vartype(lxResult) = 'O'
		Return Execscript(_Screen.cThorDispatcher, 'Result=', lxResult)
	Endif

#Define PROPERTYNAME 'cAlias'
#Define ccTab Chr[9]

Do Case
	Case Vartype(loForm) # 'O'
		lcAlias = .F.

	Case lcEntityName == 'thisform.obusobj.odata'
		lcAlias = GetTableAlias(loForm, PROPERTYNAME, .T.)

	Case lcEntityName == 'this.odata'
		lcAlias = GetTableAlias(loForm, PROPERTYNAME)

	Otherwise
		lcAlias = .F.

Endcase

Return Execscript(_Screen.cThorDispatcher, 'Result=', lcAlias)



Procedure GetTableAlias(loForm, tcPropertyName, tlCurrentAlias)
	* If property <tcPropertyName> exists in object <loForm>, 
	* calls plug-in <PEME_OpenTable> to select or open the table
	* with that alias.

	* If this does not result in the desired table, and if
	* <tlCurrentAlias> is .T., tries to use the current table

	Local lcAlias

	If Pemstatus(loForm, tcPropertyName, 5) And Vartype(loForm.&tcPropertyName) = 'C'
		lcAlias = loForm.&tcPropertyName
		If Empty(lcAlias) And Lower(loForm.Name) = 'bo_'
			lcAlias = OpenMyTable(Substr(loForm.Name, 4))
		Endif
		lcAlias = OpenMyTable(lcAlias)
	Else
		lcAlias = .F.
	Endif

	If Empty(lcAlias) And tlCurrentAlias And Not Empty(Alias())
		lcAlias = Alias()
	Endif

	Return lcAlias

Endproc


Procedure OpenMyTable(tcAlias)
	If Empty(tcAlias) Or '.' $ tcAlias
		Return ''
	Else
		Return Execscript(_Screen.cThorDispatcher, 'PEME_OpenTable', tcAlias)
	Endif
Endproc


Procedure GetSQLStructure(lcEntityName)
	* Sample Procedure that gets the structure for an SQL table

	* The result is a collection, each element containing the field name,
	* then a tab, then the data type and width

	* This procedure uses a dictionary in a local table. It could just
	* as well use SQLColumns to read the structure directly.

	#Define DictionaryTableName 'C:\VISUAL FOXPRO\DATA\KONG\DATADICTIONARY.DBF'
	#Define Table_FieldName     Xtabname
	#Define Field_FieldName		field_name
	#Define Type_FieldName		Field_Type
	#Define Length_FieldName	Field_Len
	#Define Decimals_FieldName	Field_Dec

	Local lxResult As 'Collection'
	Local laFields[1], laList[1], lcTableName, lnSelect

	lxResult = .F.
	If '.' $ lcEntityName
		Return lxResult
	EndIf 

	* Assumes beginning of table name is 'SQL_'
	If Upper(lcEntityName) = 'SQL_'
		lcTableName = Substr(lcEntityName, 5)
	Else
		lcTableName = lcEntityName
	Endif

	If File(DictionaryTableName)
		lnSelect = Select()
		Use(DictionaryTableName) Alias DataDictSource In 0 Again Shared

		Select  Lower(Field_FieldName)    As  field_name,			;
				Type_FieldName            As  Field_Type,			;
				Length_FieldName          As  Field_Len,			;
				Decimals_FieldName        As  Field_Dec				;
			From DataDictSource										;
			Where Lower(Table_FieldName)  = Lower(lcTableName)		;
			Into Array laFields

		If _Tally > 0
			Dimension laList[1]
			Execscript(_Screen.cThorDispatcher, 'THOR_PROC_GetFieldNames', @laFields, @laList, 3)
			lxResult = Createobject('Empty')
			AddProperty(lxResult, 'aList[1]')
			Acopy(laList, lxResult.aList)
		Endif

		Use In DataDictSource
		Select(lnSelect)
	Endif && File(DictionaryTableName)

	Return lxResult
Endproc

		Endtext
		****************************************************************
		****************************************************************
	Endproc

Enddefine



****************************************************************
****************************************************************

Define Class clsISXNewObject As Custom

	Source				= 'ISX'
	PlugIn				= 'New Object'
	Description			= 'Called to provide IntellisenseX for variables that refer to objects created by a UDF.'
	Tools				= 'IntellisenseX'
	FileNames			= 'Thor_Proc_NewObject.PRG'
	DefaultFileName		= '*Thor_Proc_NewObject.PRG'
	DefaultFileContents	= ''

	Procedure Init
		****************************************************************
		****************************************************************
		Text To This.DefaultFileContents Noshow
Lparameters tcMethodName, tcClass, tcClassLib

Local loException, loResult
loResult = Null

Do Case

	Case Upper(tcMethodName) == Upper('NewSessionObject')
		Try
			loResult = Newobject(tcClass, tcClassLib, 0)
		Catch To loException

		Endtry

	Case Upper(tcMethodName) == Upper('FetchBusinessObject')
		loResult = FetchBusinessObject(tcClass, .T.)

	Case Upper(tcMethodName) == Upper('JRNDynamicForm')
		loResult = JRNDynamicForm()

Endcase

Return Execscript(_Screen.cThorDispatcher, 'Result= ', loResult)
		Endtext
		****************************************************************
		****************************************************************
	Endproc

Enddefine



****************************************************************

Define Class clsISXDataObject As Custom

	Source				= 'ISX'
	PlugIn				= 'Data Objects'
	Description			= 'Called to create dropdown lists for objects contained in other objects, normally fields for data objects. For instance, loParts.oData'
	Tools				= 'IntellisenseX'
	FileNames			= 'Thor_Proc_DataObjectPlugIn.PRG'
	DefaultFileName		= '*Thor_Proc_DataObjectPlugIn.PRG'
	DefaultFileContents	= ''

	Procedure Init
		****************************************************************
		****************************************************************
		Text To This.DefaultFileContents Noshow
* Sample Plug-in to obtain dropdown lists for objects or data objects
* that are contained in other objects. For Example:
*	loObject.oJobs
*	This.oParts
*	This.oParts.oData
*	This.oJobs.oItems
*	This.oJobs.oItems.oData

* In each of these examples, the reference before the final dot has been
* resolved into an object, and the values of the properties in that object
* are made available through the parameter object that is passed in, 
* using two methods:
*	loPEMs.GetValueFor('PropertyName')
*	loPEMs.GetDescriptionFor('PropertyName')

* The second value is the name following the last dot ("oJobs" in first example)


* Result may be any of:
*   .null. or logical -- no match found

*   Character         -- alias for table from which fields are to be listed

*   Character         -- {class, classlibrary} for an object

*   An Object         -- all properties, methods, and objects in the object 
*						 are displayed

*   An Object with a four dimensional array named aList:
*           aList[, 1] = Display Text (first column)
*           aList[, 2] = Second Column
*           aList[, 3] = Filter text
*           aList[, 4] = Icon file name

*   Collection        -- collection of simple character data, each item to
*                        be displayed as a separate row. A single tab character
*                        within any item may be used to create a two column display.


* =========================================================================
* =========================================================================
* 
* The following is sample code. It handles the case where the property 'oData'
* refers to a data object. The name of the table for this data object is
* contained in either:
*     -- the property 'cAlias'
*     -- the name of the passed-in object, if that name begins with 'bo_'

Lparameters loPEMs, lcPEM

Local lcAlias, lcName, lxResult

* Don't remove this! You still want the default behavior!
lxResult = Execscript(_Screen.cThorDispatcher, 'DoDefault()', m.loPEMs, m.lcPEM)

If Isnull(m.lxResult)
	If Lower(m.lcPEM) == 'odata'
		lcAlias = m.loPEMs.GetValueFor('cAlias')
		If Vartype(m.lcAlias) = 'C' And Not Empty(m.lcAlias)
			lxResult = m.lcAlias
		Else
			lcName = m.loPEMs.GetValueFor('Name')
			If Vartype(m.lcName) = 'C' And Lower(m.lcName) = 'bo_'
				lxResult = Substr(m.lcName, 4)
			Endif
		Endif
	Endif
Endif

Return Execscript(_Screen.cThorDispatcher, 'Result= ', m.lxResult)

		Endtext
		****************************************************************
		****************************************************************
	Endproc

Enddefine



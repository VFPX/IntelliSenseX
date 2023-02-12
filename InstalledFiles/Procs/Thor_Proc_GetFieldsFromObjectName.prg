#Define ccTab Chr[9]

Lparameters toISX

Local loParameter As 'Empty'
* tools home page = https://github.com/VFPX/Thor/blob/master/Docs/Thor_tools_object.md
Local loTools As Pemeditor_tools Of 'c:\visual foxpro\programs\MyThor\thor\tools\apps\pem editor\source\peme_tools.vcx'
Local laFields[1], laList[1], lcName, lcResult, llForceIt, lnFieldNamesCase, loTopOfForm
Local lxObjectInfo, lxResult

With m.toISX
	lcName			 = .cEntity
	llForceIt		 = .lForceThor
	lnFieldNamesCase = .ISXOptions.FieldNamesCase
Endwith

If Upper(m.lcName) # '@'
	If Upper(m.lcName) == 'THISFORM' Or Upper(m.lcName) == 'THIS' Or m.toISX.nEditSource = 0
		Return
	Endif
Endif

If Left(m.lcName, 1) = '.' Or Empty(m.lcName)
	loTools	= Execscript(_Screen.cThorDispatcher, 'Class= tools from pemeditor')
	lcName	= m.loTools.oUtils.oIDEx.GetCurrentHighlightedText(.T.)
Endif

If(Empty(m.lcName) Or m.lcName = 'm')  And Not m.llForceIt
	Return
Endif

loTools = Execscript(_Screen.cThorDispatcher, 'Class= tools from pemeditor')

loTopOfForm = m.loTools.GetCurrentObject(.T.)

loParameter = Createobject('Empty')
AddProperty(m.loParameter, 'cEntityName', m.lcName)
AddProperty(m.loParameter, 'oTopOfForm', m.loTopOfForm)
AddProperty(m.loParameter, 'lForceIt', m.llForceIt)

AddProperty(m.loParameter, 'cTextLeft', m.toISX.cTextLeft)
AddProperty(m.loParameter, 'cName', m.toISX.cName)

lxObjectInfo = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetTableFromObject', m.loParameter)
lxResult	 = .F.

Do Case

	Case Isnull(m.lxObjectInfo) Or Vartype(m.lxObjectInfo) = 'L'
		lcResult = ''
		If GetTableForAlias(m.lcName, @m.lcResult)
			Do Case
				Case Type('m.lcResult.aList[1]') = 'C'
					lxResult = m.lcResult
				Case 'O' = Vartype(m.lcResult)
					lxResult = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetPropertyList', m.lcResult)
				Otherwise
					lxResult = TryToUse(m.lcResult, m.lnFieldNamesCase)
			Endcase
		Endif

		* file name
	Case Vartype(m.lxObjectInfo) = 'C'
		lxResult = TryToUse(m.lxObjectInfo, m.lnFieldNamesCase)

		* if not an object
	Case Vartype(m.lxObjectInfo) # 'O'

		* for an object with an array Property aList
	Case 'C' = Type('m.lxObjectInfo.aList[1]')
		lxResult =  m.lxObjectInfo
		* for a collection, return the contents of the collection
	Case Vartype(m.lxObjectInfo.BaseClass) = 'C' And Lower(m.lxObjectInfo.BaseClass) = 'collection'
		lxResult =  m.lxObjectInfo
		* for all other objects, return the list of PEMs
	Otherwise
		poISXObject = m.lxObjectInfo
		lxResult = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetPropertyList', m.lxObjectInfo)
Endcase

Return Execscript(_Screen.cThorDispatcher, 'Result=', m.lxResult)


 Procedure FixFieldNameCase(tcName, lnFieldNamesCase)
	Local lcField
	lcField = m.tcName
	Do Case
		Case m.lnFieldNamesCase = 1
			lcField = Lower(m.lcField)
		Case m.lnFieldNamesCase = 2
			lcField = Upper(m.lcField)
		Case m.lnFieldNamesCase = 3
			lcField = Proper(m.lcField)
		Case m.lnFieldNamesCase = 4
			lcField = Lower(Left(m.lcField, 1)) + Substr(m.lcField, 2)
	Endcase
	Return m.lcField
Endproc


 Procedure GetTableForAlias(lcAlias, lcResult)
 	* See if this alias is defined in Thor's global alias list
 	Local loThor As Thor_Engine Of 'C:\VISUAL FOXPRO\PROGRAMS\MyThor\Thor\Source\Thor.vcx'
 	Local lcFileName, loResult
 
 	loThor	   = Execscript(_Screen.cThorDispatcher, 'Thor Engine=')
 	lcFileName = m.loThor.GetTableForAlias(m.lcAlias)
 
 	If Empty(m.lcFileName)
 		Return .F.
 	Endif
 
 	loResult = Execscript(_Screen.cThorDispatcher, 'THOR_PROC_ISX_GetNewObject', m.lcFileName)
 	If Isnull(m.loResult)
 		lcResult = m.lcFileName
 	Else
 		lcResult = m.loResult
 	Endif
 	Return .T.
 Endproc
 

 Procedure TryToUse(lcFileName, lnFieldNamesCase)
	Local lxResult As 'Empty'
	Local laFields[1], laList[1], lcAlias
	lcAlias	   = Execscript(_Screen.cThorDispatcher, 'PEME_OpenTable', m.lcFileName)
	If Used(m.lcAlias)
		Afields(laFields, m.lcAlias )
		Dimension m.laList[1]
		Execscript(_Screen.cThorDispatcher, 'THOR_PROC_GetFieldNames', @m.laFields, @m.laList, m.lnFieldNamesCase, m.lcFileName)
		lxResult = Createobject('Empty')
		AddProperty(m.lxResult, 'aList[1]')
		Acopy(laList, m.lxResult.aList)
	Else
		lxResult = .F.
	Endif

	Return m.lxResult
Endproc


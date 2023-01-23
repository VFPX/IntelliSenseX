#Define ThorTool 		'IntellisenseX'
#Define AllNameTool 	'AutoComplete'
#Define TableAliases 	'Table Aliases'

#Define		CRLF Chr[13] + Chr[10]

Local loResult As 'Empty'
Local laKeyWordList[1], laLines[1], lcChanges, lcImagesFolder, lcWord, lnCount, lnI, lnIndex
Local lnLines, loThor

If 'O' # Vartype(_Screen.oISXOptions)
	m.loThor		  = Execscript(_Screen.cThorDispatcher, 'Thor Engine=')

	m.loResult = Createobject('Empty')

	AddProperty(m.loResult, 'FontName', 		Alltrim(m.loThor.GetOption('Font Name', 	ThorTool)))
	AddProperty(m.loResult, 'FontSize', 		m.loThor.GetOption('Font Size', 			ThorTool))
	AddProperty(m.loResult, 'DisplayCount', 	m.loThor.GetOption('Display Count', 		ThorTool))

	AddProperty(m.loResult, 'AlphaSort', 		m.loThor.GetOption('Alpha Sort', 			ThorTool))
	AddProperty(m.loResult, 'ShowFieldDefs', 	m.loThor.GetOption('Show Fields Defs', 		ThorTool))
	AddProperty(m.loResult, 'FieldNamesCase', 	m.loThor.GetOption('FieldNames Case', 		ThorTool))

	AddProperty(m.loResult, 'Filtering', 		m.loThor.GetOption('Filtering', 			ThorTool))
	AddProperty(m.loResult, 'FilterType', 		m.loThor.GetOption('FilterType', 			ThorTool))
	AddProperty(m.loResult, 'FilterToggle', 	m.loThor.GetOption('FilterToggle', 			ThorTool))
	AddProperty(m.loResult, 'SelectIfOne', 		m.loThor.GetOption('SelectIfOne', 			ThorTool))
	AddProperty(m.loResult, 'PRGBasedClasses', 	m.loThor.GetOption('PRGBasedClasses', 		ThorTool))
	AddProperty(m.loResult, 'OverrideThisform', m.loThor.GetOption('OverrideThisform',		ThorTool))
	AddProperty(m.loResult, 'UseCKLforPEMs', 	m.loThor.GetOption('UseCKLforPEMs',			ThorTool))
	AddProperty(m.loResult, 'LeaveTablesOpen', 	m.loThor.GetOption('LeaveTablesOpen',		ThorTool))

	AddProperty(m.loResult, 'MDotsUsage', 		m.loThor.GetOption('MDots Usage',			'MDots'))
	AddProperty(m.loResult, 'ImagesFolder', 	Addbs(Execscript(_Screen.cThorDispatcher, 'Tool Folder=')) + 'Images\')

	AddProperty(m.loResult, 'CaseSensitive', 	m.loThor.GetOption('Case-sensitive sort',	AllNameTool))
	AddProperty(m.loResult, 'ExcludeVFPKeywords',	m.loThor.GetOption('Exclude VFP Keywords',	AllNameTool))
	AddProperty(m.loResult, 'Capitalization',	m.loThor.GetOption('Capitalization',	AllNameTool))
	AddProperty(m.loResult, 'AllProcedures',	m.loThor.GetOption('All Procedures in PRGS',	AllNameTool))

	AddProperty(m.loResult, 'AliasMethodName', 	Alltrim(m.loThor.GetOption('Table Aliases Method Name',	TableAliases)))
	AddProperty(m.loResult, 'AliasNamePosition', 	m.loThor.GetOption('Table Aliases Name Position',	TableAliases))
	AddProperty(m.loResult, 'AliasPosition', 	m.loThor.GetOption('Table Aliases Alias Position',	TableAliases))

	* --------------------------------------------------------------------------------
	Use Home() + 'WIZARDS\FDKEYWRD' Order TOKEN Again Shared In 0 Alias Keywords
	Select  Distinct TOKEN					;
		From Keywords						;
		Where Isalpha(TOKEN)				;
			Or Left(TOKEN, 1) = '_'			;
		Order By 1							;
		Into Array laKeyWordList
	Use In Keywords

	lcChanges = Execscript(_Screen.cThorDispatcher, 'Get Option=', 'Excluded Words', AllNameTool)
	If Not Empty(Nvl(lcChanges, ''))
		lnLines	= Alines(laLines, lcChanges, 7, ' ', ',')
		lnCount	= Alen(laKeyWordList)
		For lnI = 1 To lnLines
			lcWord = laLines[lnI]
			If lcWord # '+'
				lnIndex = Ascan(laKeyWordList, lcWord, 1, -1, 1, 7)
				If lnIndex # 0
					Adel(laKeyWordList, lnIndex)
					lnCount = lnCount - 1
					Dimension laKeyWordList[lnCount]
				Endif
			Else
				lnCount = lnCount + 1
				Dimension laKeyWordList[lnCount]
				laKeyWordList[lnCount] = Padr(Substr(lcWord, 2), 30)
			Endif
		Endfor
	Endif

	AddProperty(m.loResult, 'KeyWordList[1]')
	Acopy(laKeyWordList, loResult.KeyWordList)
	AddProperty(m.loResult, 'oKeyWordList', ExecScript(_Screen.cThorDispatcher, 'Class= cKeywordlist of Thor_Proc_ManageCustomKeywordList.PRG'))

	* --------------------------------------------------------------------------------

	_Screen.AddProperty('oISXOptions', m.loResult)
Endif

Return Execscript(_Screen.cThorDispatcher, 'Result=', _Screen.oISXOptions)


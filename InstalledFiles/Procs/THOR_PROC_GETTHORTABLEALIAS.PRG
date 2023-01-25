Lparameters lcAlias

*	Maps an alias to its "Real Name" in Thor's TableAliases Table
*	which can be used both for tables and objects

*	Called by GoToDefinition and IntellisenseX

#Define ccOriginalPlaceHolder '<*>'
Local laMatches[1], lcMatchAlias, lcResult, lcToolFolder, lcWildCardValue, lnStartPosition

If Not Used('TableAliases_in_Thor')
	lcToolFolder  = Execscript(_Screen.cThorDispatcher, 'Tool Folder=')
	Use Addbs(m.lcToolFolder) + '..\Tables\TableAliases' Alias TableAliases_in_Thor Again Shared In 0
Endif

Select  Alias,															;
		Table,															;
		Upper(Alias) == Padr(Upper(m.lcAlias), 40)    As  Exact,		;
		Len(Trim(Alias))                              As  Length		;
	From TableAliases_in_Thor											;
	Where Upper(Alias) == Padr(Upper(m.lcAlias), 40)					;
		Or Like(Upper(Alltrim(Alias)), Upper(Alltrim(m.lcAlias)))		;
	Order By Exact Desc,												;
		Length Desc														;
	Into Array laMatches

If _Tally > 0
	lcResult = Alltrim(m.laMatches[2])
	If '*' $ m.lcResult
		lcMatchAlias	= Alltrim(m.laMatches[1])
		lnStartPosition	= At('*', m.lcMatchAlias)
		lcWildCardValue	= Substr(m.lcAlias, m.lnStartPosition, Len(Alltrim(m.lcAlias)) - Len(m.lcMatchAlias) + 1)
		If ccOriginalPlaceHolder $ m.lcResult
			lcResult =  Strtran(m.lcResult, ccOriginalPlaceHolder, m.lcWildCardValue)
		Else
			lcResult =  Strtran(m.lcResult, '*', m.lcWildCardValue)
		Endif
	Endif
Endif

Use In TableAliases_in_Thor

Return Execscript (_Screen.cThorDispatcher, 'Result=', m.lcResult)

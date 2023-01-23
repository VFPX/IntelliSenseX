Lparameters lcAlias

*	Maps an alias to its "Real Name" in Thor's TableAliases Table
*	which can be used both for tables and objects

*	Called by GoToDefinition

#Define PLACEHOLDER '<*>'
Local lcName, lcResult, lcToolFolder, lcWildCardValue, lnSelect, lnStarPosition

lnSelect = Select()
Select 0
If Used('Thor_TableAliases')
	Select Thor_TableAliases
Else
	lcToolFolder  = Execscript(_Screen.cThorDispatcher, 'Tool Folder=')
	Use Addbs(m.lcToolFolder) + '..\Tables\TableAliases' Alias Thor_TableAliases Again Shared
Endif

If Indexseek(Upper(Padr(m.lcAlias, 40)),.T., 'Thor_TableAliases', 'Alias')
	lcResult = Alltrim(Thor_TableAliases.Table)
Else
	Locate For Like(Upper(Alltrim(Alias)), Upper(Alltrim(m.lcAlias)))
	If Found()
		lnStarPosition	= At('*', Alias)
		lcWildCardValue	= Substr(m.lcAlias, m.lnStarPosition, Len(Alltrim(m.lcAlias)) - Len(Alltrim(Alias)) + 1)
		lcName			= Alltrim(Table)
		If Empty(m.lcName)
			lcResult = m.lcWildCardValue
		Else
			lcResult =  Strtran(m.lcName, PLACEHOLDER, m.lcWildCardValue)
		Endif
	Endif
Endif

Use In Thor_TableAliases
Select (m.lnSelect)

Return Execscript (_Screen.cThorDispatcher, 'Result=', m.lcResult)

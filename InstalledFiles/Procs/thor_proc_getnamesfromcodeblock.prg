#Define ccNAMECHARS	 '0123456789@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz'

#Define Tab 	Chr[9]
#Define CR 		Chr[13]
#Define LF 		Chr[10]
#Define CRLF 	CR + LF


Lparameters lcCodeBlock, lcPrefix
Local loResult As 'Empty'
Local loTools As Pemeditor_tools Of 'c:\visual foxpro\programs\MyThor\thor\tools\apps\pem editor\source\peme_tools.vcx'
Local laNames[1], laResult[1], laUsed[1], lcDelimiters, lcLast, lcName, lcNameString, lcType
Local llResult, lnCapitalization, lnCount, lnI, lnKeyWordIndex, lnLength, lnRow, loVariables

lcCodeBlock = Strtran(Chrtran(m.lcCodeBlock, LF, ''), CR, CRLF)
* tools home page = http://vfpx.codeplex.com/wikipage?title=thor%20tools%20object
loTools		= Execscript (_Screen.cThorDispatcher, 'Class= tools from pemeditor')

Execscript (_Screen.cThorDispatcher, 'Thor_Proc_FindNonCodeBlocks', m.lcCodeBlock, 'crsr_NotCode')

Scan For NotCode
	lnLength	= 2 + End - Start
	lcCodeBlock	= Stuff(m.lcCodeBlock, Start, m.lnLength, Space(m.lnLength))
Endscan
Use In crsr_NotCode

lcDelimiters = Chrtran(m.lcCodeBlock, ccNAMECHARS, '')
lcNameString = Chrtran(m.lcCodeBlock, m.lcDelimiters, Space(Len(m.lcDelimiters)))

If Empty(m.lcNameString)
	Return Execscript(_Screen.cThorDispatcher, 'Result=', .F.)
Endif

Alines(laNames, m.lcNameString, 5, ' ')
Asort(m.laNames, 1, -1, 0, 1)

Dimension m.laResult(Alen(m.laNames), 2)
lnCount			 = 0
lcLast			 = '?'
lnCapitalization = _Screen.oISXOptions.Capitalization
loVariables		 = m.loTools.GetVariablesList (m.lcCodeBlock, '*')

For lnI = 1 To Alen(m.laNames)
	lcName = m.laNames[m.lnI]
	If Left(m.lcName, 1) $ '.0123456789'
		Loop
	Endif

	If Len(m.lcName) > 250
		Loop
	Endif

	If Atc(m.lcLast + '.', m.lcName + '.') = 1
		If m.lnCapitalization = 4 And m.laResult[m.lnCount, 1] == Lower(m.laResult[m.lnCount, 1])
			laResult[m.lnCount, 1] = m.lcName
		Endif
		Loop
	Endif

	If '.' $ m.lcName
		lcName = Getwordnum(m.lcName, 1, '.')
	Endif

	If _Screen.oISXOptions.ExcludeVFPKeywords
		lnKeyWordIndex = Ascan(_Screen.oISXOptions.KeyWordList, Padr(m.lcName, 30), 1, -1, 1, 7)
	Else
		lnKeyWordIndex = 0
	Endif

	If m.lnKeyWordIndex = 0
		lnCount				   = m.lnCount + 1
		lcLast				   = m.lcName
		laResult[m.lnCount, 1] = Icase(m.lnCapitalization = 2, Upper(m.lcName), m.lnCapitalization = 3, Lower(m.lcName), Evl(_Screen.oISXOptions.oKeyWordList.FixCase(m.lcName), m.lcName))
		laResult[m.lnCount, 2] = ''
	Endif
Endfor && lnI = 1 to Len(laNames)

If m.lnCount = 0
	Return Execscript(_Screen.cThorDispatcher, 'Result=', .F.)
Endif

For lnI = 1 To Alen(m.loVariables.aList, 1)
	lcName = m.loVariables.aList[m.lnI, 1]
	If Empty(m.lcName)
		Loop
	Endif
	lcType = m.loVariables.aList[m.lnI, 2]
	lnRow  = Ascan(m.laResult, m.lcName, 1, -1, 1, 15)
	Do Case
		Case m.lnRow = 0

		Case 'param' $ m.lcType
			laResult[m.lnRow, 1] = m.lcPrefix + m.laResult[m.lnRow, 1]
			laResult[m.lnRow, 2] = 'Parameter'
		Case 'local' $ m.lcType
			laResult[m.lnRow, 1] = m.lcPrefix + m.laResult[m.lnRow, 1]
			laResult[m.lnRow, 2] = 'Local'
		Case 'public' $ m.lcType
			laResult[m.lnRow, 1] = m.lcPrefix + m.laResult[m.lnRow, 1]
			laResult[m.lnRow, 2] = 'Public'
		Case 'private' $ m.lcType
			laResult[m.lnRow, 1] = m.lcPrefix + m.laResult[m.lnRow, 1]
			laResult[m.lnRow, 2] = 'Private'
		Otherwise
			laResult[m.lnRow, 2] = 'Assigned'
	Endcase
Endfor

Dimension m.laResult[m.lnCount, 2]
Asort(m.laResult, 1, -1, 0, Iif(_Screen.oISXOptions.CaseSensitive, 0, 1))

llResult = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_SortAutoComplete', @m.laResult)
If Nvl(m.llResult, .T.)
	loResult = Createobject('Empty')
	AddProperty(m.loResult, 'aList[1]')
	Acopy(laResult, m.loResult.aList)
	Return Execscript(_Screen.cThorDispatcher, 'Result=', m.loResult)
Else
	Return Execscript(_Screen.cThorDispatcher, 'Result=', .F.)
Endif

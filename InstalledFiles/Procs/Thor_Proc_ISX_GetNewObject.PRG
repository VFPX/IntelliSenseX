*	Get an object; parameter combinations are:
*		[1]	Two parameters:
*			'ClassName', 'ClassLibrary'
*		[2] Single parameter:
*			-   {ClassName, ClassLibrary}   --- (preferred construction)
*			-	Local Somename as ClassName of ClassLibrary
*			-	= SomePhrasetoExecute

* 	Returns null if not found / unable to create; error trapping

*	Called by GoToDefinition

Lparameters lcClass, lcClassLib
Local loException, loResult

loResult = Null
Do Case

	Case Empty(m.lcClass)

	Case Pcount() = 2
		loResult = GetNewObject(m.lcClass, m.lcClassLib)

	Case GetAliasFromBraces(m.lcClass, @m.loResult)

	Case GetAliasFromLOCALStatement(m.lcClass, @m.loResult)

	Case Left(m.lcClass, 1) = '='
		Try
			loResult = Evaluate(Substr(m.lcClass, 2))
		Catch To m.loException

		EndTry
		
Endcase

Return ExecScript(_Screen.cThorDispatcher, 'Result=', m.loResult)



 Procedure GetNewObject(lcClass, lcClassLib)
	Local loException, loObject
	Try
		loObject   = Newobject(m.lcClass, m.lcClassLib, 0)
	Catch To m.loException
		loObject = null
	Endtry
	Return m.loObject
Endproc


 Procedure GetAliasFromLOCALStatement(tcCommand, tcResult)
	Local lcClass, lcClassLib, lcCommand, lcQuote, lcWord1, loException, loObject
	lcCommand = Upper(m.tcCommand)
	lcWord1	  = Getwordnum(m.lcCommand, 1)
	If Len(m.lcWord1) >= 4 And 'LOCAL ' = m.lcWord1
		lcClass	   = Chrtran(Getwordnum(m.lcCommand, 4), ['"] + '[]', '')
		lcClassLib = ''
		If Getwordnum(m.lcCommand, 5) == 'OF'
			lcClassLib = Getwordnum(m.lcCommand, 6)
			lcQuote	   = Left(m.lcClassLib, 1)
			If m.lcQuote $  ['"] + '['
				lcClassLib = Substr(m.lcCommand, Atc(m.lcClassLib, m.lcCommand))
				lcClassLib = Strextract(m.lcClassLib, m.lcQuote, Chrtran(m.lcQuote, '[', ']'))
			Endif
		Endif
		loObject = GetNewObject(m.lcClass, m.lcClassLib)
		If Vartype(m.loObject) = 'O'
			tcResult = m.loObject
			Return .T.
		Endif
	Endif && Len(lcWord1)>= 4 and 'LOCAL ' = lcWord1
	Return .F.
Endproc


 Procedure GetAliasFromBraces(tcCommand, tcResult)
	Local lcClass, lcClassLib, lcText, loObject

	lcText = Strextract(m.tcCommand, '{', '}')
	If Empty(m.lcText)
		Return .F.
	Endif

	lcClass	   = Alltrim(Getwordnum(m.lcText, 1, ','))
	lcClassLib = Alltrim(Getwordnum(m.lcText, 2, ','))
	loObject   = GetNewObject(m.lcClass, m.lcClassLib)
	If Vartype(m.loObject) = 'O'
		tcResult = m.loObject
		Return .T.
	Endif
	Return .F.
Endproc



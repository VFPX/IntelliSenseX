Lparameters tcCodeText

Local loGP As 'Empty'
Local lcResult, lcTextLine, lcWord1, llFirstLine
loGP = Createobject('Empty')

AddProperty(loGP, 'nNextLine', 1)
AddProperty(loGP, 'aCodeLines[1]')
AddProperty(loGP, 'nLineCount', Alines(loGP.aCodeLines, tcCodeText))

lcResult = ''
Return Execscript(_Screen.cThorDispatcher, 'Result=', TrimTabs(lcResult))
Do While loGP.nNextLine <= loGP.nLineCount and Empty(lcResult)
	llFirstLine	= loGP.nNextLine = 1
	lcTextLine	= GetTextLine(loGP)
	lcWord1		= Upper(Getwordnum(lcTextLine, 1, ' ('))
	Do Case
		Case Len(lcWord1) < 4
		Case ('PROCEDURE' = lcWord1 Or 'FUNCTION' = lcWord1) AND '(' $lcTextLine
			lcResult =  StrExtract(lcTextLine, '(', ')') 
		Case 'LPARAMETERS' = lcWord1 Or 'PARAMETERS' = lcWord1
			lcResult =  Strtran(lcTextLine, lcWord1, '', 1, 1, 1)
		Case llFirstLine And '(' $ lcTextLine And		;
				('PROCEDURE' = lcWord1 Or 'FUNCTION' = lcWord1)
			If '(' $ lcTextLine
				lcResult =  Strextract(lcTextLine, '(', ')', 1)
			Endif
		Otherwise
	Endcase
Enddo

Return Execscript(_Screen.cThorDispatcher, 'Result=', TrimTabs(lcResult))


Procedure GetTextLine(toGP)
	* Gets a text line, including continuation lines
	lcTextLine = GetPhysicalLine(toGP)
	Do While Right(lcTextLine, 1) = ';' And toGP.nNextLine <= toGP.nLineCount
		lcTextLine = Left(lcTextLine, Len(lcTextLine) - 1) + ' ' + GetPhysicalLine(toGP)
	Enddo
	Return lcTextLine
Endproc

#Define DoubleAmps 	('&' + '&')

Procedure GetPhysicalLine(toGP)
	Local lcTextLine
	lcTextLine	   = TrimTabs(toGP.aCodeLines[toGP.nNextLine])
	toGP.nNextLine = toGP.nNextLine + 1
	If DoubleAmps $ lcTextLine
		lcTextLine = TrimTabs(Left(lcTextLine, At(DoubleAmps, lcTextLine) - 1))
	Endif
	Return lcTextLine
Endproc

Procedure TrimTabs(tcText)
	Return Alltrim(tcText, 1, ' ', ccTab)
Endproc
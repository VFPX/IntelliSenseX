#Include "..\Header Files\Thor_Proc_IntellisenseX.h"

#Define cnColumnCount 	6

Lparameters lnDetailLevel, tcCodeSource, lnSelStart, lcClass

* lnDetailLevel = 3 for Custom only
*               = 2 for All (includes native and inherited)

Local loGetPEMS As 'GetPEMS'
Local lcCodeSource, loEditorWin, loResult

If 'C' = Vartype(m.tcCodeSource)
	lcCodeSource = m.tcCodeSource
	lnSelStart	 = Evl(m.lnSelStart, 1)
Else
	* editorwin home page = https://github.com/VFPX/Thor/blob/master/Docs/Thor_editorwindow_object.md
	loEditorWin = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_EditorWin')

	lnSelStart	 = m.loEditorWin.GetSelStart()
	lcCodeSource = m.loEditorWin.GetString(0, 10000000)
Endif

loGetPEMS		 = Newobject('GetPEMS')
With m.loGetPEMS
	.cCodeSource  = m.lcCodeSource
	.nDetailLevel = m.lnDetailLevel
	.oProcs		  = Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetFullStartPositions', m.lcCodeSource)
Endwith

If Empty(m.lcClass)
	loResult = m.loGetPEMS.Run(m.lnSelStart, 0)
Else
	loResult = m.loGetPEMS.ReadClass(m.lcClass)
Endif

Return Execscript(_Screen.cThorDispatcher, 'Result=', m.loResult)


* --------------------------------------------------------------------------------

 Define Class GetPEMs As Custom
	cCodeSource	  = ''
	nDetailLevel  = 2
	nCount		  = 0
	oProcs		  = Null
	cImagesFolder = ''

	Dimension aList[1, cnColumnCount]


	Procedure Init
		This.cImagesFolder = Addbs(Execscript(_Screen.cThorDispatcher, 'Tool Folder=')) + 'Images\'
	Endproc


 	Procedure Run(lnSelStart, lnCountStartValue)

		Local loResult As 'Empty'
		Local lcClassName, lcCodeVariables, lcName, lcParameterList, lcParentClass, lcParentClassLoc
		Local lcProcCode, llWithinAClass, lnEndProperties, lnI, lnLength, lnStartProperties, loProc

		llWithinAClass = .F.

		For lnI = 1 To This.oProcs.Count
			loProc = This.oProcs[m.lnI]
			Do Case

				Case m.loProc.Type = 'Class' And m.loProc.StartByte <= m.lnSelStart
					llWithinAClass	  = .T.
					lcClassName		  = m.loProc.Name
					This.nCount		  = m.lnCountStartValue
					lnStartProperties = m.loProc.StartByte
					If m.lnI < This.oProcs.Count
						lnEndProperties = This.oProcs[m.lnI + 1].StartByte
					Else
						lnEndProperties = Len(This.cCodeSource)
					Endif
					lcParentClass	 = m.loProc.ParentClass
					lcParentClassLoc = m.loProc.ParentClassLoc

				Case m.loProc.Type = 'Class'
					Exit

				Case m.loProc.Type = '-End'

				Case Not m.llWithinAClass

				Otherwise
					If Getwordcount(m.loProc.Name, '.') = 2
						lcName = Getwordnum(m.loProc.Name, 2, '.')
						If m.lcName # '-'
							If m.lnI < This.oProcs.Count
								lnLength = This.oProcs[m.lnI + 1].StartByte - m.loProc.StartByte
							Else
								lnLength = Len(This.cCodeSource) - m.loProc.StartByte
							Endif
							lcProcCode		= Substr(This.cCodeSource, m.loProc.StartByte, m.lnLength)
							*!* ******************** Removed 05/04/2020 *****************
							*!* lcParameterList	= Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetParameters', m.lcProcCode)
							lcParameterList	= Thor_Proc_GetParameters(m.lcProcCode)

							This.AddRow(m.lcName, 'Method', '(' + m.lcParameterList + ')')
						Endif
					Endif
			Endcase
		Endfor

		If This.nCount = 0
			Return .F.
		Endif

		lcCodeVariables	= Substr(This.cCodeSource, m.lnStartProperties + 1, m.lnEndProperties - m.lnStartProperties)
		This.AddClassProperties(m.lcCodeVariables, m.lcClassName, m.lcParentClass)

		If m.llWithinAClass And This.nDetailLevel = 2
			This.AddInheritedProperties(m.lcParentClass, m.lcParentClassLoc)
		Endif

		loResult = Createobject('Empty')
		AddProperty(m.loResult, 'aList[1]')
		Acopy(This.aList, m.loResult.aList)

		Return m.loResult
	Endproc


 	Procedure AddClassProperties(lcCodeVariables, lcClassName, lcParentClass)
		Local laProperties[1], lcNewProperty, lcProp, lcWord1, llAddit, lnCount, lnI, lnPropCount

		lnPropCount	= Alines(laProperties, Strtran(m.lcCodeVariables, ccTab, ' '), 5)
		This.AddRow('Name', 'Propty', , [Name = '] + m.lcClassName + ['])
		This.AddRow('Class', 'Propty', , [Class = '] + m.lcClassName + ['])
		This.AddRow('ParentClass', 'Propty', , [ParentClass = '] + m.lcParentClass + ['])
		For lnI = 2 To m.lnPropCount
			lcProp	= m.laProperties[m.lnI]
			lcWord1	= Getwordnum(m.lcProp, 1, ' =')
			Do Case
				Case Left(m.lcWord1, 1) $ '*&#'
					llAddit = .F.
				Case Len(m.lcWord1) >= 4 And(Not '=' $ m.lcProp) And(		;
						  'HIDDEN' = Upper(m.lcWord1)						;
						  Or 'PROTECTED' = Upper(m.lcWord1)					;
						  Or 'DIMENSION' = Upper(m.lcWord1))
					llAddit		  = .T.
					lcNewProperty = Getwordnum(m.lcProp, 2, ' ([' + ccTab)
				Otherwise
					llAddit		  = .T.
					lcNewProperty = m.lcWord1
			Endcase
			If m.llAddit And 0 = Ascan(This.aList, m.lcNewProperty, 1, -1, 1, 15)
				This.AddRow(Alltrim(m.lcNewProperty), 'Propty', , m.lcProp)
			Endif
			* ignore continuation lines
			Do While  ';' = Right(Trim('X' + m.lcProp, ' ', Chr[9]), 1) And m.lnI < m.lnPropCount
				lnI	   = m.lnI + 1
				lcProp = m.laProperties[m.lnI]
			Enddo
		Endfor
	Endproc


 	Procedure AddInheritedProperties(lcParentClass, lcParentClassLoc, llCustomOnly)
 		Local laMembers[1], lcNewProperty, lcNewerProperty, lcParameters, lcType, lcValue, lcWord1, lnI
 		Local lnRowCount, loException, loObject, loProc
 	
 		If Empty(m.lcParentClassLoc)
 			For lnI = 1 To This.oProcs.Count
 				loProc = This.oProcs[m.lnI]
 				If m.loProc.Type = 'Class' And Upper(m.loProc.Name) == Upper(m.lcParentClass)
 					This.Run(m.loProc.StartByte, This.nCount)
 					Return
 				Endif
 			Endfor
 		Endif
 	
 		If m.llCustomOnly
 			Return
 		Endif
 	
 		Try
 			loObject   = Newobject(m.lcParentClass, m.lcParentClassLoc, 0)
 			lnRowCount = Amembers(laMembers, m.loObject, 3)
 		Catch To m.loException
 			lnRowCount = 0
 		Endtry
 	
 		For lnI = 1 To m.lnRowCount
 			lcNewProperty = m.laMembers[m.lnI, 1]
 			lcNewProperty = Evl(_Screen.oISXOptions.oKeyWordList.FixCase(m.lcNewProperty, .T.), m.lcNewProperty)
 			lcType		  = m.laMembers[m.lnI, 2]
 			If 0 = Ascan(This.aList, m.lcNewProperty, 1, -1, 1, 15)
 				Do Case
 					Case m.lcType = 'Property'
 						Try
 							lcValue = Getpem(m.loObject, m.lcNewProperty)
 						Catch To m.loException
 							lcValue = '?'
 						Endtry
 						Do Case
 							Case Vartype(m.lcValue) = 'C'
 								lcValue = '[' + m.lcValue + ']'
 							Case Isnull(m.lcValue)
 								lcValue = '.Null.'
 							Otherwise
 								lcValue = Transform(m.lcValue)
 						Endcase
 						*!* ******************** Removed 11/17/2014 *****************
 						*!* If Not Empty(m.laMembers[m.lnI, 4])
 						*!* 	lcValue = m.lcValue + DescriptionDelimiter + m.laMembers[m.lnI, 4]
 						*!* Endif
 	
 						This.AddRow(m.lcNewProperty, 'Propty', , m.lcNewProperty + [ = ] + m.lcValue)
 	
 					Case Inlist(m.lcType, 'Method', 'Event')
 						lcParameters = m.laMembers[m.lnI, 3]
 						lcWord1		 = Upper(Getwordnum(m.lcParameters, 1, ' '))
 						Do Case
 							Case 'PROCEDURE ' = m.lcWord1
 								lcNewerProperty = Substr(m.lcParameters, 11, Len(m.lcNewProperty))
 								If m.lcNewProperty == Upper(m.lcNewProperty)						;
 										Or (Upper(m.lcNewerProperty) = Upper(m.lcNewProperty)		;
 										  And This.CountUpperCase(m.lcNewerProperty) > This.CountUpperCase(m.lcNewProperty))
 									lcNewProperty = m.lcNewerProperty
 								Endif
 								lcParameters = Strextract(m.lcParameters, '(', ')')
 							Case 'PARAMETERS ' = lcWord1 Or 'LPARAMETERS ' = lcWord1
 								lcParameters = Substr(m.lcParameters, 1 + Len(lcWord1))
 							Case 'LOCAL ' = lcWord1
 								lcParameters = ''
 						Endcase
 						This.AddRow(m.lcNewProperty, m.lcType, '(' + m.lcParameters + ')')
 				Endcase
 			Endif
 		Endfor
 	Endproc
 		
	
	Procedure CountUpperCase(lcText)
		Return Len(Chrtran(lcText, 'abcdefghijklmnopqrstuvwxyz ', ''))
	EndProc 



 	Procedure AddRow(lcName, lcType, lcParameters, lcValueText)
 		If This.nCount # 0 and 0 # Ascan(This.aList, m.lcName, 1, -1, 1, 15) && no dups
 			Return
 		EndIf 
 	
		This.nCount				   = This.nCount + 1
		Dimension This.aList[This.nCount, cnColumnCount]
		This.aList[This.nCount, 1] = m.lcName
		This.aList[This.nCount, 2] = Iif(Vartype(m.lcValueText) = 'C', Alltrim(Substr(m.lcValueText, At('=', m.lcValueText))), m.lcParameters)
		This.aList[This.nCount, 4] = This.cImagesFolder + m.lcType + '.bmp'
		If Not Empty(m.lcParameters)
			This.aList[This.nCount, 5] = m.lcName + m.lcParameters
		Endif
		If Not Empty(m.lcValueText)
			If '=' $ m.lcValueText
				This.aList[This.nCount, 6] = Alltrim(Substr(m.lcValueText, 1 + At('=', m.lcValueText)))
			Else
				This.aList[This.nCount, 6] = ''
			Endif
		Endif
	Endproc


 	Procedure ReadClass(lcClass)
		Local loResult As 'Empty'
		This.AddInheritedProperties(m.lcClass, , .T.)
		If This.nCount = 0
			Return .F.
		Endif

		loResult = Createobject('Empty')
		AddProperty(m.loResult, 'aList[1]')
		Acopy(This.aList, m.loResult.aList)
		Return m.loResult
	Endproc

 Enddefine



Procedure Thor_Proc_GetParameters
Lparameters tcCodeText

Local loGP As 'Empty'
Local lcResult, lcTextLine, lcWord1, llFirstLine
loGP = Createobject('Empty')

AddProperty(loGP, 'nNextLine', 1)
AddProperty(loGP, 'aCodeLines[1]')
AddProperty(loGP, 'nLineCount', Alines(loGP.aCodeLines, tcCodeText))

lcResult = ''

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

Return TrimTabs(lcResult)


Procedure GetTextLine(toGP)
	* Gets a text line, including continuation lines
	lcTextLine = GetPhysicalLine(toGP)
	Do While Right(lcTextLine, 1) = ';' And toGP.nNextLine <= toGP.nLineCount
		lcTextLine = Left(lcTextLine, Len(lcTextLine) - 1) + ' ' + GetPhysicalLine(toGP)
	Enddo
	Return lcTextLine
Endproc

#Define DoubleAmps 	('&' + '&')
#Define ccTab 		Chr[9]

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
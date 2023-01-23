#Include "..\Header Files\Thor_Proc_IntellisenseX.h"

Lparameters toObject, tcTypes

Local loTools As Pemeditor_tools Of 'c:\visual foxpro\programs\MyThor\thor\tools\apps\pem editor\source\peme_tools.vcx'
Local lxResult As 'Empty'
Local laList[1], laMembers[1], lcBmpName, lcFirstParam, lcImagesFolder, lcKeyWord, lcName, lcOKTypes
Local lcParametersList, lcType, lcValue, lcWord1, llPropValues, lnColumnCount, lnCount, lnIndex
Local lnKeyWordIndex, lnLastRow, loException, loPEMs

If Pemstatus(m.toObject, 'BaseClass', 5) And _Screen.oISXOptions.UseCKLforPEMs = .F.
	* tools home page = http://vfpx.codeplex.com/wikipage?title=thor%20tools%20object
	loTools	= Execscript(_Screen.cThorDispatcher, 'Class= tools from pemeditor')
	loPEMs	= m.loTools.GetPEMList(m.toObject)
Else
	loPEMs = Createobject('collection')
Endif

* --------------------------------------------------------------------------------
*** In some obscure cases, these may fail; we don't know why
lnCount = 0
Try
	lnCount = Amembers(laMembers, m.toObject, 3)
Catch
	Try
		lnCount = Amembers(laMembers, m.toObject, 1)
	Catch
		Try
			lnCount = Amembers(laMembers, m.toObject, 0)
			Dimension m.laMembers(Alen(m.laMembers, 1), 1)
		Catch
		Endtry
	Endtry
Endtry

If m.lnCount = 0
	Return
Endif

lnLastRow	   = 0
lcOKTypes	   = Evl(m.tcTypes, 'PROPERTY,EVENT,METHOD,OBJECT')
lcImagesFolder = Addbs(Execscript(_Screen.cThorDispatcher, 'Tool Folder=')) + 'Images\'
lnColumnCount  = Alen(m.laMembers, 2)
* avoid COM objects (any non-foxpro objects) but allow the Empty object
llPropValues   = m.lnColumnCount >= 2 And (Pemstatus(m.toObject, 'classlibrary', 5) Or		;
	  (Ascan(m.laMembers, 'EVENT', 1, -1, 2, 5) = 0) And (Ascan(m.laMembers, 'METHOD', 1, -1, 2, 5) = 0))

Dimension m.laList[m.lnCount, 6]

For lnCount = 1 To m.lnCount
	lcName = m.laMembers[m.lnCount, 1]
	If m.lnColumnCount >= 2
		lcType = Left(Upper(m.laMembers[m.lnCount, 2]), 8)
		If Not m.lcType $ m.lcOKTypes
			Loop
		Endif
		If 0 # Ascan(m.laList, m.lcName, 1, -1, 1, 7)
			Loop
		Endif
		lnIndex	  = m.loPEMs.GetKey(Upper(Trim(m.lcName)))
		lcBmpName = Iif(Upper(m.lcType) = 'PROPERTY', 'PROPTY', m.lcType)

		If _Screen.oISXOptions.UseCKLforPEMs
			lcKeyWord	= _Screen.oISXOptions.oKeywordlist.FixCase(m.lcName, .T.)
		Else
			lcKeyWord   = ''
		Endif

		lnKeyWordIndex = Ascan(_Screen.oISXOptions.Keywordlist, Padr(m.lcName, 30), 1, -1, 1, 7)

		Do Case
			Case Not Empty(m.lcKeyWord)
				lcName	= m.lcKeyWord
				If m.lcType = 'OBJECT' And 'O' = Type('m.toObject.&lcName') And 'C' = Type('m.toObject.&lcName..Name')
					*	m.lcName	= m.toObject.&lcName..Name
					If 'C' = Type('m.toObject.&lcName..BaseClass')
						lcBmpName	= m.toObject.&lcName..BaseClass
					Endif
				Endif
			Case m.lnKeyWordIndex > 0
				lcName	= Trim(_Screen.oISXOptions.Keywordlist[m.lnKeyWordIndex])
			Case m.lnIndex # 0
				lcName	= Trim(m.loPEMs.Item[m.lnIndex].cName)
			Case m.lcType = 'OBJECT' And 'O' = Type('m.toObject.&lcName') And 'C' = Type('m.toObject.&lcName..Name')
				lcName	= m.toObject.&lcName..Name
				If 'C' = Type('m.toObject.&lcName..BaseClass')
					lcBmpName	= m.toObject.&lcName..BaseClass
				Endif
			Otherwise
				lcName	= Proper(m.lcName)
		Endcase
		lnLastRow			   = m.lnLastRow + 1
		laList[m.lnLastRow, 1] = m.lcName

		*!* * Removed 10/2/2012 / JRN
		*!* m.laList[m.lnLastRow, 3] = Proper(m.lcType)
		laList[m.lnLastRow, 4] = m.lcImagesFolder + m.lcBmpName + '.bmp'
		If m.lnColumnCount >= 3
			lcParametersList = m.laMembers[m.lnCount, 3]
			If Inlist(m.lcType, 'EVENT', 'METHOD') Or Not Empty(m.lcParametersList)

				* sometimes that PARAM or LPARAM is stuck onto the beginning		
 					lcWord1		 = Upper(Getwordnum(m.lcParametersList, 1, ' '))
 					Do Case
 						Case 'PROCEDURE ' = m.lcWord1
 							lcNewerProperty = Substr(m.lcParametersList, 11, Len(m.lcName))
 							If m.lcName == Upper(m.lcName)						;
 									Or (Upper(m.lcNewerProperty) = Upper(m.lcName)		;
 									  And CountUpperCase(m.lcNewerProperty) > CountUpperCase(m.lcName))
 								laList[m.lnLastRow, 1] = m.lcNewerProperty
 							Endif
 							lcParametersList = Strextract(m.lcParametersList, '(', ')')
 						Case 'PARAMETERS ' = lcWord1 Or 'LPARAMETERS ' = lcWord1
 							lcParametersList = Substr(m.lcParametersList, 1 + Len(lcWord1))
						Case 'LOCAL ' = lcWord1
 							lcParametersList = ''
 					Endcase
										
				laList[m.lnLastRow, 2] = '(' + Left(m.lcParametersList, 250) + ')'
				laList[m.lnLastRow, 5] = m.lcName + '(' + m.lcParametersList + ')'
			Endif
		Endif

		If m.llPropValues And Inlist(m.lcType, 'PROPERTY')
			Try
				lcValue = Getpem(m.toObject, m.lcName)
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
			laList[m.lnLastRow, 2] = Left('= ' + m.lcValue, 254)
			If m.lnColumnCount >= 4 And Not Empty(m.laMembers[m.lnCount, 4])
				lcValue = m.lcValue + DescriptionDelimiter + m.laMembers[m.lnCount, 4]
			Endif
			laList[m.lnLastRow, 6] = m.lcValue
		Endif && Inlist(m.lcType, 'PROPERTY', 'METHOD')

	Else
		lnIndex	= m.loPEMs.GetKey(Upper(Trim(m.lcName)))
		If m.lnIndex # 0
			lcName = Trim(m.loPEMs.Item[m.lnIndex].cName)
		Endif
		lnLastRow			   = m.lnLastRow + 1
		laList[m.lnLastRow, 1] = m.lcName
	Endif && lnColumnCount >= 2


Next

Dimension m.laList[m.lnLastRow, 6]
lxResult = Createobject('Empty')
AddProperty(m.lxResult, 'aList[1]')
Acopy(laList, m.lxResult.aList)

Return Execscript(_Screen.cThorDispatcher, 'Result=', m.lxResult)


	Procedure CountUpperCase(lcText)
		Return Len(Chrtran(lcText, 'abcdefghijklmnopqrstuvwxyz ', ''))
	EndProc 

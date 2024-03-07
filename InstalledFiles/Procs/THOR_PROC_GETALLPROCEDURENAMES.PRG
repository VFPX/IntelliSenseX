* Creates and returns a list of all Procedure/Function names in Current Project / Path

Local loResult As 'ISXList'
Local laFolders[1], laProcs[1], lcCurDir, lcFolder, lcProcedure, lnCount, lnI

loResult = Createobject('ISXList')
GetISXOptions()

lcCurDir = Fullpath(Curdir())
AddFolder(m.loResult, Addbs(m.lcCurDir))

lnCount = Alines(laFolders, Set('Path'), .T., ';', ',')
For lnI = 1 To m.lnCount
	lcFolder = Fullpath(m.laFolders(m.lnI))
	If (Not Upper(Addbs(m.lcFolder)) == Upper(Addbs(m.lcCurDir))) And Not Empty(m.lcFolder)
		AddFolder(m.loResult, Addbs(m.lcFolder))
	Endif
Endfor

lnCount = Alines(laProcs, Set('Procedure'), .T., ';', ',')
For lnI = 1 To m.lnCount
	lcProcedure = m.laProcs[m.lnI]
	If ' ' $ m.lcProcedure
		lcProcedure = Chrtran(m.lcProcedure, Left(m.lcProcedure, 1), '')
	Endif
	lcProcedure = Forceext(m.lcProcedure, 'PRG')
	AddProcedures(m.loResult, m.lcProcedure)
Endfor

Return Execscript(_Screen.cThorDispatcher, 'Result=', m.loResult)

* ================================================================================
* ================================================================================



Procedure AddFolder(loResult, lcFolder)
	Local laFiles[1], lcStem, lnCount, lnCounter
	If Directory(m.lcFolder, 1)
		lnCount	= Adir(laFiles, m.lcFolder + [*.PRG])
		For lnCounter = 1 To m.lnCount
			lcStem = Juststem(m.laFiles(m.lnCounter, 1))
			lcStem = Evl(_Screen.oISXOptions.oKeyWordList.FixCase(m.lcStem), m.lcStem)
			*!* ******************** Removed 05/04/2020 *****************
			*!* AddRow(m.loResult, m.lcStem, '', 1)
			AddRow(m.loResult, m.lcStem, Lower(Sys(2014, m.laFiles(m.lnCounter, 1))), 1)
			* 	Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetProceduresFromPRG', m.loResult, Filetostr(m.lcFolder + m.lcFName))
		Endfor
	Endif
Endproc


Procedure AddProcedures(loResult, lcProcedure)
	Local laProcs[1], lcCode, lcName, lcRelativePath, lcType, lnCount, lnI
	If File(m.lcProcedure)
		lcCode = Filetostr(m.lcProcedure)
		If Not Empty(m.lcCode)
			lnCount		   = Aprocinfo(laProcs, m.lcProcedure)
			lcRelativePath = Lower(Sys(2014, m.lcProcedure))
			For lnI = 1 To m.lnCount
				lcName = m.laProcs[m.lnI, 1]
				lcType = m.laProcs[m.lnI, 3]
				If m.lcType = 'Procedure' And Not '.' $ m.lcName

					AddRow(m.loResult, m.lcName, m.lcRelativePath)
				Endif
			Endfor
		Endif
	Endif

Endproc


* ================================================================================
* ================================================================================
Procedure AddRow(loResult, lcMethodName, lcFullPathName, lnLineNumber)
	Local lnRow
	lnRow		   = m.loResult.Count + 1
	loResult.Count = m.lnRow
	Dimension m.loResult.aList[m.loResult.Count, 3]

	loResult.aList[m.loResult.Count, 1]	= m.lcMethodName
	loResult.aList[m.loResult.Count, 2]	= Dtoc(Fdate(m.lcFullPathName))
	loResult.aList[m.loResult.Count, 3]	= m.lcFullPathName
Endproc


Define Class ISXList As Custom
	Count = 0
	Dimension aList[1]

	*	Columns in aList
	*		[, 1] = Procedure / Method name
	*		[, 2] = Date modified
	*		[, 3] = Parameters

Enddefine


Procedure GetISXOptions
    Return Execscript (_Screen.cThorDispatcher, 'Thor_Proc_GetISXOptions')
Endproc

 
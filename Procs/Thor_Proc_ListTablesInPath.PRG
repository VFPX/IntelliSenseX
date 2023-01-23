*	Returns an object containing an array named 'aList', which has three columns 
*		[, 1] = Table name
*		[, 2] = Date updated 
*		[, 3] = File size
*
*	Note that each of the columns must be character

Local loList As 'Empty'
Local laFolders[1], lnCount, lnI

loList = Createobject('Empty')
AddProperty(loList, 'aList[1]')
AddProperty(loList, 'Count', 0)

AddFolder(Curdir(), loList)
lnCount = Alines(laFolders, Set('Path'), .T., ';', ',')
For lnI = 1 To lnCount
	If Not Empty(laFolders(lnI))
		AddFolder(laFolders(lnI), loList)
	Endif
Endfor

**********************************************************
*** Away we go
**********************************************************
If loList.Count > 0
	Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ISX', 'VAR', '', .T., loList, .T.)
Endif


Procedure AddFolder(lcFolder, loList)
	Local laFiles[1], lcAlias, lcDate, lcFileName, lnCount, lnCounter, loResult
	If Directory(lcFolder, 1)
		lnCount	= Adir(laFiles, Addbs(lcFolder) + [*.DBF])
		For lnCounter = 1 To lnCount
			lcAlias = Juststem(laFiles(lnCounter, 1))
			If loList.Count = 0 Or 0 = Ascan(loList.aList, lcAlias, 1, -1, 1, 7)
				loList.Count = loList.Count + 1
				Dimension loList.aList[loList.Count, 3]
				lcDate						  = Dtoc(laFiles[lnCounter, 3], 1)
				loList.aList[loList.Count, 1] = Proper(lcAlias)
				loList.aList[loList.Count, 2] = Left(lcDate, 4) + '-' + Substr(lcDate, 5, 2) + '-' + Right(lcDate, 2)
				loList.aList[loList.Count, 3] = Alltrim(Transform(laFiles[lnCounter, 2], '9,999,999,999'))
			Endif
		Endfor
	Endif
Endproc

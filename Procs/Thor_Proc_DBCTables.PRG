Lparameters tcDBCName

Local loList As 'Empty'
Local laDBCList[1], laDEList[1], lnColumnCount, lnCount, lnDEList, lnDNCList, lnI

loList = Createobject('Empty')
AddProperty(loList, 'aList[1]')
lnCount		  = 0
lnColumnCount = 1

* --------------------------------------------------------------------------------
* Any tables in DBC
lnDNCList = Execscript(_Screen.cThorDispatcher, 'THOR_PROC_GetDBCTablesList', tcDBCName, @laDBCList)
If lnDNCList # 0
	Acopy(laDBCList, loList.aList)
	lnCount		  = lnDNCList
	lnColumnCount = 2
Endif

* --------------------------------------------------------------------------------
* and any in Data Environment
lnDEList  = Execscript(_Screen.cThorDispatcher, 'THOR_PROC_GetDataEnvironmentList', tcDBCName, @laDEList)

If lnDEList # 0
	For lnI = 1 To lnDEList
		lnCount = lnCount + 1
		Dimension loList.aList[lnCount, lnColumnCount]
		loList.aList[lnCount, 1] = laDEList[lnI]
		If lnColumnCount = 2
			loList.aList[lnCount, 2] = 'DE'
		Endif
	Endfor && lnI = 1 to lnDEList
Endif && lnDEList # 0

* --------------------------------------------------------------------------------
* Away we go
If lnCount > 0
	Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ISX', 'VAR', '', .T., loList, .T.)
Endif


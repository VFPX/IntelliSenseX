* 	Creates dropdown (a la IntellisenseX) in the current code window for the array

*	Columns in laISXList (only the first is required)
*		[, 1] = Property Name (UPPER -- not displayed)
*		[, 2] = Display (1st column)
*		[, 3] = Display (2nd column)
*		[, 4] = Display (3rd column)
*		[, 5] = Image name
*		[, 6] = Parameters (in parens)

Parameters laISXList

Local loList As 'Empty'

loList = Newobject('Empty')
AddProperty(m.loList, 'Count', Alen(m.laISXList, 1)) 
AddProperty(m.loList, 'aList[1]')
Acopy(laISXList, m.loList .aList)

Execscript(_Screen.cThorDispatcher, 'Thor_Proc_ISX', 'VAR', '', .T., m.loList, .T.)

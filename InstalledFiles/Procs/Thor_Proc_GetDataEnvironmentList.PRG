Lparameters tcDBCName, taDestArray

* tools home page = https://github.com/VFPX/Thor/blob/master/Docs/Thor_tools_object.md
Local loTools As Pemeditor_tools Of 'c:\visual foxpro\programs\9.0\common\thor\tools\apps\pem editor\source\peme_tools.vcx'
Local laDataEnvironment[1], lcAlias, lnCount, lnX, loCurrent, loDataEnvironment, loFormObject
loTools = Execscript(_Screen.cThorDispatcher, 'Class= tools from pemeditor')

loFormObject = loTools.GetCurrentObject(.T.)
lnCount		 = 0

If Not Isnull(loFormObject) And 0 # Aselobj(laDataEnvironment, 2)
	loDataEnvironment = laDataEnvironment[1]
	For lnX = 1 To 1000
		If 'O' # Type('loDataEnvironment.Objects(lnX)')
			Exit
		Else
			loCurrent = loDataEnvironment.Objects(lnX)
			lcAlias	  = Lower(loCurrent.Alias)
			lnCount	  = lnCount + 1
			Dimension taDestArray[lnCount]
			taDestArray[lnCount] = lcAlias
		Endif
	Endfor
Endif

Return Execscript(_Screen.cThorDispatcher, 'Result=', lnCount)
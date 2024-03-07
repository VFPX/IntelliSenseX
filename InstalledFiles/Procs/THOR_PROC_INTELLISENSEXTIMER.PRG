#Define ccPropertyName  'oIntellisenseXTimer'
#Define ccClassName		'IntellisenseXTimer'

Lparameters tcAction

Local lcAction
lcAction = Proper(Evl(tcAction, 'Start'))

Do Case
	Case lcAction = 'Start'
		StopTimer()
		StartTimer()
	Case lcAction = 'Stop'
		StopTimer()
	Otherwise
		Return Execscript(_Screen.Cthordispatcher, 'Result=', ToggleTimer())
Endcase

Return

* ==========================================
Procedure StartTimer
	_Screen.AddProperty(ccPropertyName, Newobject(ccClassName))
Endproc

* ==========================================
Procedure StopTimer
	_Screen.AddProperty(ccPropertyName, Null)
Endproc

* ==========================================
Procedure ToggleTimer
	Local lcPropertyName
	lcPropertyName = ccPropertyName
	If Type([_Screen.] + lcPropertyName) = 'O' And Vartype(_Screen.&lcPropertyName) = 'O'
		StopTimer()
		Return .F.
	Else
		StartTimer()
		Return .T.
	Endif
Endproc


* ==========================================
* ==========================================
Define Class ccClassName As Custom

	cISXPRG = ''
	Procedure Init
		Local lcPRG
		lcPRG		 = Execscript(_Screen.Cthordispatcher, 'Full Path=Thor_Proc_ISX')
		This.cISXPRG = lcPRG
		This.Newobject('Timer', 'ISXTimer')
	Endproc

Enddefine

Define Class ISXTimer As Timer

	Interval = 1000
	Enabled	 = .T.

	* ==========================================
	Procedure Timer
		Local lcOnKeyDot, lcPRG, llCodeWindow

		llCodeWindow = This.GetWindowType() >= 0
		lcOnKeyDot	 = On('Key', '.')

		Do Case
			Case _Screen.lThorDebuggerOpen and Wexist('Debugger') && Edy 
				StopTimer()
			
			Case llCodeWindow =(Not Empty(lcOnKeyDot))

			Case llCodeWindow
				This.StartOnKeyDot()
			Otherwise
				This.StopOnKeyDot()
		Endcase

	Endproc

	* ==========================================
	Procedure Destroy
		This.StopOnKeyDot()
	Endproc

	* ==========================================
	Procedure StartOnKeyDot
		Local lcPRG
		lcPRG = This.Parent.cISXPRG
		On Key Label . Do [&lcPRG] With 'VAR,OBJ,TABLE,THOR', '.'
	Endproc

	* ==========================================
	Procedure StopOnKeyDot
		On Key Label .
	Endproc

	* ==========================================
	Procedure GetWindowType
		Local laEnv[25], llResult, lnHandle, lnResult

		If Not 'FOXTOOLS.FLL' $ Upper(Set('Library'))
			Set Library To(Home() + 'FoxTools.Fll') Additive
		Endif
		lnHandle = _WonTop()

		Try
			llResult = _EdGetEnv(lnHandle, @laEnv)
		Catch
			llResult = -1
		Endtry

		If llResult > 0
			Return laEnv[25]
		Else
			Return - 1
		Endif

	Endproc

Enddefine

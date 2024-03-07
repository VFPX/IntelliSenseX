Lparameters loResult, lcCodeSource, llGetParameters

Local laList[1], lcParameterList, lcProcCode, llWithinAClass, lnI, lnLength, loProc, loProcs

loProcs		   = _oPEMEditor.oUtils.GetProcedureStartPositions(m.lcCodeSource)
llWithinAClass = .F.
For lnI = 1 To m.loProcs.Count
	loProc = m.loProcs[m.lnI]
	Do Case

		Case m.loProc.Type = 'Class'
			llWithinAClass	  = .T.

		Case m.loProc.Type = 'Class'
			Exit

		Case m.loProc.Type = '-End'

		Case m.llWithinAClass

		Otherwise
			loResult.Count = m.loResult.Count + 1
			Dimension m.loResult.aList[m.loResult.Count, 5]
			loResult.aList[m.loResult.Count, 1]	= m.loProc.Name

			If m.lnI < m.loProcs.Count
				lnLength = m.loProcs[m.lnI + 1].StartByte - m.loProc.StartByte
			Else
				lnLength = Len(m.lcCodeSource) - m.loProc.StartByte
			Endif

			If m.llGetParameters
				lcProcCode							= Substr(m.lcCodeSource, m.loProc.StartByte, m.lnLength)
				lcParameterList						= Execscript(_Screen.cThorDispatcher, 'Thor_Proc_GetParameters', m.lcProcCode)
				loResult.aList[m.loResult.Count, 2]	= m.lcParameterList
				loResult.aList[m.loResult.Count, 5]	= m.loProc.Name + '(' + m.lcParameterList + ')'
			Endif
	Endcase
Endfor

Return Execscript(_Screen.cThorDispatcher, 'Result=', m.loResult)

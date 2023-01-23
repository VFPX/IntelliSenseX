Lparameters tcCodeSource, tnSelStart

Local lcResult, lnI, lnLength, loProc, loProcs
m.loProcs		 = ExecScript(_Screen.cThorDispatcher, 'Thor_Proc_GetFullStartPositions', tcCodeSource)

m.lcResult = Null
For m.lnI = m.loProcs.Count To 1 Step - 1
	m.loProc = m.loProcs[m.lnI]
	If m.loProc.StartByte <= m.tnSelStart
		Do Case
			Case m.loProc.Type = 'Class'
				m.lcResult = ''
				Exit
			Case m.loProc.Type = '-End'
				m.lcResult = ''
				Exit
			Otherwise
				If m.lnI = m.loProcs.Count
					m.lnLength = Len(m.tcCodeSource) - m.loProc.StartByte
				Else
					m.lnLength = m.loProcs[m.lnI + 1].StartByte - m.loProc.StartByte
				Endif
				m.lcResult = Substr(m.tcCodeSource, m.loProc.StartByte + 1, m.lnLength)
				Exit
		Endcase
	Endif && loProc.StartByte <= lnSelStart
Endfor

Do Case
	Case Not Isnull(m.lcResult)
	
	Case m.loProcs.Count = 0
		m.lcResult = m.tcCodeSource
	Otherwise
		m.lnLength = m.loProcs[1].StartByte
		m.lcResult = Left(m.tcCodeSource, m.lnLength)
Endcase

Return Execscript(_Screen.cThorDispatcher, 'Result=', m.lcResult) 
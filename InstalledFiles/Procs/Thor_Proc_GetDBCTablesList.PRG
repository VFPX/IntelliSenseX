Lparameters tcDBCName, taDestArray

**********************************************************
*** Determine the DBC
*** taDestArray comes in by reference
**********************************************************

Local lcDBC, lnCount
Do Case
	Case Empty(tcDBCName) And Empty(Dbc())
		lcDBC = ''

	Case Empty(tcDBCName) Or Upper(tcDBCName) == Upper(Juststem(Dbc()))
		lcDBC = Dbc()

	Otherwise
		lcDBC = tcDBCName + '.dbc'

Endcase

**********************************************************
*** Get the list of Tables and Views
**********************************************************
lnCount		  = 0
If Not Empty(lcDBC)
	Try
		Select  objectname,											;
				objecttype											;
			Where Inlist(Upper(objecttype), 'TABLE', 'VIEW')		;
				From(lcDBC)											;
			Into Array taDestArray
		lnCount		  = _Tally
	Catch
	Endtry
Endif

Return Execscript(_Screen.cThorDispatcher, 'Result=', lnCount)
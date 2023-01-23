#Define CRLF Chr[13] + Chr[10]

Define Class cKeyWordList As Session
	cKeyWordList = ''

	Procedure Init
		Set Ansi On
		This.CreateReservedWordsCursor()
		This.OpenMyKeywordList()
	Endproc


	Procedure Destroy
		Local loException
		If Used('KeyWordList')
			Select KeyWordList
			Locate For Deleted()
			If Found()
				Try
					Use (Dbf()) Exclusive
					Pack
				Catch To loException

				Endtry
			Endif
		Endif
	Endproc


	Procedure CreateReservedWordsCursor
		Use Home() + 'WIZARDS\FDKEYWRD' Order TOKEN Again Shared In 0 Alias Keywords
		Select  Distinct TOKEN    As  Keyword		;
			From Keywords							;
			Where Isalpha(TOKEN)					;
				Or Left(TOKEN, 1) = '_'				;
			Order By 1								;
			Into Cursor crsr_ReservedWords Readwrite
		Index On Upper(Keyword) Tag Keyword

		Use In Keywords
	Endproc

	Procedure OpenMyKeywordList
		Local lcFilename, lcToolFolder, loException
		lcToolFolder = Execscript(_Screen.cThorDispatcher, 'Tool Folder=')
		lcFilename	 = Addbs(lcToolFolder) + 'My Tools\KeywordList.DBF'
		If File (lcFilename)
			Try
				Use (lcFilename) In 0 Order Keyword Again Shared Alias KeywordList
				If Empty(Field('Locked', 'KeywordList'))
					Select Keywordlist
					Use (lcFileName) Exclusive
					Alter table (lcFileName) add column Locked L
					Use 
					Use (lcFilename) In 0 Order Keyword Again Shared Alias KeywordList
				EndIf 
			Catch To loException
				Messagebox('Unable to open Customer Keywords Table' + Chr(13) + Chr(13) + loException.Message + Chr(13) + Chr(13) + lcFilename, 16, 'Unable to open Custom Keywords Table')
			Endtry
		Else
			Create Table (lcFilename) (Keyword C(60), Locked L)
			Index On Upper(Keyword) Tag Keyword
		Endif
	Endproc


	Procedure FixCase(tcKeyword, llReservedWords)
		Local lcKeyword
		lcKeyword = Upper(Trim(tcKeyword)) + ' '
		Do Case
			Case Used('KeywordList') And Seek(lcKeyword, 'KeywordList')
				Return Trim(KeyWordList.Keyword)
			Case llReservedWords And Seek(lcKeyword, 'crsr_ReservedWords')
				Return Trim(crsr_ReservedWords.Keyword)
			Otherwise
				Return ''
		Endcase
	Endproc


	Procedure IsLocked(tcKeyword)
		Local lcKeyWord
		lcKeyWord = Upper(Trim(tcKeyword)) + ' '
		If Used('KeywordList') And Seek(lcKeyWord, 'KeywordList')
			Return KeyWordList.Locked
		Else
			Return .F.
		Endif
	Endproc
	

	Procedure IsReservedWord(tcKeyword)
		Local lcKeyword
		lcKeyword = Upper(Trim(tcKeyword)) + ' '
		Return Seek(lcKeyword, 'crsr_ReservedWords')
	Endproc


	Procedure UpdateWord(tcKeyword, llReplaceReservedWord, llPromptBeforeChanging, tlLocked)
		Local lcKeyWord, loAddWordstoCKL
		lcKeyWord = Upper(Trim(tcKeyword)) + ' '
		Do Case
			Case Empty(lcKeyWord) Or 'C' # Vartype(lcKeyWord)
				Return - 1
			Case Seek(lcKeyWord, 'crsr_ReservedWords') And Not llReplaceReservedWord
				Return 0
			Case Not Used('KeywordList')
				Return - 2
			Case Seek(lcKeyWord, 'KeywordList')
				If llPromptBeforeChanging And KeyWordList.Keyword # tcKeyword
					loAddWordstoCKL = Execscript(_Screen.cThorDispatcher, 'Class= clsAddWordstoCKL from Thor_Proc_AddWordsToCKL.PRG')
					With loAddWordstoCKL
						.ProcessText(tcKeyword)
						.PostProcessing(.T.)
					Endwith
					Return 3
				Else
					Replace KeyWordList.Keyword With tcKeyword In KeyWordList
					If Pcount()>= 4
						Replace KeyWordList.Locked With tlLocked In KeyWordList					
					EndIf 
					This.cKeyWordList = ''
					Return 1
				Endif
			Otherwise
				Insert Into KeyWordList Values(tcKeyword, tlLocked)
				This.cKeyWordList = ''
				Return 2
		Endcase
	Endproc
	

	Procedure BrowseKeywordList
		If Used('KeyWordList')
			Select KeyWordList
			Goto Top
			Browse Normal Nowait
		Else
			Messagebox("Unable to find table KeywordList in 'My Tools'", 16, "Can't open table")
		Endif
	Endproc


	Procedure GetKeywordList
		Local lcResult
		If Empty(This.cKeyWordList)
			lcResult = ''
			Select KeyWordList
			Scan
				lcResult = lcResult + Trim(Keyword) + CRLF
			Endscan
			This.cKeyWordList = lcResult
		Endif
		Return This.cKeyWordList
	Endproc

Enddefine

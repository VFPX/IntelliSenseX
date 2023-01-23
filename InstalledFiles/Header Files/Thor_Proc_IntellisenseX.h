#Define     DEBUGGING		.F.

#If DEBUGGING
	#Define SAVEDEBUGINFO SaveDebugger(Program(), Lineno(1), Lineno())
#Else
	#Define	SAVEDEBUGINFO
#Endif

#Define 	CommandWindow	0
#Define		PRGFile			1
#Define		ModifyFile		2
#Define		MenuCode		8
#Define		MethodCode		10
#Define		DBCCode			12

#Define cnMaxColumn2Width 400

#Define NOMATCHFOUND 			' <no matches>'
* Characters which terminate popup and show current selection; the dot is conditional
#DEFINE POPUP_TERMINATION_CHARS " ()[=+-*/%,].'"
* Characters which also have a space before them
#DEFINE EXTRA_SPACE_LIST		'+-*$/%<>=!^;'

#Define ccTab chr[9]

#Define DoubleAmps ('&' + '&')
#Define DescriptionDelimiter '&|&'

#Define BACKSPACE	127
#Define LEFTARROW   19

#Define SQLKeywords ' inner outer left right full join on with where group union having order into to '
#Define ObjectAnnotation	'_Def'

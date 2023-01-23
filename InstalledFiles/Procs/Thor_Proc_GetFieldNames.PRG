Lparameters laFields, laResult, tnFieldNamesCase, lcAlias

* Arrays are passed in by Reference
* laFields is array of field names from AFields
* laResult is re-dimensioned below to have three columns
*  [;1] = Field name, with case changed as desired
*  [;2] = Type for the field -- like 'C(20)' or 'N(10,2)'
*  [;3] = No longer used

Local laTypes[1], lcField, lcType, lnCount, lnFieldCount, lnRow

lnFieldCount = Alen(laFields, 1)
Dimension laResult[lnFieldCount, 3]
Alines(laTypes, 'Integer, Date, Time, Logical', 5, ',')

For m.lnCount = 1 To lnFieldCount
	m.lcField			   = FixFieldNameCase(m.laFields[m.lnCount, 1], tnFieldNamesCase, lcAlias)
	laResult[m.lnCount, 1] = Alltrim(m.lcField)
	m.lcType			   = m.laFields[m.lnCount, 2]
	Do Case

		Case laFields[m.lnCount, 2] = 'C'
			m.lcType			   = m.lcType + '(' + Transform(m.laFields[m.lnCount, 3]) + ')'

		Case laFields[m.lnCount, 2] = 'N' And laFields[m.lnCount, 4] = 0
			m.lcType			   = m.lcType + '(' + Transform(m.laFields[m.lnCount, 3]) + ')'

		Case laFields[m.lnCount, 2] = 'N'
			m.lcType			   = m.lcType + '(' + Transform(m.laFields[m.lnCount, 3]) + ',' + Transform(m.laFields[m.lnCount, 4]) + ')'

		Case laFields[m.lnCount, 2] = 'B'
			m.lcType			   = m.lcType + '(' + Transform(m.laFields[m.lnCount, 4]) + ')'

	Endcase
	laResult[m.lnCount, 2] = m.lcType
Next
Return


Procedure FixFieldNameCase(tcName, tnFieldNamesCase, tlAlias)
	Local lcField

	m.lcField = _Screen.oISXoptions.oKeywordlist.FixCase(tcName, .F.)
	If Not Empty(m.lcField)
		Return m.lcField
	Endif

	m.lcField = tcName
	Do Case
		Case Empty(tnFieldNamesCase)

		Case tnFieldNamesCase = 1
			m.lcField = Lower(m.lcField)
		Case tnFieldNamesCase = 2
			m.lcField = Upper(m.lcField)
		Case tnFieldNamesCase = 3
			m.lcField = Proper(m.lcField)
		Case tnFieldNamesCase = 4
			m.lcField = Lower(Left(m.lcField, 1)) + Proper(Substr(m.lcField, 2))
	Endcase
	Return m.lcField
Endproc


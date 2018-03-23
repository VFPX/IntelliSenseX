## Thor IntellisenseX for SQL Tables

IntellisenseX can be used to display the fields in SQL tables, although doing so requires customization on your part.

The sample below accesses a table from a SQL server database:

![](images/thor_intellisensex_sql_table_snaghtmlbe1d5e2.png)

Customization is achieved by modifying a Plug-in PRG.

The Plug-In is called when IntellisenseX has exhausted all other possible interpretations of the text before the dot. In this example, it is called with “soheader” as a parameter, and the Plug-In is free to determine the list of items to appear in the dropdown. In particular, it can use SQLColumns to determine the fields in the table or read the list of fields from a data dictionary.

See [plug-in PRG for handling names that may be of SQL tables or data objects](Thor_IntellisenseX_Implicit_Tables.md).

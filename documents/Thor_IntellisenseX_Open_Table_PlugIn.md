## Thor IntellisenseX Plug-In for Opening Tables

Thor provides a number of Plug-In PRGs to alter or enhance the behaviors of some of the Thor Tools. You can create or edit Plug-Ins by using the Manage Plug-Ins menu item in the Thor menu:

![](images/thor_intellisensex_for_open_table_image_2.png)

The Plug-In used by IntellisenseX to open tables is also used by a number of other tools, as shown below.

![](images/thor_intellisensex_open_table_plugin_snaghtmlaee7c2a.png)

The default behavior of OpenTable is to try to USE the table (which will work if the table name is in the path) or, if not found, look for the table in the MRU list for DBFs. If this behavior does not meet your needs, click Edit to create your own local copy of the PRG which you can edit as necessary.

The PRG takes a single parameter which is the name of the table to be opened. It must return the alias of the table that it opened (if any), using this rather odd looking construction required of Plug-In PRGs:

```foxpro
Return Execscript (_Screen.cThorDispatcher, 'Result=', lcReturn)
```


Example of alternative use of OpenTable: In a particular installation, all table names and the folders they are found in are themselves stored in a table, where the alias is used as a key to the table.  These tables are only opened within a single PRG which takes the alias as a parameter. In this case, OpenTable was modified to call this PRG to open the table instead of using a simple USE statement.
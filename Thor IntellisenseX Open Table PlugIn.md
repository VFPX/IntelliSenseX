<p><font size="5">Thor IntellisenseX Plug-In for Opening Tables</font></p>
<p>Thor provides a number of Plug-In PRGs to alter or enhance the behaviors of some of the Thor Tools. You can create or edit Plug-Ins by using the Manage Plug-Ins menu item in the Thor menu:</p>
<p><img border="0" src="Thor%20IntellisenseX%20Open%20Table%20PlugIn_image_2.png" width="561" height="271" style="border-right-width:0px; padding-left:0px; padding-right:0px; display:inline; border-top-width:0px; border-bottom-width:0px; border-left-width:0px; padding-top:0px"></p>
<p>The Plug-In used by IntellisenseX to open tables is also used by a number of other tools, as shown below.
</p>
<p><img border="0" src="Thor%20IntellisenseX%20Open%20Table%20PlugIn_SNAGHTMLaee7c2a.png" width="925" height="400" style="border-right-width:0px; padding-left:0px; padding-right:0px; display:inline; border-top-width:0px; border-bottom-width:0px; border-left-width:0px; padding-top:0px"></p>
<p>The default behavior of OpenTable is to try to USE the table (which will work if the table name is in the path) or, if not found, look for the table in the MRU list for DBFs. If this behavior does not meet your needs, click Edit to create your own local
 copy of the PRG which you can edit as necessary.</p>
<p>The PRG takes a single parameter which is the name of the table to be opened. It must return the alias of the table that it opened (if any), using this rather odd looking construction required of Plug-In PRGs:</p>
<p><font face="Courier New">Return Execscript (_Screen.cThorDispatcher, 'Result=', lcReturn)</font></p>
<p>Example of alternative use of OpenTable: In a particular installation, all table names and the folders they are found in are themselves stored in a table, where the alias is used as a key to the table.&nbsp; These tables are only opened within a single PRG
 which takes the alias as a parameter. In this case, OpenTable was modified to call this PRG to open the table instead of using a simple USE statement.</p>

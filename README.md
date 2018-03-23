# Thor IntellisenseX

## Introduction
<p><em>IntellisenseX</em> refers to a suite of Thor Tools that provide functionality similar to native Intellisense. These tools display lists of available variable names, field names, or members (properties, events, methods, and objects) while you type code, just like Intellisense. However, they cover those areas that Intellisense forgot (such as the list of field names in a table when editing in a code window) and provide new capabilities, available through customization, such as displaying the list of field names in an SQL table, as shown below</p>


![](documents/images/thor_intellisensex_examples_snaghtmlf871ea8.png)

<p><a name="Videos"></a></p>
<p><font size="4"><strong>Videos</strong></font></p>
<ol>
<li><font color="#ff0000"><a href="http://bit.ly/Q3izOd">Getting started</a></font> <font color="#000000">(5:23)</font></li>
<li><font color="#ff0000"><a href="http://bit.ly/SmMeQw">Using and configuring the dropdown box</a></font><font color="#000000"> (4:01)</font></li>
<li><font color="#ff0000"><a href="http://www.youtube.com/watch?v=lPmFwa4WeJ8&amp;hd=1&amp;rel=0">Fields from tables</a></font> (9:29)</li>
<li><font color="#ff0000"><a href="http://www.youtube.com/watch?v=9TUvouhSU6Y&amp;hd=1&amp;rel=0">Properties and methods from objects</a></font><font color="#000000"> (5:14)</font></li>
<li><font color="#ff0000"><a href="http://www.youtube.com/watch?v=4lv4FoU2XEA&amp;hd=1&amp;rel=0">Indirect table and object references and the Alias directive</a></font> <font color="#000000">(3:51) </font></li>
<li><font color="#ff0000"><a href="http://bit.ly/P73dWr">Variables (LOCAL and otherwise) list</a>&nbsp;</font><font color="#000000">(5:28) </font></li>
<li><font color="#ff0000"><a href="http://bit.ly/SmM9fA">Constants (#Defines) list</a>&nbsp;</font><font color="#000000">(3:18) </font></li>
<li><font color="#ff0000"><a href="http://bit.ly/Rj9zpQ">Setting ControlSource in PEM Editor</a></font><font color="#000000"> (2:25)</font></li>
<li><font color="#ff0000"><a href="https://www.youtube.com/watch?v=6x9BraGybXY">Known issues</a></font><font color="#000000"> (7:00)</font></li>
<li><a href="http://www.youtube.com/watch?v=71psd6RH2Ls&amp;hd=1&amp;rel=0">&ldquo;IntellisenseX by Dot&rdquo; vs &ldquo;IntellisenseX by Hot Key&rdquo;</a> (3:29)</li>
<li><a href="http://www.youtube.com/watch?v=UGyqlInAfvc&amp;hd=1&amp;rel=0">Managing Plug-Ins: OpenTable and Intellisense</a><font color="#ff0000"><font color="#000000"> (5:34)</font> </font></li>
</ol>

## Installation Instructions
<p>IntellisenseX is downloaded and installed as part of the Check For Updates process for <a href="http://github.com/VFPX/Thor"> Thor</a>.</p>

## Thor Tools
<p>IntellisenseX is implemented through the use of four tools:</p>
<ul>
<li><strong>IntellisenseX by Dot</strong> is the main tool. Once executed, IntellisenseX is activated any time you press a period (dot), the same as for native Intellisense. The tool is actually a toggle. If you execute it a second time, the On Key Label is removed, and typing a dot simply works like normal. (Unfortunately, there is an undesirable side effect to this technique of executing code when you press a dot, which is why you may want to turn off Intellisense by Dot from time to time. See <a href="Thor%20Intellisense%20Dot%20Glitch.md"> glitch when using Intellisense by Dot</a>. )</li>
<li><strong>IntellisenseX by Hot Key</strong> is the twin of <strong>IntellisenseX by Dot</strong>, except that it is activated differently, by using a hot key (which you define in Thor) instead of a dot. To activate the tool, press the hot key <u>after</u> you press the dot. This tool is available because of the <a href="Thor%20Intellisense%20Dot%20Glitch.md"> glitch when using Intellisense by Dot</a>.</li>
<li><strong>Dropdown Variables List</strong> provides a list of local variables for those who do not use MDot (m.)</li>
<li><strong>Dropdown Constants List</strong> provides a list of constants (created by #Define and #Include)</li>
</ul>
<p>Like all Thor tools, these tools can be executed in a number of different ways, such as by using the Tool Launcher, as shown below, or by user-assigned hot keys.</p>

![](documents/images/Thor_IntellisenseX_Examples_image_4.png)

## Examples of IntellisenseX

<p>Unless otherwise noted, all examples provided are enabled by a single execution of the tool &ldquo;IntellisenseX by dot&rdquo;.</p>
<p><a name="top"></a></p>
<p>The following is a summary of the different types of dropdown lists available:</p>
<p>Field names:</p>
<ul>
<li><a href="#SampleFieldsFromTable">Fields from an open table (or view).</a></li>
<li><a href="#SampleFieldsFromClosedTable">Fields from an table that is not open (but is in the path).</a></li>
<li><a href="#SampleFieldsSelectAlias">Fields from a local_alias in an SQL statement.</a></li>
<li><a href="#SampleFieldsSQL">Fields from a SQL Server table</a></li>
<li><a href="#SampleFieldsDataObject">Fields from a Data Object</a></li>
</ul>
<p>Property and Method names (PEMs) from objects:</p>
<ul>
<li><a href="#SampleFieldsBetweenWith">PEMs for objects referenced between WITH / ENDWITH</a></li>
<li><a href="#SampleFieldsPRGClasses">PEMS referenced in PRG-based classes</a></li>
</ul>
<p>Indirect references:</p>
<ul>
<li><a href="#SampleObjectReference">Indirect object references</a></li>
<li><a href="#SampleAliasReferences">*#Alias directive for tables and objects</a></li>
</ul>
<p>Variables (local and otherwise):</p>
<ul>
<li><a href="#SampleMDot">Variables from MDot.</a></li>
<li><a href="#SampleHotKeyLocals">Variables using a hot key.</a></li>
</ul>
<p>Other:</p>
<ul>
<li><a href="#SampleConstants">Listing Constants (created by #Define and #Include)</a></li>
<li><a href="#SamplePEMEditor">Setting ControlSources in PEM Editor</a></li>
</ul>
<p><a href="Thor%20IntellisenseX%20Configuration%20Options.md">Configuration Options</a></p>
<p><a href="Thor%20IntellisenseX%20Customization.md">Customization</a></p>
<hr />
<h3><a name="SampleFieldsFromTable"></a>Fields from an open table (or view)</h3>
<p>If a table (or view) is open, the dropdown list shows the list of fields as well as their data type and field width.</p>
<p><img style="margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; padding-top: 0px; border-width: 0px;" src="Thor%20IntellisenseX%20Examples_SNAGHTML655319b.png" width="697" height="304" border="0" /></p>
<p><a href="#top">Back to top</a></p>
<hr />
<h3><a name="SampleFieldsFromClosedTable"></a>Fields from an table that is not open (but is in the path)</h3>
<p>If the alias for the table is not in use, the path is searched for a DBF of that name; if found, the table is opened and its fields are listed.</p>
<p>This particular algorithm for opening tables might not be sufficient for your needs (you might, for instance, open tables from a folder not in the path during development). If so, you can customize the way that tables are opened; see the OpenTable PRG in <a href="http://http://github.com/VFPX/Thor/PlugIns">Thor Plug-In Prgs</a>.</p>

![](documents/images/Thor_IntellisenseX_Examples_SNAGHTML65a1036.png)
<p><a href="#top">Back to top</a></p>
<hr />
<h3><a name="SampleFieldsSelectAlias"></a>Fields from a local_alias in an SQL statement</h3>
<p>If a local_alias is used in an SQL statement, the fields from the actual table (or alias) are shown. This does not apply to sub-queries (yet).</p>

![](documents/images/Thor_IntellisenseX_Examples_SNAGHTML664d1b1.png)

<p><a href="#top">Back to top</a></p>
<hr />
<h3><a name="SampleFieldsSQL"></a>Fields from a SQL Server table</h3>
<p>The fields from an SQL Server table (&ldquo;soheader&rdquo; in the example below) can be displayed. This requires customization of a plug-in PRG (managed by Thor) that accesses the structure of the table. This can be done a few different ways, including using SQLColumns() or accessing a dictionary of the fields and in an SQL database.</p>
<p>This feature is <u>only</u> available if you do some customization so that you can return to Intellisense a list of field names associated with a given SQL table name (&ldquo;soheader&rdquo; in the example). See the Intellisense PRG in <a href="http://github.com/VFPX/Thor/PlugIns">Thor Plug-In Prgs</a>.</p>

![](documents/images/Thor_IntellisenseX_Examples_SNAGHTMLf871ea8.png)

<p><a href="#top">Back to top</a></p>
<hr />
<h3><a name="SampleFieldsDataObject"></a>Fields from a Data Object</h3>
<p>IntellisenseX can be used to display the fields from data objects that are based on an underlying table in a business object or in a form or visual class based on an underlying table, although doing so requires customization on your part.</p>
<p>The sample below accesses the underlying table that the current class is based on (found in &ldquo;This.cAlias&rdquo;) whenever &ldquo;This.oData.&rdquo; is entered.</p>
<p>This feature is <u>only</u> available if you do some customization so that Intellisense can associate a code snippet(&ldquo;This.odata&rdquo; in the example) with a table alias (&ldquo;MasterPartsList&rdquo;).&nbsp; See the Intellisense PRG in <a href="http://github.com/VFPX/Thor/PlugIns">Thor Plug-In Prgs</a>.</p>
![](documents/images/Thor_IntellisenseX_Examples_image_8.png)
<p><a href="#top">Back to top</a></p>
<hr />
<h3><a name="SampleFieldsBetweenWith"></a>PEMs for objects referenced between WITH / ENDWITH</h3>
<p>When using a &ldquo;WITH&rdquo; phrase (&ldquo;With loObject&rdquo;), if you do not use &ldquo;as&rdquo; (&ldquo;With loObject <strong>as</strong> Textbox&rdquo;), the only object for which FoxPro provides Intellisense in methods for visual classes is THIS:</p>

![](documents/images/Thor_IntellisenseX_Examples_SNAGHTML130f05dd.png)

<p>This feels like an incomplete implementation, as there are a number of other objects for which it would seem that Intellisense would work:</p>
<ul>
<li>With ThisForm</li>
<li>With This.Parent</li>
<li>With This.Parent.cboMaintTable</li>
<li>With Thisform.PageFrame.Pages[1]</li>
</ul>
<p>These are all provided for by IntellisenseX, as shown in the following image:</p>

![](documents/images/Thor_IntellisenseX_Examples_SNAGHTML13106da4.png)
<p>Note as well the parameters list that appears in the second column. Once you have selected a method from the listbox, pressing Ctrl+Enter will insert both the method name and parameters into your code.</p>
<p>In addition, IntellisenseX also recognizes a number of other references to objects that follow WITH: see <a href="#SampleFieldsDataObject">Fields from a Data Object</a>, <a href="#SampleObjectReference"> Indirect object references</a>, and <a href="#SampleAliasReferences">*#Alias directive for tables and objects</a>.</p>

![](documents/images/Thor_IntellisenseX_Examples_SNAGHTML131db30d.png)
<p><a href="#top">Back to top</a></p>
<hr />
<h3><a name="SampleFieldsPRGClasses"></a>PEMS referenced in PRG-based classes</h3>
<p>FoxPro provides Intellisense for THIS in PRG-based classes in a limited way: it might not show custom properties or methods in the class being edited at all (as shown below), if it does will not display them in the same case as they are defined, and the list is not updated as new properties or methods are added.</p>

![](documents/images/Thor_IntellisenseX_Examples_SNAGHTML143d7097.png)
<p>IntellisenseX provides an alternative that shows <u>only</u> the properties and methods defined in the current class (no inherited or native properties or methods, unless defined in the class), in their correct case. This list is always current as properties or methods are added. (Depending on interest, this list may be extended to include inherited properties and methods.)</p>
<p>This feature is disabled by default; to enable it, see <a href="Thor%20IntellisenseX%20Configuration%20Options.md#SamplePRGClasses"> Configuration Options</a>.</p>

![](documents/images/Thor_IntellisenseX_Examples_SNAGHTML14521dc7.png)
<p><a href="#top">Back to top</a></p>
<hr />
<h3><a name="SampleObjectReference"></a>Indirect object references</h3>
<p>IntellisenseX recognizes the use of variables that are assigned as objects in code, as shown below. The objects referenced may be either objects in the form or class, or a <a href="#SampleFieldsDataObject">Data Object</a>.</p>

![](documents/images/Thor_IntellisenseX_Examples_SNAGHTML145a23a1.png)
<p><a href="#top">Back to top</a></p>
<hr />
<h3><a name="SampleAliasReferences"></a>*#Alias directive for tables and objects</h3>
<p>It may happen that a variable (that actually refers to a specific object) or alias (that actually refers to a specific table) is not defined in code in such a way the one can tell what it refers to, even if the developer knows exactly what it refers to. In this case the <font face="Courier New">*#Alias</font> directive can be used to inform Intellisense how to interpret the variable or alias.</p>
<p>In the example below, the second line informs Intellisense that the variable toData actually refers to the object ThisForm.grdGrid, so that referring to toData later in the code displays the dropdown list of properties and methods for that grid. This works for form objects (as in the example), <a href="#SampleFieldsDataObject">Data Objects</a>, and aliases.</p>

![](documents/images/Thor_IntellisenseX_Examples_SNAGHTML14653608.png)
<p><a href="#top">Back to top</a></p>
<hr />
<h3><a name="SampleMDot"></a>Variables (local and otherwise) from MDot</h3>
<p>Typing "m" and then a dot (period) will drop down a list of all variables in a procedure or method that are local, private, public, or are assigned values anywhere in the procedure (even after the current line of code).</p>

![](documents/images/Thor_IntellisenseX_Examples_image_2.png)
<p><a href="#top">Back to top</a></p>
<hr />
<h3><a name="SampleHotKeyLocals"></a>Variables (local and otherwise) using a hot key</h3>
<p>For those who do not use M-Dot notation, the same list of all variables in a procedure or method that are local, private, public, or are assigned values anywhere in the procedure. can be obtained by a hot key. (This hot key is selectable in Thor). See also <a href="Thor%20IntellisenseX%20Configuration%20Options.md#SampleIfOne"> Auto-completion on single match</a>.</p>

![](documents/images/Thor_IntellisenseX_Examples_SNAGHTML64ada77_1.png)
<p><a href="#top">Back to top</a></p>
<hr />
<h3><a name="SampleConstants"></a>Listing Constants (created by #Define and #Include)</h3>
<p>The Thor tool <strong>Dropdown Constants List</strong> creates a dropdown list of all #Define&rsquo;d constants. This list is created using the same code as is used by ZDEF, which traverses all #Include files. The second column in the display shows the value of each constant. (Note that &ldquo;match anywhere&rdquo; applies to the this second column as well.) See also <a href="Thor%20IntellisenseX%20Configuration%20Options.md#SampleIfOne"> Auto-completion on single match</a>.</p>

![](documents/images/Thor_IntellisenseX_Examples_SNAGHTML14745903.png)
<p><a href="#top">Back to top</a></p>
<hr />
<h3><a name="SamplePEMEditor"></a>Setting ControlSources in PEM Editor</h3>
<p>PEM Editor has been enhanced to recognize most of the IntellisenseX capabilities described here when entering a ControlSource. It will recognize:</p>
<ul>
<li>Object references (Thisform, e.g., as shown below)</li>
<li>Table or alias references (PartsList)</li>
<li><a href="#SampleFieldsDataObject">Data Objects</a> (This.oData)</li>
</ul>
<p>Note that if you set the ControlSource to a property of Thisform that does not exist, you will be asked if you want it to be created.</p>

![](documents/images/Thor_IntellisenseX_Examples_SNAGHTML147a41fa.png)
<p><a href="#top">Back to top</a></p>
<p><strong><font size="4">Customization</font></strong></p>
<p>There are three areas of customization available:</p>
<ul>
<li>Settings in the <a href="Thor%20IntellisenseX%20Configuration.md"> Thor configuration form</a>.</li>
<li>A <a href="Thor%20IntellisenseX%20Open%20Table%20PlugIn.md"> plug-in PRG for opening tables</a> based on their name</li>
<li>A <a href="Thor%20IntellisenseX%20Implicit%20Tables.md"> plug-in PRG for handling names that may be of SQL tables or data objects</a></li>
</ul>
<p><strong><font size="4">Using the IntellisenseX dropdown</font></strong></p>
<p>The dropdown listbox from IntellisenseX is designed to work like the dropdown from native FoxPro Intellisense, as much as that is possible, but there are differences.&nbsp; <a href="Thor%20IntellisenseX%20Using%20Dropdown.md"> See Description</a>.</p>
<p><font size="4"><strong>Acknowledgements</strong></font></p>
<p>IntellisenseX is built on ISX.PRG, written by Christof Wollenhaupt (and a host of others) from 1999-2010. The concept of extending Intellisense began with ISX.PRG and even after modifying it to fit within Thor and extending it to some new areas, the vast majority of code from ISX.PRG remains unchanged. Thanks so much to Christof (and the others) for providing such a worthy tool as a starting place.</p>
<p>Thanks also to Matt Slay for asking the right question at the right time to get this project started.</p>

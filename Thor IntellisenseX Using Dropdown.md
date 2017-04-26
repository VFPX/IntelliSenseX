<p><font size="5">Using the IntellisenseX DropDown</font></p>
<p>The dropdown listbox from IntellisenseX is designed to work like the dropdown from native FoxPro Intellisense, as much as that is possible.</p>
<p>Typing highlights the first match to what has been entered. Settings in the <a href="http://vfpx.codeplex.com/wikipage?title=Thor%20IntellisenseX%20Configuration">
Thor configuration form</a> can alter this behavior so that instead of highlighting the first match, the list is progressively filtered as you type. The “match anywhere” filter, a concept borrowed from Visual Studio, can be very effective, as seen in this example
 in which only the fields that contain ‘cos’ are displayed.</p>
<p><img border="0" src="Thor%20IntellisenseX%20Using%20Dropdown_SNAGHTMLabe132a.png" width="438" height="251" style="border-bottom:0px; border-left:0px; padding-left:0px; padding-right:0px; display:inline; border-top:0px; border-right:0px; padding-top:0px"></p>
<p>The normal list of characters that cannot be part of a name (punctuation), terminate the drop down, select the highlighted item and then insert the character typed. A space is automatically inserted before those characters that are operators (plus, minus,
 etc).</p>
<p>The significant different between the behavior of this listbox and native FoxPro Intellisense is that the listbox is contained within a modal form. Thus, to remove the dropdown, you must press the Esc key. (Native FoxPro Intellisense lets you click anywhere
 to remove the dropdown).</p>

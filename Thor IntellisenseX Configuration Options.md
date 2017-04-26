<h3>IntellisenseX Configuration Options</h3>
<p>There are a number of configuration options in Thor configuration form that apply to IntellisenseX. The major options are described here.</p>
<p><img border="0"  src="Thor%20IntellisenseX%20Configuration%20Options_SNAGHTML1e72af03.png" width="680" height="376" style="border-bottom:0px; border-left:0px; padding-left:0px; padding-right:0px; display:inline; border-top:0px; border-right:0px; padding-top:0px"></p>
<p>The first page has options that control the behavior of the listbox once you begin typing.</p>
<p>The default behavior mimics the behavior of native FoxPro Intellisense, in which the first item in the listbox that matches the typed characters is highlighted.</p>
<p>If filtering is enabled (by using the first checkbox), instead of highlighting the first item in the listbox that matches, only the items that match the typed characters are displayed. As you can see, the matching can be done against either the leading characters
 or anywhere in the item. This last option, patterned after some uses in Visual Studio, allows you to narrow your search very quickly:</p>
<p><img border="0" src="Thor%20IntellisenseX%20Configuration%20Options_SNAGHTML153acc04.png" width="697" height="304" style="border-right-width:0px; padding-left:0px; padding-right:0px; display:inline; border-top-width:0px; border-bottom-width:0px; border-left-width:0px; padding-top:0px"></p>
<h3><a name="SampleIfOne">Auto-completion on single match</a></h3>
<p>For the tools that are not initiated by pressing dot, (<strong>IntellisenseX by hotkey</strong>,
<strong>DropDown Variables List</strong>, and <strong>DropDown Constants List</strong>), you can begin typing part of the item to be selected
<u>before</u> you call the tool. In this example, <strong>DropDown Variables List</strong> was executed after “call” was already entered, and the dropdown list has only one item (if you have selected “match anywhere” filter, above)</p>
<p><img border="0" src="Thor%20IntellisenseX%20Configuration%20Options_SNAGHTML1544dd53.png" width="700" height="306" style="border-right-width:0px; padding-left:0px; padding-right:0px; display:inline; border-top-width:0px; border-bottom-width:0px; border-left-width:0px; padding-top:0px"></p>
<p>So, for the lazy developer, there is the option “Auto-completion on partial match”. If this option had been selected, then “loCallingForm” would have been pasted into the code immediately, without ever showing the listbox. This allows you to access your
 variables very rapidly by only entering enough of their names to uniquely identify them.
</p>
<p><strong>Recommendation</strong>: Turn on “match anywhere” filtering and the “Auto-completion on partial match” checkbox. You will become acclimated to these options very quickly.</p>
<h3><a name="SamplePRGClasses">Handling of PEMS in PRG based classes</a></h3>
<p>The last page in the configuration for IntellisenseX allows you to specify how THIS is handled within PRG-based classes. (There is some consideration for including a third option, for custom and inherited PEMs. This would exclude PEMs from the baseclass
 that have their default values).</p>
<p><img border="0" src="Thor%20IntellisenseX%20Configuration%20Options_SNAGHTML1549e790.png" width="680" height="376" style="border-right-width:0px; padding-left:0px; padding-right:0px; display:inline; border-top-width:0px; border-bottom-width:0px; border-left-width:0px; padding-top:0px"></p>

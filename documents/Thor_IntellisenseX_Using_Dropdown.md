## Using the IntellisenseX DropDown

The dropdown listbox from IntellisenseX is designed to work like the dropdown from native FoxPro Intellisense, as much as that is possible.

Typing highlights the first match to what has been entered. Settings in the [Thor configuration form](Thor_IntellisenseX_Configuration.md) can alter this behavior so that instead of highlighting the first match, the list is progressively filtered as you type. The “match anywhere” filter, a concept borrowed from Visual Studio, can be very effective, as seen in this example in which only the fields that contain ‘cos’ are displayed.

![](images/Thor_IntellisenseX_Using_Dropdown_SNAGHTMLabe132a.png)

The normal list of characters that cannot be part of a name (punctuation), terminate the drop down, select the highlighted item and then insert the character typed. A space is automatically inserted before those characters that are operators (plus, minus, etc).

The significant different between the behavior of this listbox and native FoxPro Intellisense is that the listbox is contained within a modal form. Thus, to remove the dropdown, you must press the Esc key. (Native FoxPro Intellisense lets you click anywhere to remove the dropdown).
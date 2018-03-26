## Thor IntellisenseX for Data Objects

IntellisenseX can be used to display the fields from data objects that are based on an underlying table in a business object or in a form or visual class based on an underlying table, although doing so requires customization on your part.

The sample below accesses the underlying table that the current class is based on (found in “This.cAlias”) whenever “This.oData.” is entered.

![](images/thor_intellisensex_data_object_image_6.png)

Customization is achieved by modifying a Plug-in PRG.

The Plug-In is called when IntellisenseX has exhausted all other possible interpretations of the text before the dot. In this example, it is called with “This.oData” as a parameter and also the object reference to the class being edited, and the Plug-In is free to determine the list of items to appear in the dropdown.  In this example, the name of the underlying table is determined from the property “This.cAlias”

See [plug-in PRG for handling names that may be of SQL tables or data objects](Thor_IntellisenseX_Implicit_Tables.md).

## Thor IntellisenseX: Setting ControlSource in PEM Editor

PEM Editor now recognizes IntellisenseX when setting ControlSource, as shown in this example:

![](images/thor_intellisensex_controlsources_snaghtmlafe99.png)

There are two different ways of using IntellisenseX to set a ControlSource:

(1) Selecting from a list of properties from an object in the form or class being edited. The object can be specified as either:

*   “Thisform.”
*   “This.Parent.” (with “.Parent” repeated as many times as necessary)

Note that only custom or inheritied properties are listed. Events, methods, native properties, and objects are all excluded from the list.

(2) Selecting from a list of fields from a table, the same as occurs for [Thor IntellisenseX](../README.md).

*   From the [alias of an open table](Thor_IntellisenseX_for_Open_Table.md).
*   From the [name of a table](Thor_IntellisenseX_Implicit_Tables.md) 
*   From a [Data Object](Thor_IntellisenseX_Data_Object.md) (requires customization)

IntellisenseX is activated automatically in PEM Editor when the dot key is pressed and is independent of the use or setting of the Thor Tool **IntellisenseX by Dot**.

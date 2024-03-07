### 2024-03-06, Version 1.25.01 ###

* Add in four Thor Proc files that had mysteriously disappeared.

### 2023-12-22, Version 1.25 ###

* Attempted fix to handle when dot is pressed not in a code window, eliminating the need for the timer altogether (Issue #26).
* Fix bug to correctly toggle ISX by dot when not using timer (Issue #25).
* Add hook so that Thor menus may show checkbox for ISX by dot when it is turned on (a feature for Thor suggested but not yet implemented).

### 2023-10-27, Version 1.24.07 ###

* Expand column widths for 2nd / 3rd columns

### 2023-10-11, Version 1.24.06 ###

* Spelling corrections and renaming 

### 2023-08-15, Version 1.24.05 ###

Add new property .AppID to all tools to identify the project they originate in.

### 2023-03-16, Version 1.24.04 ###

Bug fix

### 2023-03-14, Version 1.24.03 ###

Minor changes to captions for options

### 2023-02-12, Version 1.24.02 ###

* IntelliSenseX now respects the case of object members defined in _MemberData. Because this can be slow, it works best if the IntelliSenseX "Apply Custom Keyword List" option is turned on: the correct case of object members is saved in the custom keyword list the first time it's used, so there's no need to process _MemberData the second time.

### 2023-02-08, Version 1.24.01 ###

Minor bug fixes and missing file

### 2023-01-27, Version 1.24 ###

The list of Thor tools that use the IntellisenseX dropdown listbox has expanded. Like all Thor tools, you can make them accessible by assigning a hot key, adding them to a pop-up menu, or any of the other options that Thor provides for executing a tool.

| Thor Tool | Description |
| --- | ----------- |
| Dropdown Constants List | List of all defined constants created by #Define or #Include statements |
| Dropdown Table Names | List of all tables in the path|
| Dropdown Procedures List | List of all PRGs and procedures/functions defined in PRGs found in "Set Procedure to"|
| Dropdown Intellisense scripts | List of native Intellisense custom scripts|
| AutoComplete | List of all names used in code window (or what is highlighted there)|
| Dropdown Form Names in Active Project | List of all form names in the Active Project|
| Dropdown Report Names in Active Project | List of all report names in the Active Project|
| Dropdown Aliases | List of all aliases used in current data session
| DBC Tables by !| Assigns hot key ! so that typing in the name of a database followed by ! gives a popup of the names of the tables and views in the database.|

* Also New:
    * New keystrokes:
        * Ctrl+Enter is a special case that applies when the dropdown list is a list of properties and methods.  The second column in the dropdown gives the parameter list, if available.  This keystroke selects the current item from the dropdown and pastes the parameter list into edit window as well.
        * Ctrl+C copies the contents of the second visible column into the clipboard.
        * Ctrl+Z closes the popup and leaves the text already entered as is, whether it matches anything in the dropdown or not.
    * Dropdown box is resizable.
        
* Fixed:
    * Previously, pressing a dot to cause the dropdown would cause garbage results when the character immediately following is a valid name character.  (This would occur, for instance, if entering a table name and dot before an existing field reference.) The dot is now ignored.
    * When using the dropdown box for other uses (defined constants, procedures, etc), clicking anywhere in the name before invoking the dropdown moves the cursor to the end of the name and works normally.
    * Dropdown box now uses the option for maximum number of items to display.
    * Dropdown box shrinks to fit in the VFP screen if necessary.

### 2022-06-04, Version 1.22 ###

Continued cleanup of move to GitHub

### 2012-09-10 ###

Initial release

---
Last changed: _2023-01-27_ ![Picture](./docs/images/vfpxpoweredby_alternative.gif)


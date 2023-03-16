# How to contribute to IntellisenseX

## Bug report?
- Please check [issues](https://github.com/VFPX/IntellisenseX/issues) to see if the bug has already been reported.

- If you're unable to find an open issue addressing the problem, open a new one. Be sure to include a title and clear description, as much relevant information as possible, and a code sample or an executable test case demonstrating the expected behavior that is not occurring.

## Fix a bug or add an enhancement
Here are the steps to updating to a new version:

1. Fork the project: see this [guide](https://www.dataschool.io/how-to-contribute-on-github/) for setting up and using a fork.

1. Make whatever changes are necessary. The source code for IntelliSenseX is in the InstalledFiles folder.

1. If you haven't already done so, install VFPX Deployment: choose Check for Updates from the Thor menu, turn on the checkbox for VFPX Deployment, and click Install.

---
4. Edit the Version setting in _BuildProcess\ProjectSettings.txt_.

1. Update the version and date in _README.md_.

1. Describe the changes in the top of _Change Log.md_.

1. Run the VFPX Deployment tool to create the installation files by
    -   Invoking menu item  **Thor Tools -> Applications -> VFPX Project Deployment**  
    -   Or executing ```EXECSCRIPT(_screen.cThorDispatcher, 'Thor_Tool_DeployVFPXProject')``` 

---
8. Commit the changes.

1. Push to your fork.

1. Create a pull request; ensure the description clearly describes the problem and solution or the enhancement.
---
Last changed: _2023/02/12_ ![Picture](../Docs/Images/vfpxpoweredby_alternative.gif)

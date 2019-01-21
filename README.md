# Shader Programming
Files for the laboration in Advanced Computer Graphics and Shader Programming

# Requirements
* Python 3.7
* Pillow for Python
* Aqsis Renderer

# To use this yourself:
* Download the repository and open it in Visual Studio Code.
* Open up .vscode/tasks.json and edit the AQSISHOME variable for your operating system to point to the installation folder of Aqsis.
* Make sure that your PATH includes the bin folder inside AQSISHOME.
* Create empty folders called 'images' and 'shaders' inside the project root.

# To compile a RIB file:
* Open a RIB file in the editor.
* Press your Build hotkey and select 'Compile RIB' as your default build task.
* All the outdated shaders in the same directory as the RIB file will be compiled and moved to the 'shaders' directory.
* The image will be created, converted to PNG format, and moved to 'images'.

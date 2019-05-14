# awhelper
A tcl script for some common tasks for AndroWish: http://www.androwish.org/index.html/home

![AWhelper logo](https://github.com/dzach/awhelper/blob/master/awhelper.png)

Provides a dialog with the following options:
1. Create a home screen shortcut
   - Select target TCL script
   - Select optional icon for the shortcut
   - Enter an optional name for the shortcut
2. Edit and install .wishrc in the AndroWish HOME directory of an Android device
   - The .wishrc script is autoloaded whenever the AndroWish binary is run.
   - The simple editor provides text cursor navigation buttons to make editing on a phone a little easier.
 
 Here is how it looks:
 
![AWhelper on awemu](https://github.com/dzach/awhelper/blob/master/awhelper.gif)

(NOTE: The screencast above is from an android screen emulator, written in TCL. More on this emulator will appear [here](https://github.com/dzach/awemu) ). 

To use it:

1. Drop it in any place in the phone's / tablet's SDcard and source it with AndroWish.
2. Make a shortcut to it by using the script itself, and have this shortcut available when needed. Use the provided png file (awhelper.png) for a shortcut icon.

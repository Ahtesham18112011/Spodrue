
# Day 1: Introduction to TCL and VSDSYNTH Tool Box Usage
This day introduces us to the **Tool Command Language (TCL)** and explains us the usage of the TCL langiage.

## What is TCL language?
**Tcl (Tool Command Language)** is a high-level, general-purpose, interpreted programming language designed for simplicity and flexibility. It follows a multi-paradigm approach, supporting **event-driven, functional, imperative, and object-oriented programming**. 

## Learning TCL language through a User Interface software
This workshop teaches the TCL language through a UI (User Interface) software, which is capable of receiving input files (`.csv`), reading verilog files, `.lib` files and dumping the final results as a statistic table to the output file. Below is the first step to make this software:-

### Task 1 to make the software
1. Create command (for example vsdsynth) and pass `.csv` from UNIX shell to TCL script.

## Creating the command
To create command type this in the terminal:-
```bash
touch myfile.tcsh
```
Then change the permission by typing :-
```bash
chmod -R 777 myscript.tcsh
```
Then edit the file through ane ditor like vim, nano etc.
## Shell code for verifying the input `.csv` file
So now we will create a UNIX shell command that will inform if the `.csv` file is not given, or it does not exists or the user has typed `-help`. And if all the necessary files are given to the software it will throw the csv file to the TCL script.

```tcsh
#!/bin/tcsh -f
if ($#argv == 0) then
    echo "Error: No csv file provided."
    exit 1
endif

if (! -f $argv[1] || $argv[1] == "-help") then
       if ($argv[1] != "-help") then
      echo "Error: Cannot find csv file"
      exit 1

      else

      echo "Type the command ./ui.tcsh and write the csv file aside"
      exit 0
      endif
else
   tclsh ui.tcl $argv[1]

endif

```

1. **Shebang Line (`#!/bin/tcsh -f`)**  
   - Specifies that the script should be executed using `tcsh` (a variant of the C shell).
   - The `-f` flag prevents automatic loading of `.tcshrc`, speeding execution.

2. **Argument Check (`if ($#argv == 0) then …`)**  
   - If **no arguments** are provided, the script prints an error message and exits.

3. **File Validation (`if (! -f $argv[1] || $argv[1] == "-help") then …`)**  
   - If the provided argument **is not a file**, or the user requests help (`-help`):
     - If it's **not `-help`**, print an error and exit.
     - Otherwise, provide guidance: `"Type the command ./ui.tcsh and write the csv file aside"` and exit.

4. **Executing the Tcl Script (`tclsh ui.tcl $argv[1]`)**  
   - If the input file **exists**, it runs `ui.tcl` with the CSV file as an argument.














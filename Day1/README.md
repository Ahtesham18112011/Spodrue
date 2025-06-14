
# Day 1: Introduction to TCL and VSDSYNTH Tool Box Usage
This day introduces us to the **Tool Command Language (TCL)** and explains us the usage of the TCL langiage.

## What is TCL language?
**Tcl (Tool Command Language)** is a high-level, general-purpose, interpreted programming language designed for simplicity and flexibility. It follows a multi-paradigm approach, supporting **event-driven, functional, imperative, and object-oriented programming**. 

## Learning TCL language through a User Interface software
This workshop teaches the TCL language through a UI (User Interface) software, which is capable of receiving input files (`.csv`), reading verilog files, `.lib` files and dumping the final results as a statistic table to the output file. Below is the first step to make this software:-

### Task 1 to make the software
1. Create command (for example vsdsynth) and pass `.csv` from UNIX shell to TCL script.

## Creating the command
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





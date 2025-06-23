
# Day 1: Introduction to TCL
This day introduces us to the **Tool Command Language (TCL)** and explains us the usage of the TCL language.

## What is TCL language?
**Tcl (Tool Command Language)** is a high-level, general-purpose, interpreted programming language designed for simplicity and flexibility. It follows a multi-paradigm approach, supporting **event-driven, functional, imperative, and object-oriented programming**. 

<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/Tcl-powered.svg/182px-Tcl-powered.svg.png" alt="Image"/>
</p>

## Learning TCL language through a User Interface software
This workshop teaches the TCL language through a UI (User Interface) software, which is capable of receiving input files (`.csv`), reading verilog files, `.lib` files and dumping the final results as a statistic table of pre-layout timings, synthesized netlist to the output file. Below is the first step to make this software:-


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







echo "                                                                   ____             __                "
echo "                                                                  / __/__  ___ ____/ /____  ____      "
echo "                                                                 _\ \/ _ \/ _  / _  / __/ |/ / -_)    "
echo "                                                                /___/ .__/\___/\_,_/_/  |___/\__/     "
echo "                                                                   /_/                                "

echo "\n                   A unique User Interface (UI) that will take RTL netlist & SDC constraints as an input, and will generate sythnesized netlist & pre-layout timing report as an output."
echo "                                         It uses Yosys open-source tool for synthesis and Opentimer to generate pre-layout timing reports."





if ($#argv == 0) then
    echo "Error: No csv file provided."
    exit 1
endif

if (! -f $argv[1] || $argv[1] == "-help") then
       if ($argv[1] != "-help") then
      echo "Error: Cannot find csv file"
      exit 1

      else

      echo "Type the command ./spodrue.tcsh and write the csv file aside"
      exit 0
      endif
else
echo "\nSending the csv file to tcl script as argument" 
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


## Run in Terminal

Run the command to run the UI in the Ubuntu terminal

```bash
./myfile.tcsh you_csv_file.csv
```

![WhatsApp Image 2025-06-21 at 14 41 39](https://github.com/user-attachments/assets/3079dc56-d2e3-4e1e-93f4-5156d487f81e)












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

      echo "Type the command ./ui.tcsh and write the csv file aside"
      exit 0
      endif
else
echo "\nSending the csv file to tcl script as argument" 
   tclsh spodrue.tcl $argv[1]

endif

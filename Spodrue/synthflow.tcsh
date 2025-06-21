#!/bin/tcsh -f



echo                          " *****************************************************************************************************************************************************************"
echo                                                                                        " SYNTHFLOW"
echo                          " A unique User Interface (UI) that will take RTL netlist & SDC constraints as an input, and will generate sythnesized netlist & pre-layout timing as an output" 
echo                          " *****************************************************************************************************************************************************************"











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
echo "Sending the csv file to tcl script as argument" 
   tclsh ui.tcl $argv[1]

endif

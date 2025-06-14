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

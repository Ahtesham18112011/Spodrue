# Day 2: Variable Creation and Processing Constraints from CSV
## Constraints File 
A *constraints file*—often called an **SDC file** (Synopsys Design Constraints)—is like a rulebook that guides the design tools on how to handle your circuit during synthesis and place-and-route stages.

It defines critical parameters such as:

- **Timing constraints**: like clock definitions, input/output delays, and setup/hold requirements.
- **Design rules**: such as maximum fanout, transition times, and capacitance limits.
- **Operating conditions**: including voltage, temperature, and wire load models.
- **System interface constraints**: like driving cell characteristics and load values.

The file uses a syntax based on TCL (Tool Command Language), and it helps ensure that the final chip meets performance, power, and area goals.

---

So, in this task we need to convert the `.csv` file to the SDC file through TCL, below is the code for doing this:-

```tcl
#!/usr/bin/env tclsh
set filename [lindex $argv 0]
package require csv
package require struct::matrix
struct::matrix m
set f [open $filename r]
csv::read2matrix $f m , auto
close $f
set columns [m columns]
m link my_arr
set num_of_rows [m rows]
set i 0

while {$i < $num_of_rows} {
    puts "\nInfo: Setting $my_arr(0,$i) as '$my_arr(1,$i)'"
    if {$i == 0} {
        set [string map {" " ""} $my_arr(0,$i)] $my_arr(1,$i)
    } else {
        set [string map {" " ""} $my_arr(0,$i)] [file normalize $my_arr(1,$i)]
    }
    set i [expr {$i+1}]
}

puts "DesignName = $DesignName"
puts "OutputDirectory = $OutputDirectory"
puts "NetlistDirectory = $NetlistDirectory"
puts "EarlyLibraryPath = $EarlyLibraryPath"
puts "LateLibraryPath = $LateLibraryPath"
puts "ConstraintsFile = $ConstraintsFile"

if {![file isdirectory $OutputDirectory]} {
puts "\nInfo: Cannot find output directory $OutputDirectory. Creating $OutputDirectory"
file mkdir $OutputDirectory

} else {
puts "\nInfo: Output directory found in path $OutputDirectory"

}

if {![file isdirectory $NetlistDirectory]} {
puts "\nerror: Cannot find netlist directory $NetlistDirectory."

} else {
puts "\nInfo: Output netlist found in path $NetlistDirectory"

}

if {![file exists $EarlyLibraryPath]} {
puts "\nerror: Cannot find earlylibrarypath directory $EarlyLibraryPath."

} else {
puts "\nInfo: earlylibrary path directory found in path $EarlyLibraryPath"


}

if {![file exists $LateLibraryPath]} {
puts "\nerror: cannot find latelibrarypath directory $LateLibraryPath."

} else {
puts "\nInfo: latelibrarypath directory found in path $LateLibraryPath"

}

if {![file exists $ConstraintsFile]} {
puts "\nerror: Cannot find constraintsfile directory $ConstraintsFile."

} else {
puts "\nInfo: constraintsfile directory found in path $ConstraintsFile"

}

puts "\nInfo: Dumping SDC constraints for $DesignName"
::struct::matrix constraints
set chan [open $ConstraintsFile]
csv::read2matrix $chan constraints  , auto
close $chan
set number_of_rows [constraints rows]
set number_of_columns [constraints columns]

puts "number of rows = $number_of_rows"
puts "number of columns = $number_of_columns"

set clock_start_rows [lindex [lindex [constraints search all CLOCKS] 0 ] 1]
set input_ports_start [lindex [lindex [constraints search all INPUTS] 0] 1]
set output_ports_start [lindex [lindex [constraints search all OUTPUTS] 0] 1]
set clock_start_columns [lindex [lindex [constraints search all CLOCKS] 0] 0]





set clock_start_columns [lindex [lindex [constraints search all CLOCKS] 0] 0
```

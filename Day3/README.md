# Day 3: Processing Clocks and Input constraints
In this day we learned to read the constraints file and convert it to the `.sdc` format using TCL

## Constraints file
![Screenshot from 2025-06-16 20-33-27](https://github.com/user-attachments/assets/b40adb40-367f-4736-99a5-55ef05d3d90d)


## Coverting clock inputs as `.sdc` format
To do this just type the below command after the last tcl script:-

```tcl
set clock_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_columns $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_rise_delay] 0 ] 0]
set clock_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_columns $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_fall_delay] 0 ] 0]
set clock_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_columns $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_rise_delay] 0 ] 0]
set clock_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_columns $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_fall_delay] 0 ] 0]
set clock_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_columns $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_rise_slew] 0 ] 0]
set clock_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_columns $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_fall_slew] 0 ] 0]
set clock_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_columns $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_rise_slew] 0 ] 0]
set clock_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_columns $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_fall_slew] 0 ] 0]


set sdc_file [open $OutputDirectory/$DesignName.sdc "w"]
set i [expr {$clock_start+1}]
set end_of_ports [expr {$input_ports_start-1}]
puts "\nInfo: working on clockconstraints..."
while { $i < $end_of_ports } {

puts -nonewline $sdc_file "\ncreate_clock -name [constraints get cell 0 $i] \-period [constraints get cell 1 $i] -waveform {0 [expr {[constraints get cell 1 $i]*[constraints get cell 2 $i]/100}]} \\\[get$
puts -nonewline $sdc_file "\nset_clock_latency -source -early -rise [constraints get cell $clock_early_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_latency -source -early -fall [constraints get cell $clock_early_fall_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_latency -source -late -rise [constraints get cell $clock_late_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_latency -source -late -fall [constraints get cell $clock_late_fall_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_transition -rise -min [constraints get cell $clock_early_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_transition -fall -min [constraints get cell $clock_early_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_transition -rise -min [constraints get cell $clock_late_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_transition -fall -min [constraints get cell $clock_late_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"

set i [expr {$i+1}]

}
```


### Part 1: Identify Delay and Slew Start Positions

```tcl
set clock_early_rise_delay_start [...]
```
set clock_late_fall_slew_start [...]

- **Delay** (early/late, rise/fall)
- **Slew** (early/late, rise/fall)



###  **Part 2: Prepare to Write to an SDC File**
```tcl
set sdc_file [open $OutputDirectory/$DesignName.sdc "w"]
```
This line opens a new SDC file where all the constraints will be written. `$DesignName` is presumably the name of the current module or top-level design.

---

### **Part 3: Loop Through Clock Columns**
```tcl
while { $i < $end_of_ports } {
   ...
}
```
looping over clock rows (from `$clock_start+1` to just before `$input_ports_start`) to write constraints for each individual clock.

---

## Running in terminal and obseving output in the `.sdc` file
Run in terminal:-
```bash
./myscript.tcl your_csv_file.csv
```
View in the sdc file

![Screenshot from 2025-06-16 20-31-05](https://github.com/user-attachments/assets/74e0fb89-14fa-4698-8669-8921c303b7fa)


## Converting input to `.sdc` format
Below is the tcl code for doing so:-

```tcl
set input_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_columns $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_rise_delay] 0 ] 0]
set input_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_columns $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_fall_delay] 0 ] 0]
set input_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_columns $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_rise_delay] 0 ] 0]
set input_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_columns $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_fall_delay] 0 ] 0]
set input_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_columns $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_rise_slew] 0 ] 0]
set input_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_columns $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_fall_slew] 0 ] 0]
set input_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_columns $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_rise_slew] 0 ] 0]
set input_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_columns $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_fall_slew] 0 ] 0]
set related_clock [lindex [lindex [constraints search rect $clock_start_columns $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] clocks] 0 ] 0]

set i [expr {$input_ports_start+1}]
set end_of_inputs [expr {$output_ports_start-1}]
puts "\nworking on input constraints"
puts "\nCategorizing input ports as bits and busses"

#while loop to write input constraints to the sdc file--#

while { $i < $end_of_inputs } {
set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open /tmp/1 w]
foreach f $netlist {
set fd [open $f]
while { [gets $fd line] != -1 } {
set pattern1 " [constraints get cell 0 $i];"
if { [regexp -all -- $pattern1 $line] } {
set pattern2 [lindex [split $line ";"] 0]
if { [regexp -all {input} [lindex [split $pattern2 "\S+"] 0]] } {
set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
}
}
}
close $fd
}
close $tmp_file

set tmp_file [open /tmp/1 r]
set tmp2_file [open /tmp/2 w]
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open /tmp/2 r]
set count [llength [read $tmp2_file]]
close $tmp2_file
if {$count > 2} {
set inp_ports [concat [constraints get cell 0 $i]*]
#puts "Info: Working on input bus $inp_ports for user debug"
} else {
set inp_ports [constraints get cell 0 $i]
#puts "Info : Working on input bit $inp_ports for user debug"
}
        puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_delay_start$
        puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_early_fall_delay_start$
        puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $input_late_rise_delay_start $
        puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $input_late_fall_delay_start $

        puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_slew_s$
        puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_early_fall_slew_s$
        puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $input_late_rise_slew_st$
        puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $input_late_fall_slew_st$


        set i [expr {$i+1}]
}
```

### Analysis

### Part 1: **Initialization of Variables:**
   - using `constraints search rect` to extract various delay and slew values (early/late, rise/fall) from a design matrix and store them for later use.
   - Also grabbing the `related_clock`, which is essential for setting accurate timing constraints.

### Part 2: **Port Looping:**
   - The `while` loop iterates over input port indices (`$i`) to apply these constraints for each individual input or input bus (bit vs bus logic).
   - Ports are being categorized based on how many matches show up in a temporary parsed list of inputs in your netlist (based on file content heuristics).

### Part 3: **Constraint Application:**
   - Uses `set_input_delay` with `-min` and `-max` for both rising and falling transitions.
   - Similarly, it applies `set_input_transition` with delay values sourced from the variables set at the start.

### Part 4: **Temporary Files & Parsing:**
   - Parses Verilog netlists to identify inputs and avoid duplicates.
   - Generates temporary files to filter and sort unique port names before writing corresponding constraints.

---

## Running in terminal and view in `.sdc` file

Run in the terminal:-
```bash
yourdesign.tcl your_csv_file.csv
```
Observe outputs in sdc file

![Screenshot from 2025-06-16 20-37-46](https://github.com/user-attachments/assets/1be6f326-65cd-4417-8c2d-0799e144e342)



---




































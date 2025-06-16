# Day 3: Processing Clocks and Input constraints
In this day we learned to read the constraints file and convert it to the `.sdc` format using TCL

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




### Part 1: Identify Delay and Slew Start Positions

```tcl
set clock_early_rise_delay_start [...]
...
set clock_late_fall_slew_start [...]
```
- **Delay** (early/late, rise/fall)
- **Slew** (early/late, rise/fall)



---

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


















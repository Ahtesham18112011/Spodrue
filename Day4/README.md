# Day 4: Complete Scripting and Yosys synthesis Introduction

## Scripting the output:-
```tcl
set output_erd_start [lindex [lindex [constraints search rect $clock_start_columns $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] early_rise_delay] 0 ] 0]
set output_efd_start [lindex [lindex [constraints search rect $clock_start_columns $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] early_fall_delay] 0 ] 0]
set output_lrd_start [lindex [lindex [constraints search rect $clock_start_columns $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] late_rise_delay] 0 ] 0]
set output_lfd_start [lindex [lindex [constraints search rect $clock_start_columns $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] late_fall_delay] 0 ] 0]

#Finding column number starting for output realted clock in output section

set output_related_clock [lindex [lindex [constraints search rect $clock_start_columns $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] clocks] 0 ] 0]

#Finding column number starting for output load in output section

set output_load_start [lindex [lindex [constraints search rect $clock_start_columns $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] load] 0 ] 0]



#Setting varibales for actual output row start and end

set i [expr {$output_ports_start+1}]
set end_of_outputs [expr {$number_of_rows-1}]

puts "\nInfo: Working on output constraints"
puts "\nInfo: categorizing output ports as bits and busses"

while { $i < $end_of_outputs } {
set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open /tmp/1 w]
foreach f $netlist {
set fd [open $f]
while { [gets $fd line] != -1 } {
set pattern1 " [constraints get cell 0 $i];"
if { [regexp -all -- $pattern1 $line] } {
set pattern2 [lindex [split $line ";"] 0]
if { [regexp -all {output} [lindex [split $pattern2 "\S+"] 0]] } {
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
set op_ports [concat [constraints get cell 0 $i]*]
} else {
set op_ports [constraints get cell 0 $i]
#puts "Info : Working on output bit $op_ports for user debug"
}

#set_output_delay SDC command to set output latency values

puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $output_related_clock $i]\] -min -rise -source_latency_included [constraints get cell $output_erd_start $i] \[get_p$
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $output_related_clock $i]\] -min -fall -source_latency_included [constraints get cell $output_efd_start $i] \[get_p$
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $output_related_clock $i]\] -max -rise -source_latency_included [constraints get cell $output_lrd_start $i] \[get_p$
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $output_related_clock $i]\] -max -fall -source_latency_included [constraints get cell $output_lfd_start $i] \[get_p$

#set_load SDC command to set load values

puts -nonewline $sdc_file "\nset_load [constraints get cell $output_load_start $i] \[get_ports $op_ports\]"

set i [expr {$i+1}]

}
close $sdc_file

```






















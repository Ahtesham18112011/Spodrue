
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


set clock_start [lindex [lindex [constraints search all CLOCKS] 0 ] 1]
set input_ports_start [lindex [lindex [constraints search all INPUTS] 0] 1]
set output_ports_start [lindex [lindex [constraints search all OUTPUTS] 0] 1]
set clock_start_columns [lindex [lindex [constraints search all CLOCKS] 0] 0]

puts "clock column = $clock_start"
puts "input column = $input_ports_start"
puts "output column = $output_ports_start"
puts "clock column = $clock_start_columns"


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

puts -nonewline $sdc_file "\ncreate_clock -name [constraints get cell 0 $i] \-period [constraints get cell 1 $i] -waveform {0 [expr {[constraints get cell 1 $i]*[constraints get cell 2 $i]/100}]} \\\[get_ports [constraints get cell 0 $i]\\\]"
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
	puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_delay_start $i] \[get_ports $inp_ports\]"
	puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_early_fall_delay_start $i] \[get_ports $inp_ports\]"
	puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $input_late_rise_delay_start $i] \[get_ports $inp_ports\]"
	puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $input_late_fall_delay_start $i] \[get_ports $inp_ports\]"

	puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_slew_start $i] \[get_ports $inp_ports\]"
	puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_early_fall_slew_start $i] \[get_ports $inp_ports\]"
	puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $input_late_rise_slew_start $i] \[get_ports $inp_ports\]"
	puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $input_late_fall_slew_start $i] \[get_ports $inp_ports\]"


	set i [expr {$i+1}]
}

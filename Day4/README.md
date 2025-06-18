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


---

### **1. Variable Definitions for Output Constraints**
The script begins by defining variables that store column indices for various output-related constraints in a constraint data structure (likely a spreadsheet or table). The `constraints search rect` command searches a rectangular region of the data structure defined by:
- Columns: From `$clock_start_columns` to `$number_of_columns-1`.
- Rows: From `$output_ports_start` to `$number_of_rows-1`.

The variables are:
- `output_erd_start`: Column index for **early rise delay** values.
- `output_efd_start`: Column index for **early fall delay** values.
- `output_lrd_start`: Column index for **late rise delay** values.
- `output_lfd_start`: Column index for **late fall delay** values.
- `output_related_clock`: Column index for the **clock** associated with output ports.
- `output_load_start`: Column index for the **load** (capacitance) values for output ports.

These variables are set using the `lindex` command to extract the first element (index 0) from the result of the `constraints search rect` command, which returns a list of lists.

**Example:**
```tcl
set output_erd_start [lindex [lindex [constraints search rect $clock_start_columns $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] early_rise_delay] 0 ] 0]
```
This retrieves the column index for the `early_rise_delay` constraint for output ports.

---

### **2. Loop Setup for Processing Output Ports**
The script sets up a loop to iterate over the rows of output ports, starting from row `$output_ports_start + 1` (skipping the header row) to `$number_of_rows - 1` (the last row of the output section).

```tcl
set i [expr {$output_ports_start+1}]
set end_of_outputs [expr {$number_of_rows-1}]
```

The loop processes each row in the output section of the constraint data structure, extracting information about output ports and their associated constraints.

---

### **3. Categorizing Output Ports (Bits vs. Busses)**
For each row (`$i`), the script determines whether the output port is a single **bit** or a **bus** (a group of bits). This is done by analyzing Verilog netlist files in the `$NetlistDirectory` directory.

#### **Steps:**
1. **Read Netlist Files**:
   - The script uses `glob` to collect all `.v` (Verilog) files in `$NetlistDirectory`.
   - For each file, it searches for lines containing the output port name (obtained via `constraints get cell 0 $i`) followed by a semicolon (`;`).

2. **Pattern Matching**:
   - The pattern ` [constraints get cell 0 $i];` is used to find lines in the Verilog file that define the output port.
   - If a line contains the keyword `output`, the script extracts the portion before the semicolon and processes it to identify the port definition.

3. **Temporary File Creation**:
   - The script writes the processed output port definitions to a temporary file (`/tmp/1`).
   - It removes extra whitespace and writes the cleaned-up definitions to the file.

4. **Sorting and Counting Unique Entries**:
   - The temporary file (`/tmp/1`) is read, and its contents are sorted and made unique (using `lsort -unique`).
   - The sorted output is written to another temporary file (`/tmp/2`).
   - The number of unique entries is counted to determine if the port is a bus or a single bit.

5. **Port Classification**:
   - If the count of unique entries (`$count`) is greater than 2, the port is treated as a **bus**, and the script appends a wildcard (`*`) to the port name: `[constraints get cell 0 $i]*`.
   - Otherwise, it is treated as a single **bit**, and the port name is used as-is: `[constraints get cell 0 $i]`.

**Example Output**:
- For a bus: `my_port[7:0]`
- For a bit: `my_port`

---

### **4. Generating SDC Commands for Output Delays**
For each output port (row `$i`), the script generates `set_output_delay` commands to specify the timing constraints relative to a clock. These commands are written to the `$sdc_file`.

#### **Commands Generated**:
The script generates four `set_output_delay` commands per output port, covering:
- **Minimum rise delay** (`-min -rise`): Uses the value from the `early_rise_delay` column.
- **Minimum fall delay** (`-min -fall`): Uses the value from the `early_fall_delay` column.
- **Maximum rise delay** (`-max -rise`): Uses the value from the `late_rise_delay` column.
- **Maximum fall delay** (`-max -fall`): Uses the value from the `late_fall_delay` column.

Each command references:
- The clock associated with the output port (from the `output_related_clock` column, accessed via `constraints get cell $output_related_clock $i`).
- The delay value (from the respective delay column, e.g., `constraints get cell $output_erd_start $i`).
- The output port(s) (`$op_ports`), which could be a single bit or a bus.



## Running in the terminal

Successfully run in the terminal

![Screenshot from 2025-06-18 11-59-53](https://github.com/user-attachments/assets/933ed2eb-9c05-406d-81a6-5bdea372eafa)



## Observing the SDC file

[This](https://github.com/Ahtesham18112011/TCL_Workshop/blob/main/synthflow/outdir_openMSP430/openMSP430.sdc) is the full SDC file.


# What is Yosys?

Yosys is an open-source framework for Verilog RTL (Register-Transfer Level) synthesis. It’s a tool used in digital design to convert high-level hardware descriptions (written in Verilog) into a gate-level representation or netlist, which can be used for further processing in FPGA (Field-Programmable Gate Array) or ASIC (Application-Specific Integrated Circuit) design flows. Yosys supports a wide range of synthesis tasks, including logic optimization, technology mapping, and formal verification, and is highly extensible through its modular architecture and scripting capabilities.
![Copilot_20250618_122222](https://github.com/user-attachments/assets/025951e7-f29e-4448-9376-07dfaf5f9145)














# Day 5: Advanced Scripting Techniques and Quality of Results Generation
## Main Synthesis script to be used by Yosys
```tcl
puts "\nInfo: Creating main synthesis script to be used by Yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.ys"
set fileId [open $OutputDirectory/$filename "w"]
puts -nonewline $fileid $data

set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
set data $f
puts -nonewline $fileId "\nread_verilog $f"
}

puts -nonewline $fileId "\nhierarchy -top $DesignName"
puts -nonewline $fileId "\nsynth -top $DesignName"
puts -nonewline $fileId "\nsplitnets -ports -format ___\ndfflibmap -liberty ${LateLibraryPath} \nopt"
puts -nonewline $fileId "\nabc -liberty ${LateLibraryPath}"
puts -nonewline $fileId "\nflatten"
puts -nonewline $fileId "\nclean -purge\niopadmap -outpad BUFX2 A:Y -bits\nopt\nclean"
puts -nonewline $fileId "\nwrite_verilog $OutputDirectory/$DesignName.synth.v"
close $fileId
puts "\nInfo: Synthesis Script created and can be accessed from path $OutputDirectory/$DesignName.ys"
puts "\nInfo: Running Synthesis"
```

1. **Script Initialization**:  
   It announces the creation of the synthesis script and prepares a new file named `<DesignName>.ys` in the specified `$OutputDirectory`.

2. **Reading Liberty File**:  
   The first command inserted is:
   ```tcl
   read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}
   ```
   This loads the Liberty file that provides cell characteristics, treating undefined modules as black boxes.

3. **Reading Verilog Sources**:  
   It uses `glob` to list all `.v` files in `$NetlistDirectory` and appends a `read_verilog` command for each one.

4. **Setting Top Module and Synthesizing**:  
   ```tcl
   hierarchy -top $DesignName
   synth -top $DesignName
   ```
   These ensure correct module hierarchy and start synthesis with the given top module.

5. **Netlist Output**:  
   Writes the final synthesized Verilog netlist to:
   ```tcl
   $OutputDirectory/$DesignName.synth.v
   ```

6. **Completion Logs**:  
   The script closes the file and logs that the script is ready and synthesis is being started.


## Script for editing the Yosys output file
The editing is required because in further steps, when we will do STA, which can be done by the open-source tool called OpenTimer, and this tool doesn't understands characters like \\ and *. 

```tcl
if {[catch {exec yosys -s $OutputDirectory/$DesignName.ys >& $OutputDirectory/$DesignName.synthesis.log} msg]} {
     puts "\nSynthesis failed due to errors. Please refer to log $OutputDirectory/$DesignName.synthesis.log for errors"
exit

} else {

     puts "\nInfo: Synthesis finished successfully"
}

set fileId [open /tmp/1 "w"]
puts -nonewline $fileId [exec grep -v -w "*" $OutputDirectory/$DesignName.synth.v]
close $fileId

set output [open $OutputDirectory/$DesignName.final.synth.v "w"]

set filename "/tmp/1"
set fid [open $filename r]
        while {[gets $fid line] != -1} {
        puts -nonewline $output [string map {"\\" ""} $line]
        puts -nonewline $output "\n"
}
close $fid
close $output

puts "\nInfo: Please find the synthesized netlist for $DesignName at below path. You can use this netlist for STA or PNR"
puts "$OutputDirectory/$DesignName.final.synth.v"


```




### 1. **Running the Yosys Synthesis Flow**
```tcl
if {[catch {exec yosys -s $OutputDirectory/$DesignName.ys >& $OutputDirectory/$DesignName.synthesis.log} msg]} { ... }
```
- Uses `exec` to run Yosys with your generated script.
- Redirects both stdout and stderr into a log file.
- Wraps the call in a `catch` block to detect synthesis failure.
- On failure, it alerts the user and exits.
- On success, it confirms completion.

---

### 2. **Filtering the Netlist**
```tcl
puts -nonewline $fileId [exec grep -v -w "*" $OutputDirectory/$DesignName.synth.v]
```
- Opens a temporary file `/tmp/1`.
- Filters out lines containing only `*`, which are probably Yosys comments or metadata.
- Writes the cleaned content to `/tmp/1`.

---

### 3. **Rewriting the Netlist**
```tcl
puts -nonewline $output [string map {"\\" ""} $line]
```
- Opens the cleaned temp file for reading.
- Creates a final output file for STA/PNR.
- Removes unnecessary backslashes (escaped line continuations).
- Adds newline explicitly to preserve formatting.


---


# *World Of 'Procs'*

In Tcl, a **proc** is a *procedure*—essentially a named block of code that you define once and can reuse wherever needed. It allows you to organize code into modular, reusable components.

**Formal definition:**  
A *proc* in Tcl is a user-defined command that encapsulates a sequence of commands and can accept input parameters. It promotes cleaner, maintainable code by abstracting logic into callable routines.

### Basic Syntax:
```tcl
proc name {arg1 arg2 ...} {
    body
}
```

- `name` is the name of your procedure.
- The arguments are the parameters it expects.
- The `body` is the block of Tcl code that runs when the procedure is called.

### Example:
```tcl
proc greet {name} {
    puts "Hello, $name!"
}
greet "Ahtesham"
```
This would output: `Hello, Ahtesham!`

### Return Values
By default, the *last evaluated expression* in a proc is returned, but you can also explicitly return a value:
```tcl
proc add {a b} {
    return [expr {$a + $b}]
}
```

---

## Examples of *'Procs'*
**1. Reopen stdout**
```tcl
proc reopenStdout {file} {
    close stdout
    open $file w       
}
```

This Tcl procedure `reopenStdout` is meant to redirect standard output (`stdout`) to a file of your choice. Here’s what it does:

1. **`close stdout`** – Closes the current standard output stream. This is necessary before reopening it.
2. **`open $file w`** – Opens the file passed as an argument in write mode (`w`) and implicitly assigns it to `stdout` since `stdout` was just closed.


---


**2. `set_multi_cpu_usage` command**

```tcl
proc set_multi_cpu_usage {args} {
        array set options {-localCpu <num_of_threads> -help "" }
        #foreach {switch value} [array get options] {
        #puts "Option $switch is $value"
        #}
        while {[llength $args]} {
        #puts "llength is [llength $args]"
        #puts "lindex 0 of \"$args\" is [lindex $args 0]"
                switch -glob -- [lindex $args 0] {
                -localCpu {
                           #puts "old args is $args"
                           set args [lassign $args - options(-localCpu)]
                           #puts "new args is \"$args\""
                           puts "set_num_threads $options(-localCpu)"
                          }
                -help {
                           #puts "old args is $args"
                           set args [lassign $args - options(-help) ]
                           #puts "new args is \"$args\""
                           puts "Usage: set_multi_cpu_usage -localCpu <num_of_threads>"
                      }
                }
        }
}
```


###  What It Does

It processes command-line style options from the `args` list and executes commands based on flags:

- **`-localCpu <num_of_threads>`**  
  Sets the number of threads to use—prints a message like `set_num_threads 4`.

- **`-help`**  
  Outputs usage information for how to use the command.

---

### How It Works 

1. **`array set options {-localCpu <num_of_threads> -help "" }`**  
   Initializes the `options` array with expected keys and their placeholders.

2. **`while {[llength $args]}`**  
   Continues looping while there are still unprocessed arguments.

3. **`switch -glob -- [lindex $args 0]`**  
   Peeks at the first argument and decides how to handle it.

4. **`-localCpu` block**  
   - Removes `-localCpu` and its value from `args` using `lassign`.
   - Stores the value in `options(-localCpu)`.
   - Prints out: `set_num_threads <value>`.

5. **`-help` block**  
   - Similarly, removes `-help` from `args` and outputs usage instructions.

---

**3. `read_lib` command**

```tcl
proc read_lib args {
	array set options {-late <late_lib_path> -early <early_lib_path> -help ""}
	while {[llength $args]} {
		switch -glob -- [lindex $args 0] {
		-late {
			set args [lassign $args - options(-late) ]
			puts "set_late_celllib_fpath $options(-late)"
		      }
		-early {
			set args [lassign $args - options(-early) ]
			puts "set_early_celllib_fpath $options(-early)"
		       }
		-help {
			set args [lassign $args - options(-help) ]
			puts "Usage: read_lib -late <late_lib_path> -early <early_lib_path>"
			puts "-late <provide late library path>"
			puts "-early <provide early library path>"
		      }	
		default break
		}
	}
}
```


###  **Purpose**

To **handle command-line-style flags** for specifying late and early liberty file paths, which are typically needed for setup/hold timing analysis or multi-corner characterization.


### Explanation

1. **`array set options {-late <late_lib_path> -early <early_lib_path> -help ""}`**  
   - Initializes an associative array `options` with default values for expected flags.
   - The placeholders `<late_lib_path>` and `<early_lib_path>` are just stand-ins until actual values are parsed.

2. **`while {[llength $args]}`**  
   - Loops while there are arguments left to process in the `args` list.

3. **`switch -glob -- [lindex $args 0]`**  
   - Checks the first element in the current `args` list to see which flag is provided.

4. **Flag Handlers:**

   - `-late`:  
     - Uses `lassign` to pop the flag and value, storing the value into `options(-late)`.
     - Prints: `set_late_celllib_fpath <path>`

   - `-early`:  
     - Same as above, but for early library path.
     - Prints: `set_early_celllib_fpath <path>`

   - `-help`:  
     - Prints usage instructions and descriptions for each flag.

   - `default`:  
     - If an unrecognized flag is encountered, the loop exits via `break`.

---

4. `read_verilog` command

```tcl
proc read_verilog {arg1} {
puts "set_verilog_fpath $arg1"
}
```

### Explanation
This simply puts the command "set_verilog_fpath $arg1"


---


**5. read_sdc command** 
```tcl
proc read_sdc {arg1} {
set sdc_dirname [file dirname $arg1]
set sdc_filename [lindex [split [file tail $arg1] .] 0 ]
set sdc [open $arg1 r]
set tmp_file [open /tmp/1 w]

puts -nonewline $tmp_file [string map {"\[" "" "\]" " "} [read $sdc]]     
close $tmp_file

#-----------------------------------------------------------------------------#
#----------------converting create_clock constraints--------------------------#
#-----------------------------------------------------------------------------#

set tmp_file [open /tmp/1 r]
set timing_file [open /tmp/3 w]
set lines [split [read $tmp_file] "\n"]
set find_clocks [lsearch -all -inline $lines "create_clock*"]
foreach elem $find_clocks {
	set clock_port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
	set clock_period [lindex $elem [expr {[lsearch $elem "-period"]+1}]]
	set duty_cycle [expr {100 - [expr {[lindex [lindex $elem [expr {[lsearch $elem "-waveform"]+1}]] 1]*100/$clock_period}]}]
	puts $timing_file "clock $clock_port_name $clock_period $duty_cycle"
	}
close $tmp_file

#-----------------------------------------------------------------------------#
#----------------converting set_clock_latency constraints---------------------#
#-----------------------------------------------------------------------------#

set find_keyword [lsearch -all -inline $lines "set_clock_latency*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_clocks"]+1}]]
	if {![string match $new_port_name $port_name]} {
        	set new_port_name $port_name
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
        	set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_clocks"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
		puts -nonewline $tmp2_file "\nat $port_name $delay_value"
	}
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file

#-----------------------------------------------------------------------------#
#----------------converting set_clock_transition constraints------------------#
#-----------------------------------------------------------------------------#

set find_keyword [lsearch -all -inline $lines "set_clock_transition*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_clocks"]+1}]]
        if {![string match $new_port_name $port_name]} {
		set new_port_name $port_name
		set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
        	set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_clocks"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $tmp2_file "\nslew $port_name $delay_value"
	}
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file

#-----------------------------------------------------------------------------#
#----------------converting set_input_delay constraints-----------------------#
#-----------------------------------------------------------------------------#

set find_keyword [lsearch -all -inline $lines "set_input_delay*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
		set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_ports"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $tmp2_file "\nat $port_name $delay_value"
	}
}
close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file

#-----------------------------------------------------------------------------#
#----------------converting set_input_transition constraints------------------#
#-----------------------------------------------------------------------------#

set find_keyword [lsearch -all -inline $lines "set_input_transition*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
        	set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_ports"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $tmp2_file "\nslew $port_name $delay_value"
	}
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file

#-----------------------------------------------------------------------------#
#---------------converting set_output_delay constraints-----------------------#
#-----------------------------------------------------------------------------#

set find_keyword [lsearch -all -inline $lines "set_output_delay*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
        	set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_ports"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $tmp2_file "\nrat $port_name $delay_value"
	}
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file

#-----------------------------------------------------------------------------#
#-------------------converting set_load constraints---------------------------#
#-----------------------------------------------------------------------------#

set find_keyword [lsearch -all -inline $lines "set_load*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*" ] ""]]
        	set delay_value ""
        	foreach new_elem $delays_list {
        	set port_index [lsearch $new_elem "get_ports"]
        	lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $timing_file "\nload $port_name $delay_value"
	}
}
close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file  [read $tmp2_file]
close $tmp2_file

#-----------------------------------------------------------------------------#
close $timing_file

set ot_timing_file [open $sdc_dirname/$sdc_filename.timing w]
set timing_file [open /tmp/3 r]
while {[gets $timing_file line] != -1} {
        if {[regexp -all -- {\*} $line]} {
                set bussed [lindex [lindex [split $line "*"] 0] 1]
                set final_synth_netlist [open $sdc_dirname/$sdc_filename.final.synth.v r]
                while {[gets $final_synth_netlist line2] != -1 } {
                        if {[regexp -all -- $bussed $line2] && [regexp -all -- {input} $line2] && ![string match "" $line]} {
                        puts -nonewline $ot_timing_file "\n[lindex [lindex [split $line "*"] 0 ] 0 ] [lindex [lindex [split $line2 ";"] 0 ] 1 ] [lindex [split $line "*"] 1 ]"
                        } elseif {[regexp -all -- $bussed $line2] && [regexp -all -- {output} $line2] && ![string match "" $line]} {
                        puts -nonewline $ot_timing_file "\n[lindex [lindex [split $line "*"] 0 ] 0 ] [lindex [lindex [split $line2 ";"] 0 ] 1 ] [lindex [split $line "*"] 1 ]"
                        }
                }
        } else {
        puts -nonewline $ot_timing_file  "\n$line"
        }
}

close $timing_file
puts "set_timing_fpath $sdc_dirname/$sdc_filename.timing"
}
```
---

### **Step-by-Step Explanation**

#### **1. File Setup and Preprocessing**
```tcl
set sdc_dirname [file dirname $arg1]
set sdc_filename [lindex [split [file tail $arg1] .] 0 ]
set sdc [open $arg1 r]
set tmp_file [open /tmp/1 w]
puts -nonewline $tmp_file [string map {"\[" "" "\]" " "} [read $sdc]]     
close $tmp_file
```
- **Extract Directory and Filename**: 
  - `file dirname $arg1` extracts the directory path of the SDC file.
  - `file tail $arg1` gets the filename, and `split [file tail $arg1] .` splits it at the dot to extract the base filename (without extension).
- **Read SDC File**: The SDC file is opened in read mode (`r`), and its contents are read.
- **Preprocess SDC Content**:
  - The `string map` command removes square brackets (`[` and `]`) from the SDC content, replacing them with empty strings or spaces. This simplifies parsing by removing Tcl/SDC-specific syntax that could complicate string processing.
  - The processed content is written to a temporary file `/tmp/1` without a newline at the end (`-nonewline`).
- **Close Temporary File**: The temporary file `/tmp/1` is closed.

#### **2. Processing `create_clock` Constraints**
```tcl
set tmp_file [open /tmp/1 r]
set timing_file [open /tmp/3 w]
set lines [split [read $tmp_file] "\n"]
set find_clocks [lsearch -all -inline $lines "create_clock*"]
foreach elem $find_clocks {
    set clock_port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
    set clock_period [lindex $elem [expr {[lsearch $elem "-period"]+1}]]
    set duty_cycle [expr {100 - [expr {[lindex [lindex $elem [expr {[lsearch $elem "-waveform"]+1}]] 1]*100/$clock_period}]}]
    puts $timing_file "clock $clock_port_name $clock_period $duty_cycle"
}
close $tmp_file
```
- **Read Preprocessed File**: The temporary file `/tmp/1` is reopened in read mode, and its contents are split into lines (`\n`).
- **Create Output File**: A new temporary file `/tmp/3` is opened in write mode to store the processed constraints.
- **Find `create_clock` Constraints**: 
  - `lsearch -all -inline $lines "create_clock*"` searches for lines starting with `create_clock`.
- **Process Each `create_clock` Line**:
  - Extracts the clock port name (the argument after `get_ports`).
  - Extracts the clock period (the argument after `-period`).
  - Calculates the duty cycle using the waveform argument (second value after `-waveform`), expressed as a percentage: `100 - (waveform[1] * 100 / period)`.
  - Writes a line to `/tmp/3` in the format: `clock <port_name> <period> <duty_cycle>`.
- **Close Temporary File**: `/tmp/1` is closed.

#### **3. Processing `set_clock_latency` Constraints**
```tcl
set find_keyword [lsearch -all -inline $lines "set_clock_latency*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
    set port_name [lindex $elem [expr {[lsearch $elem "get_clocks"]+1}]]
    if {![string match $new_port_name $port_name]} {
        set new_port_name $port_name
        set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
        set delay_value ""
        foreach new_elem $delays_list {
            set port_index [lsearch $new_elem "get_clocks"]
            lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        }
        puts -nonewline $tmp2_file "\nat $port_name $delay_value"
    }
}
close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file
```
- **Find `set_clock_latency` Constraints**: Searches for lines starting with `set_clock_latency`.
- **Process Each Unique Clock**:
  - Extracts the clock name (argument after `get_clocks`).
  - Ensures each clock is processed only once by comparing with `new_port_name`.
  - Collects all delay values for the same clock by searching for lines containing the clock name.
  - Writes the result to `/tmp/2` in the format: `at <clock_name> <delay_values>`.
- **Append to Timing File**: The contents of `/tmp/2` are appended to `/tmp/3` without a newline.
- **Close Files**: `/tmp/2` is closed.

#### **4. Processing `set_clock_transition` Constraints**
This section is similar to the `set_clock_latency` processing but handles `set_clock_transition` constraints:
- Finds lines starting with `set_clock_transition`.
- Extracts the clock name and transition (slew) values.
- Writes to `/tmp/2` in the format: `slew <clock_name> <transition_values>`.
- Appends the contents to `/tmp/3`.

#### **5. Processing `set_input_delay` Constraints**
- Finds lines starting with `set_input_delay`.
- Extracts the port name (after `get_ports`) and input delay values.
- Writes to `/tmp/2` in the format: `at <port_name> <delay_values>`.
- Appends to `/tmp/3`.

#### **6. Processing `set_input_transition` Constraints**
- Finds lines starting with `set_input_transition`.
- Extracts the port name and transition (slew) values.
- Writes to `/tmp/2` in the format: `slew <port_name> <transition_values>`.
- Appends to `/tmp/3`.

#### **7. Processing `set_output_delay` Constraints**
- Finds lines starting with `set_output_delay`.
- Extracts the port name and output delay values.
- Writes to `/tmp/2` in the format: `rat <port_name> <delay_values>` (where `rat` likely stands for required arrival time).
- Appends to `/tmp/3`.

#### **8. Processing `set_load` Constraints**
- Finds lines starting with `set_load`.
- Extracts the port name and load values.
- Writes to `/tmp/2` in the format: `load <port_name> <load_values>`.
- Appends to `/tmp/3`.

#### **9. Final Output and Bus Handling**
```tcl
set ot_timing_file [open $sdc_dirname/$sdc_filename.timing w]
set timing_file [open /tmp/3 r]
while {[gets $timing_file line] != -1} {
    if {[regexp -all -- {\*} $line]} {
        set bussed [lindex [lindex [split $line "*"] 0] 1]
        set final_synth_netlist [open $sdc_dirname/$sdc_filename.final.synth.v r]
        while {[gets $final_synth_netlist line2] != -1 } {
            if {[regexp -all -- $bussed $line2] && [regexp -all -- {input} $line2] && ![string match "" $line]} {
                puts -nonewline $ot_timing_file "\n[lindex [lindex [split $line "*"] 0 ] 0 ] [lindex [lindex [split $line2 ";"] 0 ] 1 ] [lindex [split $line "*"] 1 ]"
            } elseif {[regexp -all -- $bussed $line2] && [regexp -all -- {output} $line2] && ![string match "" $line]} {
                puts -nonewline $ot_timing_file "\n[lindex [lindex [split $line "*"] 0 ] 0 ] [lindex [lindex [split $line2 ";"] 0 ] 1 ] [lindex [split $line "*"] 1 ]"
            }
        }
    } else {
        puts -nonewline $ot_timing_file  "\n$line"
    }
}
close $timing_file
puts "set_timing_fpath $sdc_dirname/$sdc_filename.timing"
```
- **Create Final Timing File**: Opens `<sdc_dirname>/<sdc_filename>.timing` in write mode.
- **Read Intermediate Timing File**: Reads `/tmp/3` line by line.
- **Handle Bussed Signals**:
  - Checks for lines containing an asterisk (`*`), indicating a bussed signal (e.g., `port[*]`).
  - Opens the Verilog netlist file `<sdc_filename>.final.synth.v`.
  - Searches for the bussed signal name in the netlist and checks if it corresponds to an `input` or `output` port.
  - Replaces the bussed signal with the specific port name from the netlist and writes the modified line to the final timing file.
- **Write Non-Bussed Lines**: Lines without an asterisk are written directly to the final timing file.
- **Output Path**: Prints the path to the final timing file with the command `set_timing_fpath`.

---

## TCL Sript for Converting the SDC file to the OpenTimer accepted format
```tcl
puts "\nInfo: Timing Analysis started"
puts "Initializing number of threads, libraries, sdc, verilog netlist paths"
source /home/vsduser/vsdsynth/procs/reopenStdout.proc
source /home/vsduser/vsdsynth/procs/set_num_threads.proc

reopenStdout $OutputDirectory/$DesignName.conf
set_multi_cpu_usage -localCpu 4
source /home/vsduser/vsdsynth/procs/read_lib.proc
read_lib -early $EarlyLibraryPath

read_lib -late $LateLibraryPath

source /home/vsduser/vsdsynth/procs/read_verilog.proc
read_verilog $OutputDirectory/$DesignName.final.synth.v

source /home/vsduser/vsdsynth/procs/read_sdc.proc
read_sdc $OutputDirectory/$DesignName.sdc
reopenStdout /dev/tty

set enable_prelayout_timing 1

if {$enable_prelayout_timing == 1} {
puts "\nInfo: enable_prelayout_timing is $enable_prelayout_timing. Enabling zero-wire load parasitics"
        set spef_file [open $OutputDirectory/$DesignName.spef w]
        puts $spef_file "*SPEF \"IEEE 1481-1998\" "
        puts $spef_file "*DESIGN \"$DesignName\" "
        puts $spef_file "*DATE \"[clock format [clock seconds] -format {%a %b %d %I:%M:%S %Y}]\" "
        puts $spef_file "*VENDOR \"TAU 2015 Contest\" "
        puts $spef_file "*PROGRAM \"Benchmark Parasitic Generator\" "
        puts $spef_file "*VERSION \"0.0\" "
        puts $spef_file "*DESIGN_FLOW \"NETLIST_TYPE_VERILOG\" "
        puts $spef_file "*DIVIDER / "
        puts $spef_file "*DELIMITER : "
        puts $spef_file "*BUS_DELIMITER \[ \] "
        puts $spef_file "*T_UNIT 1 PS "
        puts $spef_file "*C_UNIT 1 FF "
        puts $spef_file "*R_UNIT 1 KOHM "
        puts $spef_file "*L_UNIT 1 UH "

}
close $spef_file

set conf_file [open $OutputDirectory/$DesignName.conf a]
puts $conf_file "set_spef_fpath $OutputDirectory/$DesignName.spef"
puts $conf_file "init_timer "
puts $conf_file "report_timer "
puts $conf_file "report_wns "
puts $conf_file "report_worst_paths -numPaths 10000 "
close $conf_file
```


---

###  **Step-by-step Breakdown**

####  Logging and CPU Setup
```tcl
reopenStdout $OutputDirectory/$DesignName.conf
set_multi_cpu_usage -localCpu 4
```
- Redirects stdout to `.conf` for logging.
- Enables multi-threading using 4 local CPUs — a useful lever in timing-heavy flows.

####  Read Early & Late Libraries
```tcl
read_lib -early $EarlyLibraryPath
read_lib -late $LateLibraryPath
```
- Loads cell timing data to represent best-case and worst-case timing corners.

####  Read Synthesized Netlist
```tcl
read_verilog $OutputDirectory/$DesignName.final.synth.v
```
- Loads your synthesized Verilog — likely generated by a Yosys flow.

####  Load Constraints
```tcl
read_sdc $OutputDirectory/$DesignName.sdc
```
- Loads clock and IO timing constraints (from the `.sdc` file).

####  Generate Dummy SPEF (if enabled)
```tcl
if {$enable_prelayout_timing == 1} {
   ...
}
```
- When prelayout timing is requested, it generates a dummy `.spef` file — this acts as a placeholder for parasitic data, allowing early analysis with zero-wire loads.

The block writes metadata like:
- SPEF standard/version
- Design name
- Unit definitions (time in ps, cap in fF, resistance in kΩ, etc.)

You’ll populate actual parasitics in a proper flow later with extracted SPEFs post-placement.

####  Timer Configuration and Reporting
```tcl
set conf_file [open $OutputDirectory/$DesignName.conf a]
puts $conf_file "set_spef_fpath ..."
puts $conf_file "init_timer"
puts $conf_file "report_timer"
puts $conf_file "report_wns"
puts $conf_file "report_worst_paths ..."
```
- Appends timer directives to the `.conf` file.
- `init_timer`: Initializes the timing engine.
- `report_wns`: Reports worst negative slack.
- `report_worst_paths`: Outputs critical timing paths, up to 10,000 in this case — great for detailed analysis or debugging paths of interest.

---

## Quality Of Results (QOR) generation

```tcl
set time_elapsed_in_us [time {exec /home/vsduser/OpenTimer-1.0.5/bin/OpenTimer < $OutputDirectory/$DesignName.conf >& $OutputDirectory/$DesignName.results} 1]
set time_elapsed_in_sec "[expr {[lindex $time_elapsed_in_us 0]/100000}]sec"
puts "\nInfo: STA finished in $time_elapsed_in_sec seconds"
puts "\nInfo: Refer to $OutputDirectory/$DesignName.results for warnings and errors"

set worst_RAT_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {RAT}
while {[gets $report_file line] != -1} {
        if {[regexp $pattern $line]} {
                set worst_RAT_slack "[expr {[lindex $line 3]/1000}]ns"
                break
        } else {
        continue
        }
}
close $report_file

set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
        incr count [regexp -all -- $pattern $line]
}
set Number_output_violations $count
close $report_file

set worst_negative_setup_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r] 
set pattern {Setup}
while {[gets $report_file line] != -1} {
        if {[regexp $pattern $line]} {
                set worst_negative_setup_slack "[expr {[lindex $line 3]/1000}]ns"
                break
        } else {
        continue
        }
}
close $report_file

set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
        incr count [regexp -all -- $pattern $line]
}
set Number_of_setup_violations $count
close $report_file


set worst_negative_hold_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r] 
set pattern {Hold}
while {[gets $report_file line] != -1} {
        if {[regexp $pattern $line]} {
                set worst_negative_hold_slack "[expr {[lindex $line 3]/1000}]ns"
                break
        } else {
                continue
        }
}
close $report_file

set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
        incr count [regexp -all -- $pattern $line]
}
set Number_of_hold_violations $count
close $report_file



set pattern {Num of gates}
set report_file [open $OutputDirectory/$DesignName.results r] 
while {[gets $report_file line] != -1} {
        if {[regexp $pattern $line]} {
                set Instance_count "[lindex [join $line " "] 4 ]"
                break
        } else {
                continue
        }
}
close $report_file
puts "DesignName is \{$DesignName\}"
puts "time_elapsed_in_sec is \{$time_elapsed_in_sec\}"
puts "Instance_count is \{$Instance_count\}"
puts "worst_negative_setup_slack is \{$worst_negative_setup_slack\}"
puts "Number_of_setup_violations is \{$Number_of_setup_violations\}"
puts "worst_negative_hold_slack is \{$worst_negative_hold_slack\}"
puts "Number_of_hold_violations is \{$Number_of_hold_violations\}"
puts "worst_RAT_slack is \{$worst_RAT_slack\}"
puts "Number_output_violations is \{$Number_output_violations\}"

puts "\n"

puts "                                          ****PRELAYOUT TIMING RESULTS****                                        "
set formatStr "%15s %15s %15s %15s %15s %15s %15s %15s %15s"

puts [format $formatStr "----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts [format $formatStr "DesignName" "Runtime" "Instance Count" "WNS Setup" "FEP Setup" "WNS Hold" "FEP Hold" "WNS RAT" "FEP RAT"]
puts [format $formatStr "----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
foreach design_name $DesignName runtime $time_elapsed_in_sec instance_count $Instance_count wns_setup $worst_negative_setup_slack fep_setup $Number_of_setup_violations wns_hold $worst_negative_hold_slack$
        puts [format $formatStr $design_name $runtime $instance_count $wns_setup $fep_setup $wns_hold $fep_hold $wns_rat $fep_rat]
}

puts [format $formatStr "----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts "\n"
```




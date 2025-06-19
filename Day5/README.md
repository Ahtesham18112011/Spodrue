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
You're adding the final layer to your synthesis automation—executing the synthesis, checking its success, and post-processing the resulting netlist. Here's a breakdown of what your script does:

---

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

























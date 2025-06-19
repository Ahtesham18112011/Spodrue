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
   ```
   read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}
   ```
   This loads the Liberty file that provides cell characteristics, treating undefined modules as black boxes.

3. **Reading Verilog Sources**:  
   It uses `glob` to list all `.v` files in `$NetlistDirectory` and appends a `read_verilog` command for each one.

4. **Setting Top Module and Synthesizing**:  
   ```
   hierarchy -top $DesignName
   synth -top $DesignName
   ```
   These ensure correct module hierarchy and start synthesis with the given top module.

5. **Netlist Output**:  
   Writes the final synthesized Verilog netlist to:
   ```
   $OutputDirectory/$DesignName.synth.v
   ```

6. **Completion Logs**:  
   The script closes the file and logs that the script is ready and synthesis is being started.








\\

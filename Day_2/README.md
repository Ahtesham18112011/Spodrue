# Day 2: Variable Creation and Processing Constraints from CSV
## Constraints File 
A *constraints file*—often called an **SDC file** (Synopsys Design Constraints)—is like a rulebook that guides the design tools on how to handle your circuit during synthesis and place-and-route stages.

It defines critical parameters such as:

- **Timing constraints**: like clock definitions, input/output delays, and setup/hold requirements.
- **Design rules**: such as maximum fanout, transition times, and capacitance limits.
- **Operating conditions**: including voltage, temperature, and wire load models.
- **System interface constraints**: like driving cell characteristics and load values.

The file uses a syntax based on TCL (Tool Command Language), and it helps ensure that the final chip meets performance, power, and area goals.

So, in this task we need to convert the `.csv` file to the SDC file through TCL, below is the code for doing this:-

```tcl


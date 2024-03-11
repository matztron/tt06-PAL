# Testbench

Yeah I know TinyTapeout wants us to use this  [cocotb](https://docs.cocotb.org/en/stable/) to drive the DUT and check the outputs.

However here a traditional Verilog testbench was written.
To run the tests I recommend the free [OSS CAD suite](https://github.com/YosysHQ/oss-cad-suite-build).
After sourcing the OSS CAD suit environment e.g. with:

`source /Applications/oss-cad-suite/environment`

on MAC.

You can run 
`bash run_sim.sh`
in the `test/alt_testbench`-folder.
The gtkwave GUI will open and you can add signals to inspect.

If you don't want to use the shell script you can study the commands in the shell-script and execute them on your own.


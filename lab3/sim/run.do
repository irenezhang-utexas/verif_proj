# Create the library.
if [file exists work] {
    vdel -all
}
vlib work

# Compile the sources.

vlog ../dut/uart.v 

vlog +cover -sv ../tb/interfaces.sv  ../tb/uart_pkg.sv  ../tb/tb.sv 




# Simulate the design.
vsim -c top
run -all
exit

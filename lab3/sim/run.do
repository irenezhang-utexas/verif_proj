# Create the library.
if [file exists work] {
    vdel -all
}
vlib work

# Compile the sources.
vlog ../dut/ALU_netlist.v ../lib/gscl45nm.v
vlog +cover -sv ../tb/agent_in.sv  ../tb/agent_out.sv ../tb/config.sv ../tb/coverage.sv ../tb/scoreboard.sv ../tb/env.sv ../tb/interface.sv ../tb/lin.sv ../tb/sequences.sv ../tb/tb.sv ../tb/tests.sv  ../tb/uart2wb_monitor.sv ../tb/uart_driver_in.sv ../tb/uart_monitor_in.sv ../tb/uart_monitor_out.sv ../tb/wb2uart_driver.sv ../tb/wb2uart_monitor.sv  

# Simulate the design.
vsim -c top
run -all
exit

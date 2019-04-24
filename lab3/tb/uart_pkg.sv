

//`include "interfaces.sv"

package uart_pkg;


	import uvm_pkg::*;
	//`include "uvm_macros.svh"

	`include "config.sv"


	`include "sequences.sv"

	`include "uart2wb_monitor.sv"
	`include "uart_driver_in.sv"
	`include "uart_monitor_in.sv"
	`include "uart_monitor_out.sv"
	`include "wb2uart_driver.sv"
	`include "wb2uart_monitor.sv"
	`include "agent_in.sv"
	`include "agent_out.sv"


	`include "scoreboard.sv"
	
	`include "cov.sv"
	`include "env.sv"
	`include "uart_test.sv"
	`include "tests.sv"
	

	


	


endpackage:uart_pkg
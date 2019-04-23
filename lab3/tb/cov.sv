`include "uvm_macros.svh"
`include "../dut/system_config_defines.sv"
`include "../dut/register_addresses.sv"
package coverage;
import sequences::*;
import uvm_pkg::*;

class wb2uart_subscriber extends uvm_subscriber #(wb2uart);
    `uvm_component_utils(wb2uart)

    logic [15:0] 	i_wb_adr;
    logic		i_wb_we;
    logic		i_wb_stb;

    covergroup inputs;	

	uart_addr: coverpoint i_wb_adr {
	    bins amber_uart_dr	= {AMBER_UART_DR};
	    bins amber_uart_icr = {AMBER_UART_ICR};
	    bins amber_uart_rsr	= {AMBER_UART_RSR};
	    bins amber_uart_lcrh = {AMBER_UART_LCRH};
	    bins amber_uart_lcrm = {AMBER_UART_LCRM};
	    bins amber_uart_lcrl = {AMBER_UART_LCRL};
	    bins amber_uart_cr	= {AMBER_UART_CR};
	    bins amber_uart_fr	= {AMBER_UART_FR};
	    bins amber_uart_iir	= {AMBER_UART_IIR};
	    bins amber_uart_cid0 = {AMBER_UART_CID0};
	    bins amber_uart_cid1 = {AMBER_UART_CID1};
	    bins amber_uart_cid2 = {AMBER_UART_CID2};
	    bins amber_uart_cid3 = {AMBER_UART_CID3};
	    bins amber_uart_pid0 = {AMBER_UART_PID0};
	    bins amber_uart_pid1 = {AMBER_UART_PID1};
	    bins amber_uart_pid2 = {AMBER_UART_PID2};
	    bins amber_uart_pid3 = {AMBER_UART_PID3};
	} 
	uart_we: coverpoint i_wb_we {
	    bins one 	= {1};
	    bins zero	= {0};
	}
	uart_stb: coverpoint i_wb_stb {
	    bins one 	= {1};
	    bins zero	= {0};
	}

	crs_addr_cmd: cross uart_addr, uart_we, uart_stb


    endgroup: inputs

    function new(string name, uvm_component parent);
        super.new(name,parent);
        /* TODO: Uncomment*/
        inputs=new;
        
    endfunction: new


    function void write(wb2uart t);
        i_wb_adr = t.i_wb_adr[15:0];
        i_wb_se  = t.i_wb_we;
        i_wb_stb = t.i_wb_stb;
        inputs.sample();
        
    endfunction: write

endclass: wb2uart_subscriber


class dut_subscriber_in extends uvm_subscriber #(wb2uart);
    `uvm_component_utils(alu_subscriber_out)


endclass: dut_subscriber_in


endpackage: coverage

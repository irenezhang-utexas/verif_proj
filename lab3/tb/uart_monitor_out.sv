`include "uvm_macros.svh"
import uart_pkg::*;
class uart_monitor_out extends uvm_monitor;
    `uvm_component_utils(uart_monitor_out)

    uvm_analysis_port #(uart_tx_frame) aport;

    uart_dut_config uart_config_0;

    logic [3:0]  tx_state;

    virtual uart_out uart_vi_out;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        uart_config_0=uart_dut_config::type_id::create("config");
        aport=new("aport",this);
        assert( uvm_config_db #(uart_dut_config)::get(this, "", "uart_dut_config", uart_config_0) );
        uart_vi_out=uart_config_0.dut_vi_out;

    endfunction: build_phase

    task run_phase(uvm_phase phase);
      tx_state = 4'd0;
      repeat(1000)
      begin
        uart_tx_frame tx;
        
        @(posedge uart_vi_out.i_uart_clk);
        tx 		= uart_tx_frame::type_id::create("tx");
	   tx.tx_frame	= {tx.tx_frame[10:0],uart_vi_out.o_uart_txd};


        tx_state = (tx_state == 4'd12) ? 4'd0 :
		   (tx_state != 4'd0) ? tx_state + 4'd1 :
		   (uart_vi_out.o_uart_txd == 1'd0) ? 4'd1 : 4'd0;

	if (tx_state == 4'd12) aport.write(tx);
	
      end
    endtask: run_phase
endclass: uart_monitor_out



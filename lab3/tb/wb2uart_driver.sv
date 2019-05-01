`include "uvm_macros.svh"
import uart_pkg::*;

class wb2uart_driver extends uvm_driver#(wb2uart);
    `uvm_component_utils(wb2uart_driver)

    amber_dut_config dut_config_0;
    virtual dut_in dut_vi_in;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
       assert( uvm_config_db #(amber_dut_config)::get(this, "", "amber_dut_config", dut_config_0));
       dut_vi_in = dut_config_0.dut_vi_in;
    endfunction : build_phase
   
    task run_phase(uvm_phase phase);
      forever
      begin
        wb2uart tx;
        
        `uvm_info("sent_uart_frame test", "\n", UVM_LOW);
        @(posedge dut_vi_in.i_clk);
        seq_item_port.get(tx);

        if (tb.dut1.tx_fifo_full) begin        
        // interface of dut_vi_in
	  dut_vi_in.i_wb_adr	= {tx.i_wb_addr_hi,tx.i_wb_addr_lo};
	  dut_vi_in.i_wb_we	= tx.i_wb_we;
	  dut_vi_in.i_wb_stb	= tx.i_wb_stb;
	end


      end
    endtask: run_phase

endclass: wb2uart_driver



`include "uvm_macros.svh"
import uart_pkg::*;
class uart_monitor_out extends uvm_monitor;
    `uvm_component_utils(uart_monitor_out)

    uvm_analysis_port #(uart_tx_frame) aport;

    uart_dut_config uart_config_0;

    logic [3:0]  tx_state;
    logic [11:0] tx_frame;

    virtual uart_out uart_vi_out;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        uart_config_0=uart_dut_config::type_id::create("config");
        aport=new("aport",this);
        assert( uvm_config_db #(uart_dut_config)::get(this, "", "uart_dut_config", uart_config_0) );
        uart_vi_out=uart_config_0.uart_vi_out;

    endfunction: build_phase

    task run_phase(uvm_phase phase);
      repeat(1) @(posedge uart_vi_out.i_uart_clk);
      tx_state = 4'd0;
      tx_frame = 12'd0;
      uart_vi_out.i_uart_cts_n = 0;
      forever
      begin
        uart_tx_frame tx;
        
        @(posedge uart_vi_out.i_uart_clk);
            tx = uart_tx_frame::type_id::create("tx");
            tx_state = (tx_state == 4'd12) ? 4'd0 :
            (tx_state != 4'd0) ? tx_state + 4'd1 :
            (uart_vi_out.o_uart_txd == 1'd0) ? 4'd1 : 4'd0;

            if(tx_state != 4'd0)begin
                tx_frame  = {uart_vi_out.o_uart_txd,tx_frame[11:1]};
                uart_vi_out.i_uart_cts_n = 1;
                `uvm_info("tx_frame", $sformatf("data  %b",tx_frame), UVM_LOW);
                `uvm_info("getdata_from_uart", $sformatf("bit  %d",uart_vi_out.o_uart_txd), UVM_LOW);
                `uvm_info("uart_monitor_state", $sformatf("state  %d",tx_state), UVM_LOW);
            end
            


	if (tx_state == 4'd12) begin
         `uvm_info("uart_monitor_out", "\n-----------------uart_monitor_out-------------------------\n", UVM_LOW);
         `uvm_info("tx_frame", $sformatf("data  %b",tx_frame), UVM_LOW);
         `uvm_info("tx_fifo_rp", $sformatf("%d",$root.top.dut1.uart_dut.tx_fifo_rp), UVM_LOW);
         tx.tx_frame = tx_frame;
         tx_frame = 12'd0;
         aport.write(tx);
         repeat(100) @(posedge uart_vi_out.i_uart_clk);
         uart_vi_out.i_uart_cts_n = 0;
        end
        
	
      end
    endtask: run_phase
endclass: uart_monitor_out



`include "uvm_macros.svh"
import uart_pkg::*;
class uart2wb_monitor extends uvm_monitor;
    `uvm_component_utils(uart2wb_monitor)

    uvm_analysis_port #(uart2wb) aport;

    amber_dut_config dut_config_0;

    virtual dut_out dut_vi_out;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        dut_config_0=amber_dut_config::type_id::create("config");
        aport=new("aport",this);
        assert( uvm_config_db #(amber_dut_config)::get(this, "", "dut_config", dut_config_0) );
        dut_vi_out=dut_config_0.dut_vi_out;

    endfunction: build_phase

    task run_phase(uvm_phase phase);
    @(posedge dut_vi_out.i_clk);
    @(posedge dut_vi_out.i_clk);
      forever
      begin
        uart2wb tx;
        
        @(posedge dut_vi_out.i_clk);
        tx = uart2wb::type_id::create("tx");
        // assign them to the transaction "tx"
	tx.i_clk	= dut_vi_out.i_clk;
	tx.o_wb_dat	= dut_vi_out.o_wb_dat;
	tx.o_wb_ack	= dut_vi_out.o_wb_ack;
	tx.o_wb_err	= dut_vi_out.o_wb_err;

        aport.write(tx);
      end
    endtask: run_phase
endclass: uart2wb_monitor



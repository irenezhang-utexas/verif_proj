`include "uvm_macros.svh"
import uart_pkg::*;
class wb2uart_monitor extends uvm_monitor;
    `uvm_component_utils(wb2uart_monitor)

    uvm_analysis_port #(wb2uart) aport;

    amber_dut_config dut_config_0;

    virtual dut_in dut_vi_in;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        dut_config_0=amber_dut_config::type_id::create("config");
        aport=new("aport",this);
        assert( uvm_config_db #(amber_dut_config)::get(this, "", "dut_config", dut_config_0) );
        dut_vi_in=dut_config_0.dut_vi_in;

    endfunction: build_phase

    task run_phase(uvm_phase phase);
    @(posedge dut_vi_in.i_clk);
      forever
      begin
        wb2uart tx;
        @(posedge dut_vi_in.i_clk);
        tx = wb2uart::type_id::create("tx");
        // assign them to the transaction "tx"
	//tx.i_clk	= dut_vi_in.i_clk;
	tx.i_wb_addr_hi	= dut_vi_in.i_wb_adr[31:16];
    tx.i_wb_addr_lo   = dut_vi_in.i_wb_adr[15:0];
	tx.i_wb_we	= dut_vi_in.i_wb_we;
	tx.i_wb_dat	= dut_vi_in.i_wb_dat;
	tx.i_wb_stb	= dut_vi_in.i_wb_stb;
	
        aport.write(tx);
      end
    endtask: run_phase

endclass: wb2uart_monitor



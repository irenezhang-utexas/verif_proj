`include "uvm_macros.svh"
import uart_pkg::*;
class uart2wb_monitor extends uvm_monitor;
    `uvm_component_utils(uart2wb_monitor)

    uvm_analysis_port #(uart2wb) aport;

    amber_dut_config dut_config_0;

    virtual dut_out dut_vi_out;
    virtual dut_in dut_vi_in;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        dut_config_0=amber_dut_config::type_id::create("config");
        aport=new("aport",this);
        assert( uvm_config_db #(amber_dut_config)::get(this, "", "amber_dut_config", dut_config_0) );
        dut_vi_out=dut_config_0.dut_vi_out;
        dut_vi_in = dut_config_0.dut_vi_in;

    endfunction: build_phase

    task run_phase(uvm_phase phase);
     @(posedge dut_vi_out.i_clk);
      forever
      begin
        uart2wb tx;
         //@(posedge dut_vi_out.i_clk);
       @(negedge dut_vi_out.i_clk);
       //if((~dut_vi_in.i_wb_we && (~$root.top.dut1.uart_dut.rx_fifo_empty))&& dut_vi_in.i_wb_stb) begin
        if(~$root.top.dut1.uart_dut.rx_fifo_empty  ) begin
        dut_vi_in.i_wb_we = 0;
        dut_vi_in.i_wb_stb = 1;
        dut_vi_in.i_wb_adr = 0;
       //`uvm_info("uart2wb_monitor", $sformatf("we = %b stb = %b",dut_vi_in.i_wb_we,dut_vi_in.i_wb_stb), UVM_LOW);
        //wait(!dut_vi_in.i_wb_we);
        //`uvm_info("uart2wb_monitor", "\n", UVM_LOW);
        tx = uart2wb::type_id::create("tx");
        repeat(1) @(posedge dut_vi_out.i_clk);
        // assign them to the transaction "tx"

       @(negedge dut_vi_out.i_clk);
        dut_vi_in.i_wb_we = 0;
        dut_vi_in.i_wb_stb = 0;
        repeat(3) @(posedge dut_vi_out.i_clk);
        tx.i_clk    = dut_vi_out.i_clk;
        tx.o_wb_dat = dut_vi_out.o_wb_dat;
        tx.o_wb_ack = dut_vi_out.o_wb_ack;
        tx.o_wb_err = dut_vi_out.o_wb_err;
        aport.write(tx);
        repeat(100) @(posedge dut_vi_out.i_clk);
       end
      end
    endtask: run_phase
endclass: uart2wb_monitor



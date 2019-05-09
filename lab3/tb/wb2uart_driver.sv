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
      //reset
      dut_vi_in.i_wb_stb  = 0;

      repeat(200)@(posedge dut_vi_in.i_clk);
      forever
      begin
        wb2uart tx;
        @(negedge dut_vi_in.i_clk);
          //simple version: sending information only if the stb is high
          //if it is a write operation, make sure the tx fifo is not full
          seq_item_port.get_next_item(tx);
          seq_item_port.item_done();
        
          if(((tx.i_wb_we && (~$root.top.dut1.uart_dut.tx_fifo_full)) || (~tx.i_wb_we && (~$root.top.dut1.uart_dut.rx_fifo_empty))) && (tx.i_wb_stb)) begin
            dut_vi_in.i_wb_adr = {tx.i_wb_addr_hi,tx.i_wb_addr_lo};
            //dut_vi_in.i_wb_we  = tx.i_wb_we;
            //dut_vi_in.i_wb_stb = tx.i_wb_stb;
            dut_vi_in.i_wb_dat = tx.i_wb_dat;
            @(posedge dut_vi_in.i_clk);
            `uvm_info("wb_start_read_d1", $sformatf("%b",$root.top.dut1.uart_dut.wb_start_read_d1), UVM_LOW);
            `uvm_info("tx_fifo_push_not_full", $sformatf("%d",$root.top.dut1.uart_dut.tx_fifo_push_not_full), UVM_LOW);
            `uvm_info("i_wb_dat", $sformatf("%b",$root.top.dut1.uart_dut.i_wb_dat), UVM_LOW);
            `uvm_info("i_wb_we", $sformatf("%b",$root.top.dut1.uart_dut.i_wb_we), UVM_LOW);
            `uvm_info("o_wb_ack", $sformatf("%b",$root.top.dut1.uart_dut.o_wb_ack), UVM_LOW);
            repeat(1)@(negedge dut_vi_in.i_clk);
            dut_vi_in.i_wb_stb = 1'b0;
          end



        if((~$root.top.dut1.uart_dut.tx_fifo_full) && tx.i_wb_we && tx.i_wb_stb)begin
          `uvm_info("sent_wb_frame", "\n-----------------sent_wb_frame-------------------------\n", UVM_LOW);
          //`uvm_info("i_wb_dat", $sformatf("%b",tx.i_wb_dat), UVM_LOW);
          `uvm_info("tx fifo count", $sformatf("%d",$root.top.dut1.uart_dut.tx_fifo_wp), UVM_LOW);
          `uvm_info("tx_fifo_wp", $sformatf("%d",$root.top.dut1.uart_dut.tx_fifo_wp), UVM_LOW);
          `uvm_info("tx_fifo_push", $sformatf("%d",$root.top.dut1.uart_dut.tx_fifo_push), UVM_LOW);
          `uvm_info("i_wb_we", $sformatf("%d",$root.top.dut1.uart_dut.i_wb_we), UVM_LOW);
          `uvm_info("i_wb_adr", $sformatf("%d",$root.top.dut1.uart_dut.i_wb_adr), UVM_LOW);
          `uvm_info("wb_stb", $sformatf("%d",$root.top.dut1.uart_dut.i_wb_stb), UVM_LOW);
          `uvm_info("wb_start_write", $sformatf("%d",$root.top.dut1.uart_dut.wb_start_write), UVM_LOW);
          `uvm_info("wb_start_read_d1", $sformatf("%d",$root.top.dut1.uart_dut.wb_start_read_d1), UVM_LOW);
        end
        repeat(2000) @(posedge dut_vi_in.i_clk);


      end

    endtask: run_phase

endclass: wb2uart_driver



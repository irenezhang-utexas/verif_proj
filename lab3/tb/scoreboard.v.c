`include "uvm_macros.svh"
package scoreboard; 
import uvm_pkg::*;
import sequences::*;

class UART_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(UART_scoreboard)
	
	// scoreboard 1
    uvm_analysis_export #(wb2uart) sb_in_1;
    uvm_analysis_export #(wb2uart) sb_out_1;

    uvm_tlm_analysis_fifo #(wb2uart) fifo_in_1;
    uvm_tlm_analysis_fifo #(wb2uart) fifo_out_1;
	
	wb2uart tx_in_1;
    wb2uart tx_out_1;
	
	// scoreboard 2
    uvm_analysis_export #(uart_rx_frame) sb_in_2;
    uvm_analysis_export #(uart_rx_frame) sb_out_2;

    uvm_tlm_analysis_fifo #(uart_rx_frame) fifo_in_2;
    uvm_tlm_analysis_fifo #(uart_rx_frame) fifo_out_2;
	
	uart_rx_frame tx_in_2;
    uart_rx_frame tx_out_2;


    function new(string name, uvm_component parent);
        super.new(name,parent);
        tx_in_1=new("tx_in_1");
        tx_out_1=new("tx_out_1");
    endfunction: new

    function void build_phase(uvm_phase phase);
        sb_in_1=new("sb_in_1",this);
        sb_out_1=new("sb_out_1",this);
        fifo_in_1=new("fifo_in_1",this);
        fifo_out_1=new("fifo_out_1",this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        sb_in_1.connect(fifo_in_1.analysis_export);
        sb_out_1.connect(fifo_out_1.analysis_export);
    endfunction: connect_phase

    task run();
        forever begin
            fifo_in_1.get(tx_in_1);
            fifo_out_1.get(tx_out_1);
            compare_1();
        end
    endtask: run



    function new(string name, uvm_component parent);
        super.new(name,parent);
        tx_in_2=new("tx_in_2");
        tx_out_2=new("tx_out_2");
    endfunction: new

    function void build_phase(uvm_phase phase);
        sb_in_2=new("sb_in_2",this);
        sb_out_2=new("sb_out_2",this);
        fifo_in_2=new("fifo_in_2",this);
        fifo_out_2=new("fifo_out_2",this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        sb_in_2.connect(fifo_in_2.analysis_export);
        sb_out_2.connect(fifo_out_2.analysis_export);
    endfunction: connect_phase

    task run();
        forever begin
            fifo_in_2.get(tx_in_2);
            fifo_out_2.get(tx_out_2);
            compare_2();
        end
    endtask: run


    //extern virtual function [33:0] getresult; 
    extern virtual function void compare_1; 
    extern virtual function void compare_2; 
        
endclass: UART_scoreboard

function void UART_scoreboard::compare_1;
   
    //if (tx_out_1 == wishbone_input){
    if (tx_in_1.i_wb_dat == tx_out_1.o_uart_txd){
        tx_in_1.convert2string();
        tx_out_1.convert2string();
        uvm_report_info("Input is: ", tx_in_1.convert2string(), UVM_LOW);
        uvm_report_info("Output is: ", tx_out_1.convert2string(), UVM_LOW);
        $display("The result is matched");
    }
    else{
        tx_in_1.convert2string();
        tx_out_1.convert2string();
        uvm_report_info("Input is: ", tx_in_1.convert2string(), UVM_LOW);
        uvm_report_info("Output is: ", tx_out_1.convert2string(), UVM_LOW);
        $display("The result is not matched!!!");
    }
    end
endfunction

function void UART_scoreboard::compare_2;

    if (tx_in_2.o_wb_dat == tx_out_2.uart_vi_in){
        tx_in_2.convert2string();
        tx_out_2.convert2string();
        uvm_report_info("Input is: ", tx_in_2.convert2string(), UVM_LOW);
        uvm_report_info("Output is: ", tx_out_2.convert2string(), UVM_LOW);
        $display("The result is matched");
    }
    else {
        tx_in_2.convert2string();
        tx_out_2.convert2string();
        uvm_report_info("Input is: ", tx_in_2.convert2string(), UVM_LOW);
        uvm_report_info("Output is: ", tx_out_2.convert2string(), UVM_LOW);
        $display("The result is not matched!!!");
    }
    end
endfunction

endpackage: scoreboard

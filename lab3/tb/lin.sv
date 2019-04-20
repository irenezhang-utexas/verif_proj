`include "uvm_macros.svh"
package scoreboard; 
import uvm_pkg::*;
import sequences::*;

class UART_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(UART_scoreboard)
	
    uvm_analysis_export #(UART_transaction_in_1) sb_in_1;
    uvm_analysis_export #(UART_transaction_out_1) sb_out_1;

    uvm_tlm_analysis_fifo #(UART_transaction_in_1) fifo_in_1;
    uvm_tlm_analysis_fifo #(UART_transaction_out_1) fifo_out_1;
	
	UART_transaction_in_1 tx_in_1;
    UART_transaction_out_1 tx_out_1;
	

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
            compare();
        end
    endtask: run

    //extern virtual function [33:0] getresult; 
    extern virtual function void compare_1; 
    //extern virtual function void compare_2; 
        
endclass: UART_scoreboard

function void UART_scoreboard::compare_1;
 
    if (tx_out_1 == wishbone_input){
        tx_in_1.convert2string();
        tx_out_1.convert2string();
        uvm_report_info("Input is: ", tx_in_1.convert2string(), UVM_LOW);
        uvm_report_info("Output is: ", tx_out_1.convert2string(), UVM_LOW);
        $display("The result is matched");
    }
    else if (tx_out_1 != wishbone_input){
        tx_in_1.convert2string();
        tx_out_1.convert2string();
        uvm_report_info("Input is: ", tx_in_1.convert2string(), UVM_LOW);
        uvm_report_info("Output is: ", tx_out_1.convert2string(), UVM_LOW);
        $display("The result is not matched!!!");
    }else if (tx_in_1 == wishbone_output){
        tx_in_1.convert2string();
        tx_out_1.convert2string();
        uvm_report_info("Input is: ", tx_in_1.convert2string(), UVM_LOW);
        uvm_report_info("Output is: ", tx_out_1.convert2string(), UVM_LOW);
        $display("The result is matched");
    }else if (tx_in_1 != wishbone_output){
        tx_in_1.convert2string();
        tx_out_1.convert2string();
        uvm_report_info("Input is: ", tx_in_1.convert2string(), UVM_LOW);
        uvm_report_info("Output is: ", tx_out_1.convert2string(), UVM_LOW);
        $display("The result is not matched!!!");
    }
    end
endfunction

endpackage: scoreboard

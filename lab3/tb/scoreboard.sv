`include "uvm_macros.svh"
package scoreboard; 
import uvm_pkg::*;
import sequences::*;

class alu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(alu_scoreboard)

    uvm_analysis_export #(alu_transaction_in) sb_in;
    uvm_analysis_export #(alu_transaction_out) sb_out;

    uvm_tlm_analysis_fifo #(alu_transaction_in) fifo_in;
    uvm_tlm_analysis_fifo #(alu_transaction_out) fifo_out;

    alu_transaction_in tx_in;
    alu_transaction_out tx_out;

    function new(string name, uvm_component parent);
        super.new(name,parent);
        tx_in=new("tx_in");
        tx_out=new("tx_out");
    endfunction: new

    function void build_phase(uvm_phase phase);
        sb_in=new("sb_in",this);
        sb_out=new("sb_out",this);
        fifo_in=new("fifo_in",this);
        fifo_out=new("fifo_out",this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        sb_in.connect(fifo_in.analysis_export);
        sb_out.connect(fifo_out.analysis_export);
    endfunction: connect_phase

    task run();
        forever begin
            fifo_in.get(tx_in);
            fifo_out.get(tx_out);
            compare();
        end
    endtask: run

    extern virtual function [33:0] getresult; 
    extern virtual function void compare; 
        
endclass: alu_scoreboard

function void alu_scoreboard::compare;
    //TODO: Write this function to check whether the output of the DUT matches
    //the spec.
    //Use the getresult() function to get the spec output.
    //Consider using `uvm_info(ID,MSG,VERBOSITY) in this function to print the
    //results of the comparison.
    //You can use tx_in.convert2string() and tx_out.convert2string() for
    //debugging purposes

    reg COUT;
    reg VOUT;
    reg [31:0] OUT;
    reg [33:0] cal_result;
    reg [33:0] result = getresult();

    if (tx_in.rst) begin
	cal_result = 34'b0;
    end else begin
	COUT = 1'b0;
	VOUT = 1'b0;
	case (tx_in.opcode)
	    5'b00000: begin
		OUT = ~ tx_in.A;
	    end
	    5'b00011: begin
		OUT = tx_in.A ^ tx_in.B;
	    end
	    5'b00101: begin
		OUT = tx_in.A & tx_in.B;
	    end
	    5'b00111: begin
		OUT = tx_in.A | tx_in.B;
	    end
	    5'b01100: begin
		OUT = ($signed(tx_in.A) <= $signed(tx_in.B)) ? 32'b1 : 32'b0;
	    end
	    5'b01001: begin
		OUT = ($signed(tx_in.A) < $signed(tx_in.B)) ? 32'b1 : 32'b0;
	    end
	    5'b01110: begin
		OUT = ($signed(tx_in.A) >= $signed(tx_in.B)) ? 32'b1 : 32'b0;
	    end
	    5'b01011: begin
		OUT = ($signed(tx_in.A) > $signed(tx_in.B)) ? 32'b1 : 32'b0;
	    end
	    5'b01111: begin
		OUT = ($signed(tx_in.A) == $signed(tx_in.B)) ? 32'b1 : 32'b0;
	    end
	    5'b01010: begin
		OUT = ($signed(tx_in.A) != $signed(tx_in.B)) ? 32'b1 : 32'b0;
	    end
	    5'b10101: begin //signed addition TODO
		{COUT, OUT} = $signed(tx_in.A) + $signed(tx_in.B) + tx_in.CIN;
		VOUT = ((tx_in.A[31] == tx_in.B[31]) & (tx_in.A[31] != OUT[31]))? 1'b1 : 1'b0;
	    end
	    5'b10001: begin
		{COUT, OUT} = tx_in.A + tx_in.B + tx_in.CIN;
		VOUT = COUT;
	    end
	    5'b10100: begin //signed subtraction TODO
		{COUT, OUT} = $signed(tx_in.A) - $signed(tx_in.B);
		VOUT = ((tx_in.A[31] == tx_in.B[31]) & (tx_in.A[31] != OUT[31]))? 1'b1 : 1'b0;
	    end
	    5'b10000: begin
		{COUT, OUT} = tx_in.A - tx_in.B;
	    end
	    5'b10111: begin //signed TODO
		{COUT, OUT} = $signed(tx_in.A) + 1;
		VOUT = ((tx_in.A[31] == 1'b0) & (tx_in.A[31] != OUT[31]))? 1'b1 : 1'b0;
	    end
	    5'b10110: begin //signed TODO
		{COUT, OUT} = $signed(tx_in.A) - 1;
		VOUT = ((tx_in.A[31] == 1'b1) & (tx_in.A[31] != OUT[31]))? 1'b1 : 1'b0;
	    end
	    5'b11010: begin
		OUT = tx_in.A << tx_in.B[4:0];
	    end
	    5'b11011: begin
		OUT = tx_in.A >> tx_in.B[4:0];
	    end
	    5'b11100: begin
		reg one = |(tx_in.A >> (32- tx_in.B[4:0]));
		OUT = $signed(tx_in.A) <<< tx_in.B[4:0];
		VOUT = (one || (OUT[31] != tx_in.A[31])) ? 1'b1: 1'b0;
	    end
	    5'b11101: begin
		OUT = $signed(tx_in.A) >>> tx_in.B[4:0];
		VOUT = |(tx_in.A << (32 - tx_in.B[4:0]));
	    end
	    5'b11000: begin //rotate left shift
		reg [63:0] A2 = {tx_in.A,tx_in.A};
		OUT = (A2 >> (32 - tx_in.B[4:0]));
	    end
	    5'b11001: begin //rotate right shift
		reg [63:0] A2 = {tx_in.A,tx_in.A};
		OUT = (A2 >> tx_in.B[4:0]);
	    end
	    default: begin
		OUT = 32'b0;
	    end
	endcase
	cal_result = {VOUT,COUT,OUT};
    end


    `uvm_info(" ",{tx_in.convert2string()}, UVM_HIGH);
    if (cal_result != result) begin
    	`uvm_info(" ",{"BUG FOUND!!!"}, UVM_HIGH);
    	`uvm_info("RESULT:  ",{tx_out.convert2string()}, UVM_HIGH);
    	`uvm_info("EXPECPED:",{$sformatf("OUT = %b, COUT = %b, VOUT = %b",cal_result[31:0],cal_result[32],cal_result[33])}, UVM_HIGH);
    end

endfunction




function [33:0] alu_scoreboard::getresult;
    //TODO: Remove the statement below
    //Modify this function to return a 34-bit result {VOUT, COUT,OUT[31:0]} which is
    //consistent with the given spec.

    reg VOUT = tx_out.VOUT;
    reg COUT = tx_out.COUT;
    reg [31:0] OUT = tx_out.OUT;

    return {VOUT, COUT, OUT};    

endfunction

endpackage: scoreboard

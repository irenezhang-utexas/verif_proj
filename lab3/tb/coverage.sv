`include "uvm_macros.svh"
package coverage;
import sequences::*;
import uvm_pkg::*;

class alu_subscriber_in extends uvm_subscriber #(alu_transaction_in);
    `uvm_component_utils(alu_subscriber_in)

    //Declare Variables
    logic [31:0] A;
    logic [31:0] B;
    logic [4:0] opcode;
    logic cin;

    //TODO: Add covergroups for the inputs
    covergroup inputs;
	cp_opcode: coverpoint opcode {
	    bins logic_cp = {[0:7]};
	    bins comp_cp  = {[8:15]};
	    bins arith_cp = {[16:23]};
	    bins shift_cp = {[24:31]};
	}

	opcode_bits: coverpoint opcode[2:0] {
	    bins zero = {0};
	    bins one  = {1};
	    bins two  = {2};
	    bins three = {3};
	    bins four = {4};
	    bins five = {5};
	    bins six  = {6};
	    bins seven = {7};
	}
   
	cp_cin: coverpoint cin{
	    bins zero = {0};
	    bins one  = {1};
	}
 
    endgroup: inputs
    

    function new(string name, uvm_component parent);
        super.new(name,parent);
        /* TODO: Uncomment*/
        inputs=new;
        
    endfunction: new

    function void write(alu_transaction_in t);
        A={t.A};
        B={t.B};
        opcode={t.opcode};
        cin={t.CIN};
        /* TODO: Uncomment */
        inputs.sample();
        
    endfunction: write

endclass: alu_subscriber_in

class alu_subscriber_out extends uvm_subscriber #(alu_transaction_out);
    `uvm_component_utils(alu_subscriber_out)

    logic [31:0] out;
    logic cout;
    logic vout;

    //TODO: Add covergroups for the outputs
    covergroup outputs;
	cp_cout: coverpoint cout {
	    bins zero = {0};
	    bins one  = {1};
	}
	cp_vout: coverpoint vout {
	    bins zero = {0};
	    bins one  = {1};
	}

    endgroup: outputs

function new(string name, uvm_component parent);
    super.new(name,parent);
    /* TODO: Uncomment */
    outputs=new;
    
endfunction: new

function void write(alu_transaction_out t);
    out={t.OUT};
    cout={t.COUT};
    vout={t.VOUT};
    /*TODO: Uncomment */
    outputs.sample();
   
endfunction: write
endclass: alu_subscriber_out

endpackage: coverage

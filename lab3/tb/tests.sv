package tests;
`include "uvm_macros.svh"
import modules_pkg::*;
import uvm_pkg::*;
import sequences::*;
import scoreboard::*;

class rst_test extends alu_test;
    `uvm_component_utils(rst_test)

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new
    
    task run_phase(uvm_phase phase);
	
	rst_commands seq;
	seq = rst_commands::type_id::create("seq");
	assert( seq.randomize() );
	phase.raise_objection(this);
	seq.start(alu_env_h.alu_agent_in_h.alu_sequencer_in_h);

	phase.drop_objection(this);
    endtask: run_phase     
endclass: rst_test

class logic_test extends alu_test;
    `uvm_component_utils(logic_test)

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new
    
    task run_phase(uvm_phase phase);
	
	logic_commands seq;
	seq = logic_commands::type_id::create("seq");
	assert( seq.randomize() );
	phase.raise_objection(this);
	seq.start(alu_env_h.alu_agent_in_h.alu_sequencer_in_h);

	phase.drop_objection(this);
    endtask: run_phase     
endclass: logic_test


endpackage: tests

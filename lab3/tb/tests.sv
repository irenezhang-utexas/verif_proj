`include "uvm_macros.svh"
import uart_pkg::*;



class test1 extends uart_test;
    `uvm_component_utils(test1)

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new
    
    task run_phase(uvm_phase phase);
	
	tx_seq seq;
	seq = tx_seq::type_id::create("seq");
	assert( seq.randomize() );
	phase.raise_objection(this);

	seq.start(env_h.agent_in_h.wb2uart_sequencer_in_h);

	phase.drop_objection(this);
    endtask: run_phase     
endclass: test1




class test2 extends uart_test;
    `uvm_component_utils(test2)

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new
    
    task run_phase(uvm_phase phase);
	
	rx_seq seq;
	seq = rx_seq::type_id::create("seq");
	assert( seq.randomize() );
	phase.raise_objection(this);

	seq.start(env_h.agent_in_h.rx_frame_sequencer_in_h);

	phase.drop_objection(this);
    endtask: run_phase     
endclass: test2

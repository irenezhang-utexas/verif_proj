`include "uvm_macros.svh"
package sequences;

    import uvm_pkg::*;

    class alu_transaction_in extends uvm_sequence_item;
         // TODO: Register the  alu_transaction_in object. Hint: Look at other classes to find out what is missing.
	`uvm_object_utils(alu_transaction_in);

        rand logic [31:0] A;
        rand logic [31:0] B;
        rand logic [4:0] opcode;
        rand logic rst;
        rand logic CIN;

        //TODO: Add constraints here
	// CIN=1 when sub/subu
        constraint cin_sub {((opcode != 5'b10100 && opcode != 5'b10000) || CIN == 1);} 

	constraint rst_con {
	   rst == 1;
	}

	constraint rst_b_con {
	   rst == 0;
	}

	constraint logic_op{
	    opcode >= 0;
	    opcode <= 7;
	}

	constraint comp_op{
	    opcode >= 8;
	    opcode <= 15;
	}

	constraint arith_op{
	    opcode >= 16;
	    opcode <= 23;
	}

	constraint shift_op{
	    opcode >= 24;
	    opcode <= 31;
	}

	constraint AgeB {
	    $signed(A) >= $signed(B);
	}

	constraint AleB {
	    $signed(A) <= $signed(B);
	}

	constraint AeqB {
	    A == B;
	}

    

        function new(string name = "");
            super.new(name);
        endfunction: new

        function string convert2string;
            convert2string={$sformatf("Operand A = %b, Operand B = %b, Opcode = %b, CIN = %b, rst = %b",A,B,opcode,CIN,rst)};
        endfunction: convert2string

    endclass: alu_transaction_in


    class alu_transaction_out extends uvm_sequence_item;
        // TODO: Register the  alu_transaction_out object. Hint: Look at other classes to find out what is missing.
	`uvm_object_utils(alu_transaction_out);

        logic [31:0] OUT;
        logic COUT;
        logic VOUT;

        function new(string name = "");
            super.new(name);
        endfunction: new;
        
        function string convert2string;
            convert2string={$sformatf("OUT = %b, COUT = %b, VOUT = %b",OUT,COUT,VOUT)};
        endfunction: convert2string

    endclass: alu_transaction_out

    class rst_seq extends uvm_sequence #(alu_transaction_in);
        `uvm_object_utils(rst_seq)

        function new(string name = "");
            super.new(name);
        endfunction: new

        task body;
            alu_transaction_in tx;
            tx=alu_transaction_in::type_id::create("tx");
            start_item(tx);

	    tx.rst_b_con.constraint_mode(0); 
	    tx.logic_op.constraint_mode(0); 
	    tx.comp_op.constraint_mode(0); 
	    tx.arith_op.constraint_mode(0); 
	    tx.shift_op.constraint_mode(0); 
	    tx.AgeB.constraint_mode(0); 
	    tx.AleB.constraint_mode(0); 
	    tx.AeqB.constraint_mode(0); 


            assert(tx.randomize());
            finish_item(tx);
        endtask: body
    endclass: rst_seq

    class rst_commands extends uvm_sequence #(alu_transaction_in);
        `uvm_object_utils(rst_commands)
        `uvm_declare_p_sequencer(uvm_sequencer#(alu_transaction_in))

        function new (string name = "");
            super.new(name);
        endfunction: new

        task body;
            repeat(100)
            begin
                rst_seq seq;
                seq = rst_seq::type_id::create("seq");
                assert( seq.randomize() );
                seq.start(p_sequencer);
            end
        endtask: body

    endclass: rst_commands

    class logic_seq extends uvm_sequence #(alu_transaction_in);
        `uvm_object_utils(logic_seq)

        function new(string name = "");
            super.new(name);
        endfunction: new

        task body;
            alu_transaction_in tx;
            tx=alu_transaction_in::type_id::create("tx");
            start_item(tx);

	    tx.rst_con.constraint_mode(0); 
	    tx.comp_op.constraint_mode(0); 
	    tx.arith_op.constraint_mode(0); 
	    tx.shift_op.constraint_mode(0); 
	    tx.AgeB.constraint_mode(0); 
	    tx.AleB.constraint_mode(0); 
	    tx.AeqB.constraint_mode(0); 


            assert(tx.randomize());
            finish_item(tx);
        endtask: body
    endclass: logic_seq

    class logic_commands extends uvm_sequence #(alu_transaction_in);
        `uvm_object_utils(logic_commands)
        `uvm_declare_p_sequencer(uvm_sequencer#(alu_transaction_in))

        function new (string name = "");
            super.new(name);
        endfunction: new

        task body;
            repeat(100)
            begin
                logic_seq seq;
                seq = logic_seq::type_id::create("seq");
                assert( seq.randomize() );
                seq.start(p_sequencer);
            end
        endtask: body

    endclass: logic_commands


    class shift_seq extends uvm_sequence #(alu_transaction_in);
        `uvm_object_utils(shift_seq)

        function new(string name = "");
            super.new(name);
        endfunction: new

        task body;
            alu_transaction_in tx;
            tx=alu_transaction_in::type_id::create("tx");
            start_item(tx);

	    tx.rst_con.constraint_mode(0); 
	    tx.comp_op.constraint_mode(0); 
	    tx.arith_op.constraint_mode(0); 
	    tx.logic_op.constraint_mode(0); 
	    tx.AgeB.constraint_mode(0); 
	    tx.AleB.constraint_mode(0); 
	    tx.AeqB.constraint_mode(0); 


            assert(tx.randomize());
            finish_item(tx);
        endtask: body
    endclass: shift_seq

    class shift_commands extends uvm_sequence #(alu_transaction_in);
        `uvm_object_utils(shift_commands)
        `uvm_declare_p_sequencer(uvm_sequencer#(alu_transaction_in))

        function new (string name = "");
            super.new(name);
        endfunction: new

        task body;
            repeat(100)
            begin
                shift_seq seq;
                seq = shift_seq::type_id::create("seq");
                assert( seq.randomize() );
                seq.start(p_sequencer);
            end
        endtask: body

    endclass: shift_commands


    class arith_seq extends uvm_sequence #(alu_transaction_in);
        `uvm_object_utils(arith_seq)

        function new(string name = "");
            super.new(name);
        endfunction: new

        task body;
            alu_transaction_in tx;
            tx=alu_transaction_in::type_id::create("tx");
            start_item(tx);

	    tx.rst_con.constraint_mode(0); 
	    tx.comp_op.constraint_mode(0); 
	    tx.shift_op.constraint_mode(0); 
	    tx.logic_op.constraint_mode(0); 
	    tx.AgeB.constraint_mode(0); 
	    tx.AleB.constraint_mode(0); 
	    tx.AeqB.constraint_mode(0); 


            assert(tx.randomize());
            finish_item(tx);
        endtask: body
    endclass: arith_seq

    class arith_commands extends uvm_sequence #(alu_transaction_in);
        `uvm_object_utils(arith_commands)
        `uvm_declare_p_sequencer(uvm_sequencer#(alu_transaction_in))

        function new (string name = "");
            super.new(name);
        endfunction: new

        task body;
            repeat(100)
            begin
                arith_seq seq;
                seq = arith_seq::type_id::create("seq");
                assert( seq.randomize() );
                seq.start(p_sequencer);
            end
        endtask: body

    endclass: arith_commands

    class comp_le_seq extends uvm_sequence #(alu_transaction_in);
        `uvm_object_utils(comp_le_seq)

        function new(string name = "");
            super.new(name);
        endfunction: new

        task body;
            alu_transaction_in tx;
            tx=alu_transaction_in::type_id::create("tx");
            start_item(tx);

	    tx.rst_con.constraint_mode(0); 
	    tx.arith_op.constraint_mode(0); 
	    tx.shift_op.constraint_mode(0); 
	    tx.logic_op.constraint_mode(0); 
	    tx.AgeB.constraint_mode(0); 
	    tx.AeqB.constraint_mode(0); 


            assert(tx.randomize());
            finish_item(tx);
        endtask: body
    endclass: comp_le_seq

    class comp_le_commands extends uvm_sequence #(alu_transaction_in);
        `uvm_object_utils(comp_le_commands)
        `uvm_declare_p_sequencer(uvm_sequencer#(alu_transaction_in))

        function new (string name = "");
            super.new(name);
        endfunction: new

        task body;
            repeat(50)
            begin
                comp_le_seq seq;
                seq = comp_le_seq::type_id::create("seq");
                assert( seq.randomize() );
                seq.start(p_sequencer);
            end
        endtask: body

    endclass: comp_le_commands

class comp_eq_seq extends uvm_sequence #(alu_transaction_in);
        `uvm_object_utils(comp_eq_seq)

        function new(string name = "");
            super.new(name);
        endfunction: new

        task body;
            alu_transaction_in tx;
            tx=alu_transaction_in::type_id::create("tx");
            start_item(tx);

	    tx.rst_con.constraint_mode(0); 
	    tx.arith_op.constraint_mode(0); 
	    tx.shift_op.constraint_mode(0); 
	    tx.logic_op.constraint_mode(0); 
	    tx.AgeB.constraint_mode(0); 
	    tx.AleB.constraint_mode(0); 


            assert(tx.randomize());
            finish_item(tx);
        endtask: body
    endclass: comp_eq_seq

    class comp_eq_commands extends uvm_sequence #(alu_transaction_in);
        `uvm_object_utils(comp_eq_commands)
        `uvm_declare_p_sequencer(uvm_sequencer#(alu_transaction_in))

        function new (string name = "");
            super.new(name);
        endfunction: new

        task body;
            repeat(50)
            begin
                comp_eq_seq seq;
                seq = comp_eq_seq::type_id::create("seq");
                assert( seq.randomize() );
                seq.start(p_sequencer);
            end
        endtask: body

    endclass: comp_eq_commands


class comp_ge_seq extends uvm_sequence #(alu_transaction_in);
        `uvm_object_utils(comp_ge_seq)

        function new(string name = "");
            super.new(name);
        endfunction: new

        task body;
            alu_transaction_in tx;
            tx=alu_transaction_in::type_id::create("tx");
            start_item(tx);

	    tx.rst_con.constraint_mode(0); 
	    tx.arith_op.constraint_mode(0); 
	    tx.shift_op.constraint_mode(0); 
	    tx.logic_op.constraint_mode(0); 
	    tx.AeqB.constraint_mode(0); 
	    tx.AleB.constraint_mode(0); 


            assert(tx.randomize());
            finish_item(tx);
        endtask: body
    endclass: comp_ge_seq

    class comp_ge_commands extends uvm_sequence #(alu_transaction_in);
        `uvm_object_utils(comp_ge_commands)
        `uvm_declare_p_sequencer(uvm_sequencer#(alu_transaction_in))

        function new (string name = "");
            super.new(name);
        endfunction: new

        task body;
            repeat(50)
            begin
                comp_ge_seq seq;
                seq = comp_ge_seq::type_id::create("seq");
                assert( seq.randomize() );
                seq.start(p_sequencer);
            end
        endtask: body

    endclass: comp_ge_commands



endpackage: sequences

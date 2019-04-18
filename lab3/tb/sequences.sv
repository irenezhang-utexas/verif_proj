`include "uvm_macros.svh"
`include "register_addresses.v"
package sequences;

    import uvm_pkg::*;

    class alu_transaction_in extends uvm_sequence_item;
	`uvm_object_utils(alu_transaction_in);

        rand logic [15:0] 	i_wb_adr_hi;
        rand logic [15:0] 	i_wb_adr_lo;
        rand logic		i_wb_we;
        rand logic 		i_wb_stb;
	rand logic		start_bit;
	rand logic	 	serial_bit;

	// wb addr is uart addr
        constraint uart_addr {
		i_wb_adr_hi dist {AMBER_UART_DR := 40, [1:65535] := 50};
	} 
   
	// constraint to disable ; used to test fifo full
	constraint fifo_empty {
		i_wb_stb dist {0:= , 1:= 1};
	}

	// constraint to disable uart_stb; used to test fifo full
	constraint fifo_full {
		i_wb_stb == 1'b0;
	}


        function new(string name = "");
            super.new(name);
        endfunction: new

        function string convert2string;
            convert2string={$sformatf("wb_addr: %b, wb_we: %b, wb_stb: %b, uart_rxd: %b, start_bit: %b, seial_bit: %b",i_wb_adr,i_wb_we,i_wb_stb,i_uart_rxd,start_bit,serial_bit)};
        endfunction: convert2string

    endclass: alu_transaction_in


    class alu_transaction_out extends uvm_sequence_item;
        // TODO: Register the  alu_transaction_out object. Hint: Look at other classes to find out what is missing.
	`uvm_object_utils(alu_transaction_out);

        logic [31:0] 	o_wb_dat;
        logic		o_wb_ack;
        logic 		o_uart_rts_n;

        function new(string name = "");
            super.new(name);
        endfunction: new;
        
        function string convert2string;
            convert2string={$sformatf("o_uart_rts_n: %b, o_wb_ack: %b\no_wb_dat: %b",o_uart_rts_n,o_wb_ack,o_wb_dat)};
        endfunction: convert2string

    endclass: alu_transaction_out

    class rx_seq extends uvm_sequence #(alu_transaction_in);
        `uvm_object_utils(rx_seq)

        function new(string name = "");
            super.new(name);
        endfunction: new

        task body;

	    // general test: uart always receives data; amber core always pops data
	    `uvm_info("general test", "\n--------------------------start------------------------------\n", UVM_LOW);
	    repeat()
	    begin

            	alu_transaction_in tx;
            	tx=alu_transaction_in::type_id::create("tx");
            	start_item(tx);

	    	tx.uart_addr.constraint_mode(0); 

            	assert(tx.randomize());
            	finish_item(tx);

	    end

	    // general test: uart always receives data; amber core does not pops data
	    `uvm_info("fifo full test", "\n--------------------------start------------------------------\n", UVM_LOW);
	    repeat()
	    begin

            	alu_transaction_in tx;
            	tx=alu_transaction_in::type_id::create("tx");
            	start_item(tx);

	    	tx.uart_addr.constraint_mode(0); 

            	assert(tx.randomize());
            	finish_item(tx);

	    end

	    // general test: uart does not receive data; amber core always pops data
	    `uvm_info("fifo empty test", "\n--------------------------start------------------------------\n", UVM_LOW);
	    repeat()
	    begin

            	alu_transaction_in tx;
            	tx=alu_transaction_in::type_id::create("tx");
            	start_item(tx);

	    	tx.uart_addr.constraint_mode(0); 

            	assert(tx.randomize());
            	finish_item(tx);

	    end

	    // general test: uart always receives data; amber core always pops data
	    `uvm_info("general test", "\n--------------------------start------------------------------\n", UVM_LOW);
	    repeat()
	    begin

            	alu_transaction_in tx;
            	tx=alu_transaction_in::type_id::create("tx");
            	start_item(tx);

	    	tx.uart_addr.constraint_mode(0); 

            	assert(tx.randomize());
            	finish_item(tx);

	    end


        endtask: body
    endclass: rx_seq

endpackage: sequences


`include "uvm_macros.svh"
`include "register_addresses.v"
package sequences;

    import uvm_pkg::*;

    class wb2uart extends uvm_sequence_item;
	`uvm_object_utils(wb2uart);

        rand logic [15:0] 	i_wb_addr_hi;
        rand logic [15:0] 	i_wb_addr_lo;
	rand logic [31:0]	i_wb_dat;
        rand logic		i_wb_we;
        rand logic 		i_wb_stb;

	// wb addr is uart addr
        constraint uart_addr {
		i_wb_addr_lo dist {AMBER_UART_DR := 40, [1:65535] := 50};
	} 
   
	// constraint to disable uart_stb; used to test fifo full
	constraint fifo_full {
		i_wb_stb == 1'b0;
	}

        function new(string name = "");
            super.new(name);
        endfunction: new

        function string convert2string;
            convert2string={$sformatf("wb_addr: %b, wb_we: %b, wb_stb: %b\n",{i_wb_addr_hi,i_wb_addr_lo},i_wb_we,i_wb_stb)};
        endfunction: convert2string

    endclass: wb2uart


    class uart_rx_frame extends uvm_sequence_item;

	rand bit start_bit;
	rand bit [7:0] payload;
	rand bit [1:0] stop_bits;

  	// Default constraints  //lab1_note2
	constraint default_start_bit 	{ start_bit == 1'b0;}
	constraint default_stop_bits 	{ stop_bits == 2'b11;}
	constraint fifo_empty 		{ start_bit == 1'b1;}

  	`uvm_object_utils_begin(uart_frame)
    	    `uvm_field_int(start_bit, UVM_DEFAULT)
    	    `uvm_field_int(payload, UVM_DEFAULT)
    	    `uvm_field_int(stop_bits, UVM_DEFAULT)
	`uvm_object_utils_end

	function new(string name = "uart_frame");
	    super.new(name);
	endfunction

    endclass: uart_frame

    class uart2wb extends uvm_sequence_item;
        // TODO: Register the  alu_transaction_out object. Hint: Look at other classes to find out what is missing.
	`uvm_object_utils(alu_transaction_out);

	logic		i_clk;
        logic [31:0] 	o_wb_dat;
        logic		o_wb_ack;
        logic 		o_wb_err;

        function new(string name = "");
            super.new(name);
        endfunction: new;
        
        function string convert2string;
            convert2string={$sformatf("o_uart_rts_n: %b, o_wb_ack: %b\no_wb_dat: %b",o_uart_rts_n,o_wb_ack,o_wb_dat)};
        endfunction: convert2string

    endclass: uart2wb

    class uart_tx_frame extends uvm_sequence_item;
        // TODO: Register the  alu_transaction_out object. Hint: Look at other classes to find out what is missing.
	`uvm_object_utils(alu_transaction_out);

	logic		i_uart_clk;
        logic		o_uart_txd;
        logic 		o_uart_rts_n;

        function new(string name = "");
            super.new(name);
        endfunction: new;
        
        function string convert2string;
            convert2string={$sformatf("o_uart_rts_n: %b, o_wb_ack: %b\no_wb_dat: %b",o_uart_rts_n,o_wb_ack,o_wb_dat)};
        endfunction: convert2string

    endclass: uart2wb


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

	    	tx.fifo_full.constraint_mode(0); 
	    	tx.fifo_empty.constraint_mode(0); 

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

	    	tx.fifo_full.constraint_mode(1); 
	    	tx.fifo_empty.constraint_mode(0); 

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

	    	tx.fifo_full.constraint_mode(0); 
	    	tx.fifo_empty.constraint_mode(1); 

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

	    	tx.fifo_full.constraint_mode(0); 
	    	tx.fifo_empty.constraint_mode(0); 

            	assert(tx.randomize());
            	finish_item(tx);

	    end


        endtask: body
    endclass: rx_seq

endpackage: sequences


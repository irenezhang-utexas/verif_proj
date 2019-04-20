
class uart_driver_in extends uvm_driver#(alu_transaction_in);
    `uvm_component_utils(uart_driver_in)

    uart_dut_config dut_config_0;
    virtual uart_in uart_vi_in;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
       assert( uvm_config_db #(uart_dut_config)::get(this, "", "dut_config", dut_config_0));
       uart_vi_in = dut_config_0.uart_vi_in;
    endfunction : build_phase
   
    task run_phase(uvm_phase phase);
      forever
      begin
        alu_transaction_in tx;
        
        @(posedge uart_vi_in.i_uart_clk);
        seq_item_port.get(tx);
        
        // interface of dut_vi_in
	uart_vi_in.i_wb_stb	= tx.i_wb_stb;
	uart_vi_in.i_uart_rxd 	= tx.i_uart_rxd;

      end
    endtask: run_phase

endclass: uart_driver_in



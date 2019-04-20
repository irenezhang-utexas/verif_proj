
class uart_monitor_in extends uvm_monitor;
    `uvm_component_utils(uart_monitor_in)

    uvm_analysis_port #(alu_transaction_in) aport;

    uart_dut_config dut_config_0;

    virtual uart_in uart_vi_in;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        dut_config_0=amber_dut_config::type_id::create("config");
        aport=new("aport",this);
        assert( uvm_config_db #(amber_dut_config)::get(this, "", "dut_config", dut_config_0) );
        uart_vi_in=dut_config_0.uart_vi_in;

    endfunction: build_phase

    task run_phase(uvm_phase phase);
    @(posedge uart_vi_in.i_uart_clk);
      forever
      begin
        alu_transaction_in tx;
        @(posedge uart_vi_in.i_uart_clk);
        tx = alu_transaction_in::type_id::create("tx");
        // assign them to the transaction "tx"
	tx.i_uart_cts_n	= uart_vi_in.i_uart_cts_n;
	tx.i_uart_rxd	= uart_vi_in.i_uart_rxd;
	
        aport.write(tx);
      end
    endtask: run_phase

endclass: uart_monitor_in




class uart_test extends uvm_test;
    `uvm_component_utils(uart_test)

    uart_dut_config dut_config_0;
    amber_dut_config dut_config_1;
    env env_h;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        dut_config_0 = new();
        dut_config_1 = new();
        if(!uvm_config_db #(virtual dut_in)::get( this, "", "dut_vi_in", dut_config_1.dut_vi_in))
          `uvm_fatal("NOVIF", "No virtual interface set for dut_in")
        
        if(!uvm_config_db #(virtual dut_out)::get( this, "", "dut_vi_out", dut_config_1.dut_vi_out))
          `uvm_fatal("NOVIF", "No virtual interface set for dut_out")

        if(!uvm_config_db #(virtual uart_in)::get( this, "", "dut_vi_in", dut_config_0.dut_vi_in))
          `uvm_fatal("NOVIF", "No virtual interface set for uart_in")
        
        if(!uvm_config_db #(virtual uart_out)::get( this, "", "dut_vi_out", dut_config_0.dut_vi_out))
          `uvm_fatal("NOVIF", "No virtual interface set for uart_out")
            
        uvm_config_db #(uart_dut_config)::set(this, "*", "uart_dut_config", dut_config_0);
        uvm_config_db #(amber_dut_config)::set(this, "*", "amber_dut_config", dut_config_1);


        env_h = env::type_id::create("env_h", this);
    endfunction: build_phase

endclass:uart_test
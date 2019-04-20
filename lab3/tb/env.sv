class env extends uvm_env;
    `uvm_component_utils(env)

    agent_in agent_in_h;
    agent_out agent_out_h;
    alu_subscriber_in alu_subscriber_in_h;
    alu_subscriber_out alu_subscriber_out_h;
    UART_scoreboard uart_scoreboard_h;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        agent_in_h = agent_in::type_id::create("agent_in_h",this);
        agent_out_h = agent_out::type_id::create("agent_out_h",this);
        alu_subscriber_in_h = alu_subscriber_in::type_id::create("alu_subscriber_in_h",this);
        alu_subscriber_out_h = alu_subscriber_out::type_id::create("alu_subscriber_out_h",this);
        uart_scoreboard_h = UART_scoreboard::type_id::create("uart_scoreboard_h",this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        agent_in_h.aport.connect(alu_subscriber_in_h.analysis_export);
        agent_out_h.aport.connect(alu_subscriber_out_h.analysis_export);

        
        agent_in_h.aport.connect(alu_scoreboard_h.sb_in);
        agent_out_h.aport.connect(alu_scoreboard_h.sb_out);
    endfunction: connect_phase

    function void start_of_simulation_phase(uvm_phase phase);
        //TODO: Use this command to set the verbosity of the testbench. By
        //default, it is UVM_MEDIUM
        uvm_top.set_report_verbosity_level_hier(UVM_LOW);
    endfunction: start_of_simulation_phase

endclass: alu_env
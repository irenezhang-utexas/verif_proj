`include "uvm_macros.svh"
import uart_pkg::*;
class env extends uvm_env;
    `uvm_component_utils(env)

    agent_in agent_in_h;
    agent_out agent_out_h;
    wb2uart_subscriber wb2uart_subscriber_h;
    UART_scoreboard uart_scoreboard_h;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        agent_in_h = agent_in::type_id::create("agent_in_h",this);
        agent_out_h = agent_out::type_id::create("agent_out_h",this);
        wb2uart_subscriber_h = wb2uart_subscriber::type_id::create("wb2uart_subscriber_h",this);
        uart_scoreboard_h = UART_scoreboard::type_id::create("uart_scoreboard_h",this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        agent_in_h.aport.connect(wb2uart_subscriber_h.analysis_export);


        
        agent_in_h.aport.connect(uart_scoreboard_h.sb_in_1);
        agent_out_h.bport.connect(uart_scoreboard_h.sb_out_1);


        agent_in_h.bport.connect(uart_scoreboard_h.sb_in_2);
        agent_out_h.aport.connect(uart_scoreboard_h.sb_out_2);

    endfunction: connect_phase

    function void start_of_simulation_phase(uvm_phase phase);
        //TODO: Use this command to set the verbosity of the testbench. By
        //default, it is UVM_MEDIUM
        uvm_top.set_report_verbosity_level_hier(UVM_LOW);
    endfunction: start_of_simulation_phase

endclass: env
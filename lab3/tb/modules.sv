`include "uvm_macros.svh"
package modules_pkg;

import uvm_pkg::*;
import sequences::*;
import coverage::*;
import scoreboard::*;

typedef uvm_sequencer #(alu_transaction_in) amber25_sequencer_in;

class uart_dut_config extends uvm_object;
    `uvm_object_utils(uart_dut_config)

    virtual uart_in dut_vi_in;
    virtual uart_out dut_vi_out;

endclass: uart_dut_config


class amber_dut_config extends uvm_object;
    `uvm_object_utils(amber_dut_config)

    virtual dut_in dut_vi_in;
    virtual dut_out dut_vi_out;

endclass: amber_dut_config





class alu_env extends uvm_env;
    `uvm_component_utils(alu_env)

    alu_agent_in alu_agent_in_h;
    alu_agent_out alu_agent_out_h;
    alu_subscriber_in alu_subscriber_in_h;
    alu_subscriber_out alu_subscriber_out_h;
    alu_scoreboard alu_scoreboard_h;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        alu_agent_in_h = alu_agent_in::type_id::create("alu_agent_in_h",this);
        alu_agent_out_h = alu_agent_out::type_id::create("alu_agent_out_h",this);
        alu_subscriber_in_h = alu_subscriber_in::type_id::create("alu_subscriber_in_h",this);
        alu_subscriber_out_h = alu_subscriber_out::type_id::create("alu_subscriber_out_h",this);
        alu_scoreboard_h = alu_scoreboard::type_id::create("alu_scoreboard_h",this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        alu_agent_in_h.aport.connect(alu_subscriber_in_h.analysis_export);
        alu_agent_out_h.aport.connect(alu_subscriber_out_h.analysis_export);
        alu_agent_in_h.aport.connect(alu_scoreboard_h.sb_in);
        alu_agent_out_h.aport.connect(alu_scoreboard_h.sb_out);
    endfunction: connect_phase

    function void start_of_simulation_phase(uvm_phase phase);
        //TODO: Use this command to set the verbosity of the testbench. By
        //default, it is UVM_MEDIUM
        uvm_top.set_report_verbosity_level_hier(UVM_LOW);
    endfunction: start_of_simulation_phase

endclass: alu_env

class alu_test extends uvm_test;
    `uvm_component_utils(alu_test)

    amber_dut_config dut_config_0;
    uart_dut_config uart_config_0;
    alu_env alu_env_h;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        dut_config_0 = new();
        uart_config_0 = new();
        if(!uvm_config_db #(virtual dut_in)::get( this, "", "dut_vi_in", dut_config_0.dut_vi_in))
          `uvm_fatal("NOVIF", "No virtual interface set for dut_in")
        
        if(!uvm_config_db #(virtual dut_out)::get( this, "", "dut_vi_out", dut_config_0.dut_vi_out))
          `uvm_fatal("NOVIF", "No virtual interface set for dut_out")
         if(!uvm_config_db #(virtual uart_in)::get( this, "", "uart_vi_in", uart_config_0.uart_vi_in))
          `uvm_fatal("NOVIF", "No virtual interface set for uart_in")
        
        if(!uvm_config_db #(virtual uart_out)::get( this, "", "uart_vi_out", uart_config_0.uart_vi_out))
          `uvm_fatal("NOVIF", "No virtual interface set for uart_out")
            
        uvm_config_db #(amber_dut_config)::set(this, "*", "dut_config", dut_config_0);
        uvm_config_db #(uart_dut_config)::set(this, "*", "uart_config", uart_config_0);
        alu_env_h = alu_env::type_id::create("alu_env_h", this);
    endfunction: build_phase

endclass:alu_test

endpackage: modules_pkg

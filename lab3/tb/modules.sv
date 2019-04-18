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


class amber_driver_in extends uvm_driver#(alu_transaction_in);
    `uvm_component_utils(amber_driver_in)

    amber_dut_config dut_config_0;
    virtual dut_in dut_vi_in;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
       assert( uvm_config_db #(amber_dut_config)::get(this, "", "dut_config", dut_config_0));
       dut_vi_in = dut_config_0.dut_vi_in;
    endfunction : build_phase
   
    task run_phase(uvm_phase phase);
      forever
      begin
        alu_transaction_in tx;
        
        @(posedge dut_vi_in.i_clk);
        seq_item_port.get(tx);
        
        // interface of dut_vi_in
	dut_vi_in.i_wb_adr	= {tx.i_wb_addr_hi,tx.i_wb_addr_lo};
	dut_vi_in.i_wb_we	= tx.i_wb_we;
	dut_vi_in.i_wb_stb	= tx.i_wb_stb;

      end
    endtask: run_phase

endclass: amber_driver_in

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


class alu_monitor_in extends uvm_monitor;
    `uvm_component_utils(alu_monitor_in)

    uvm_analysis_port #(alu_transaction_in) aport;

    amber_dut_config dut_config_0;

    virtual dut_in dut_vi_in;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        dut_config_0=amber_dut_config::type_id::create("config");
        aport=new("aport",this);
        assert( uvm_config_db #(amber_dut_config)::get(this, "", "dut_config", dut_config_0) );
        dut_vi_in=dut_config_0.dut_vi_in;

    endfunction: build_phase

    task run_phase(uvm_phase phase);
    @(posedge dut_vi_in.clk);
      forever
      begin
        alu_transaction_in tx;
        @(posedge dut_vi_in.clk);
        tx = alu_transaction_in::type_id::create("tx");
        // assign them to the transaction "tx"
	tx.i_clk	= dut_vi_in.i_clk;
	tx.i_wb_adr	= dut_vi_in.i_wb_adr;
	tx.i_wb_sel	= dut_vi_in.i_wb_sel;
	tx.i_wb_we	= dut_vi_in.i_wb_we;
	tx.i_wb_dat	= dut_vi_in.i_wb_dat;
	tx.i_wb_cyc	= dut_vi_in.i_wb_cyc;
	tx.i_wb_stb	= dut_vi_in.i_wb_stb;
	tx.i_uart_cts_n	= dut_vi_in.i_uart_cts_n;
	tx.i_uart_rxd	= dut_vi_in.i_uart_rxd;
	
        aport.write(tx);
      end
    endtask: run_phase

endclass: alu_monitor_in


class uart_monitor_out extends uvm_monitor;
    `uvm_component_utils(uart_monitor_out)

    uvm_analysis_port #(alu_transaction_out) aport;

    uart_dut_config uart_config_0;

    virtual uart_out uart_vi_out;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        uart_config_0=uart_dut_config::type_id::create("config");
        aport=new("aport",this);
        assert( uvm_config_db #(uart_dut_config)::get(this, "", "dut_config", uart_config_0) );
        uart_vi_out=uart_config_0.uart_vi_out;

    endfunction: build_phase

    task run_phase(uvm_phase phase);
    @(posedge uart_vi_out.i_uart_clk);
      forever
      begin
        alu_transaction_out tx;
        
        @(posedge uart_vi_out.i_uart_clk);
        tx = alu_transaction_out::type_id::create("tx");
        // TODO: Read the values from the virtual interface of dut_vi_out and
        // assign them to the transaction "tx"
	tx.i_uart_clk	= dut_vi_out.i_uart_clk;
	tx.o_uart_txd	= dut_vi_out.o_uart_txd;
	tx.o_uart_rts_n = dut_vi_out.o_uart_rts_n;

        aport.write(tx);
      end
    endtask: run_phase
endclass: uart_monitor_out


class alu_monitor_out extends uvm_monitor;
    `uvm_component_utils(alu_monitor_out)

    uvm_analysis_port #(alu_transaction_out) aport;

    amber_dut_config dut_config_0;

    virtual dut_out dut_vi_out;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        dut_config_0=amber_dut_config::type_id::create("config");
        aport=new("aport",this);
        assert( uvm_config_db #(amber_dut_config)::get(this, "", "dut_config", dut_config_0) );
        dut_vi_out=dut_config_0.dut_vi_out;

    endfunction: build_phase

    task run_phase(uvm_phase phase);
    @(posedge dut_vi_out.clk);
    @(posedge dut_vi_out.clk);
      forever
      begin
        alu_transaction_out tx;
        
        @(posedge dut_vi_out.clk);
        tx = alu_transaction_out::type_id::create("tx");
        // TODO: Read the values from the virtual interface of dut_vi_out and
        // assign them to the transaction "tx"
	tx.i_clk	= dut_vi_out.i_clk;
	tx.o_wb_dat	= dut_vi_out.o_wb_dat;
	tx.o_wb_ack	= dut_vi_out.o_wb_ack;
	tx.o_wb_err	= dut_vi_out.o_wb_err;

        aport.write(tx);
      end
    endtask: run_phase
endclass: alu_monitor_out

class alu_agent_in extends uvm_agent;
    `uvm_component_utils(alu_agent_in)

    uvm_analysis_port #(alu_transaction_in) aport;

    amber25_sequencer_in amber25_sequencer_in_h;
    amber_driver_in amber_driver_in_h;
    uart_driver_in uart_driver_in_h;
    alu_monitor_in alu_monitor_in_h;
    uart_monitor_in uart_monitor_in_h;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new


    function void build_phase(uvm_phase phase);
        aport=new("aport",this);
        amber25_sequencer_in_h=amber25_sequencer_in::type_id::create("amber25_sequencer_in_h",this);
        amber_driver_in_h=amber_driver_in::type_id::create("amber_driver_in_h",this);
        uart_driver_in_h=amber_driver_in::type_id::create("uart_driver_in_h",this);
        alu_monitor_in_h=alu_monitor_in::type_id::create("alu_monitor_in_h",this);
        uart_monitor_in_h=uart_monitor_in::type_id::create("alu_monitor_in_h",this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        amber_driver_in_h.seq_item_port.connect(amber25_sequencer_in_h.seq_item_export);
        uart_driver_in_h.seq_item_port.connect(amber25_sequencer_in_h.seq_item_export);
        alu_monitor_in_h.aport.connect(aport);
        uart_monitor_in_h.aport.connect(aport);
    endfunction: connect_phase

endclass: alu_agent_in

class alu_agent_out extends uvm_agent;
    `uvm_component_utils(alu_agent_out)

    uvm_analysis_port #(alu_transaction_out) aport;

    alu_monitor_out alu_monitor_out_h;
    uart_monitor_out uart_monitor_out_h;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        aport=new("aport",this);
        alu_monitor_out_h=alu_monitor_out::type_id::create("alu_monitor_out_h",this);
        uart_monitor_out_h=uart_monitor_out::type_id::create("uart_monitor_out_h",this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        alu_monitor_out_h.aport.connect(aport);
        uart_monitor_out_h.aport.connect(aport);
    endfunction: connect_phase

endclass: alu_agent_out


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

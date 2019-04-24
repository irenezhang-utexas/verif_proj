`include "uvm_macros.svh"
import uart_pkg::*;

class agent_out extends uvm_agent;
    `uvm_component_utils(agent_out)

    uvm_analysis_port #(uart2wb) aport;
    uvm_analysis_port #(uart_tx_frame) bport;

    uart2wb_monitor uart2wb_monitor_h;
    uart_monitor_out uart_monitor_out_h;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        aport=new("aport",this);
        bport=new("bport",this);
        uart2wb_monitor_h=uart2wb_monitor::type_id::create("uart2wb_monitor_h",this);
        uart_monitor_out_h=uart_monitor_out::type_id::create("uart_monitor_out_h",this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        uart_monitor_out_h.aport.connect(aport); 
        uart2wb_monitor_h.aport.connect(bport);
         
    endfunction: connect_phase

endclass: agent_out

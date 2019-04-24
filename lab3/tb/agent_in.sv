`include "uvm_macros.svh"
import uart_pkg::*;
class agent_in extends uvm_agent;
    `uvm_component_utils(agent_in)

    uvm_analysis_port #(wb2uart) aport;
    uvm_analysis_port #(uart_rx_frame) bport;

    tx_seq wb2uart_sequencer_in_h;
    rx_seq rx_frame_sequencer_in_h;

    wb2uart_driver wb2uart_driver_h;
    wb2uart_monitor wb2uart_monitor_h;

    uart_driver_in uart_driver_in_h;
    uart_monitor_in uart_monitor_in_h;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        aport=new("aport",this);
        bport=new("aport",this);

        wb2uart_sequencer_in_h=tx_seq::type_id::create("wb2uart_sequencer_in_h",this);
        rx_frame_sequencer_in_h=rx_seq::type_id::create("rx_frame_sequencer_in_h",this);

        wb2uart_driver_h=wb2uart_driver::type_id::create("wb2uart_driver_h",this);
        wb2uart_monitor_h=wb2uart_monitor::type_id::create("wb2uart_monitor_in_h",this);

        uart_driver_in_h=uart_driver_in::type_id::create("uart_driver_in_h",this);
        uart_monitor_in_h=uart_monitor_in::type_id::create("uart_monitor_in_h",this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        wb2uart_driver_h.seq_item_port.connect(wb2uart_sequencer_in_h.seq_item_export);
        uart_driver_in_h.seq_item_port.connect(rx_frame_sequencer_in_h.seq_item_export);
        wb2uart_monitor_h.aport.connect(aport);
        uart_monitor_in_h.aport.connect(bport);
    endfunction: connect_phase

endclass: agent_in



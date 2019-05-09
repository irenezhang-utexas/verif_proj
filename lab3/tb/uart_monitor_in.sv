`include "uvm_macros.svh"
import uart_pkg::*;
class uart_monitor_in extends uvm_monitor;
    `uvm_component_utils(uart_monitor_in)

    uvm_analysis_port #(uart_rx_frame) aport;


    uart_dut_config dut_config_0;

    virtual uart_in uart_vi_in;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        dut_config_0=uart_dut_config::type_id::create("config");

        aport=new("aport",this);

        assert( uvm_config_db #(uart_dut_config)::get(this, "", "uart_dut_config", dut_config_0) );

        uart_vi_in=dut_config_0.uart_vi_in;

    endfunction: build_phase


    task run_phase(uvm_phase phase);
        uart_rx_frame frame;
        frame = uart_rx_frame::type_id::create("frame");


    //@(posedge uart_vi_in.i_uart_clk);
    @(posedge $root.top.dut1.uart_dut.i_clk)
      forever
      begin

        int monitor_counter = 0;
          //`uvm_info("uart_monitor", "\n--------------------------uart_monitor------------------------------\n", UVM_LOW);
        //driver start sampling the frame from outside
       wait(!uart_vi_in.o_uart_rts_n && !uart_vi_in.i_uart_rxd);
        repeat(1) @(posedge uart_vi_in.i_uart_clk);     
        while(monitor_counter < 9) begin
            @(posedge uart_vi_in.i_uart_clk)
                if ((monitor_counter >= 0) && (monitor_counter < 8)) begin
                   
                    frame.payload[monitor_counter] = uart_vi_in.i_uart_rxd;
                end
                //sening stop
                //`uvm_info("monitor_uart_data", $sformatf("monitor counter %d bit = %b",monitor_counter,uart_vi_in.i_uart_rxd), UVM_LOW);
                monitor_counter++;
        end
        //`uvm_info("uart_monitor_frame", $sformatf("%b",frame.payload), UVM_LOW);
        aport.write(frame);
      end
    endtask: run_phase

endclass: uart_monitor_in


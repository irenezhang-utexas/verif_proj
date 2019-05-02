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


    @(posedge uart_vi_in.i_uart_clk);
      forever
      begin

        int monitor_counter = 0;

        //driver start sampling the frame from outside
        wait(!uart_vi_in.o_uart_rts_n);
        `uvm_info("uart_monitor", "\n--------------------------uart_monitor------------------------------\n", UVM_LOW);
        while(monitor_counter < 10) begin
            @(posedge uart_vi_in.i_uart_clk)
                //sending start bity
                if(monitor_counter == 0)begin
                    frame.start_bit= uart_vi_in.i_uart_rxd;
                end
                //sending data
                if ((monitor_counter > 0) && (monitor_counter < 9)) begin
                    wait(uart_vi_in.o_uart_rts_n);
                    frame.payload[monitor_counter-1] = uart_vi_in.i_uart_rxd;
                end
                //sening stop
                if (monitor_counter == 9) begin
                    frame.stop_bits = uart_vi_in.i_uart_rxd;
                end
                monitor_counter++;
        end

        aport.write(frame);
      end
    endtask: run_phase

endclass: uart_monitor_in


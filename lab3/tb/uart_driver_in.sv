`include "uvm_macros.svh"
import uart_pkg::*;
//Get a Uart frame and transfer it it to serialized data
class uart_driver_in extends uvm_driver#(uart_rx_frame);



    `uvm_component_utils(uart_driver_in)

    uart_dut_config dut_config_0;
    virtual uart_in uart_vi_in;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
       assert( uvm_config_db #(uart_dut_config)::get(this, "", "uart_dut_config", dut_config_0));
       uart_vi_in = dut_config_0.dut_vi_in;
    endfunction : build_phase
   


    task run_phase(uvm_phase phase);
            fork
            get_and_drive();
            join
    endtask : run_phase

    task get_and_drive();
        while (1) begin
                fork
                begin
                    forever begin
                        @(posedge uart_vi_in.i_uart_clk)//this must be synconized with sampler in monitor
                        if(!uart_vi_in.o_uart_rts_n) begin
                            seq_item_port.get_next_item(req);
                            sent_uart_frame(req);
                            seq_item_port.item_done();
                        end
                            
                    end
                end
                join_any
                disable fork;
        end
    endtask : get_and_drive

    task sent_uart_frame(input uart_rx_frame req);
        int bit_counter = 0;

        //wait untial o_uart_rts_o is low
       //

        while(bit_counter < 10) begin
            @(posedge uart_vi_in.i_uart_clk)
                //sending start bity
                if(bit_counter == 0)begin
                    uart_vi_in.i_uart_rxd = req.start_bit;
                end
                //sending data
                if ((bit_counter > 0) && (bit_counter < 9)) begin
                    wait(uart_vi_in.o_uart_rts_n);
                    uart_vi_in.i_uart_rxd = req.payload[bit_counter-1];
                end
                //sening stop
                if (bit_counter == 9) begin
                    uart_vi_in.i_uart_rxd = req.stop_bits;
                end
                bit_counter++;
        end
    endtask : sent_uart_frame


endclass: uart_driver_in

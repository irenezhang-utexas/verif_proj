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
       uart_vi_in = dut_config_0.uart_vi_in;
    endfunction : build_phase
   


    task run_phase(uvm_phase phase);
            //fork
            get_and_drive();
            //join
    endtask : run_phase

    task get_and_drive();
        while (1) begin
                //fork
                begin
                    forever begin
                        uart_vi_in.i_uart_rxd = 1;
                        //@(posedge uart_vi_in.i_uart_clk)//this must be synconized with sampler in monitor
                        @(posedge $root.top.dut1.uart_dut.i_clk)
                        if(!uart_vi_in.o_uart_rts_n) begin
                            seq_item_port.get_next_item(req);
                            sent_uart_frame(req);
                            seq_item_port.item_done();
                        end
                            
                    end
                end
                //join_any
                //disable fork;
        end
    endtask : get_and_drive

    task sent_uart_frame(input uart_rx_frame req);
        int bit_counter = 0;
        //`uvm_info("rx_fifo_value =", $sformatf("%b",$root.top.dut1.uart_dut.rx_fifo[$root.top.dut1.uart_dut.rx_fifo_wp[4:0]]), UVM_LOW);

        //wait untial o_uart_rts_o is low
        //`uvm_info("sent_uart_frame test", "\n", UVM_LOW);
        wait(!uart_vi_in.o_uart_rts_n)
        uart_vi_in.i_uart_rxd = req.start_bit;

        while(bit_counter < 10) begin
            @(negedge uart_vi_in.i_uart_clk)
            //`uvm_info("rxd_state =", $sformatf("%d",$root.top.dut1.uart_dut.rxd_state), UVM_LOW);
                //sending data
                if ((bit_counter >= 0) && (bit_counter < 8)) begin
                    uart_vi_in.i_uart_rxd = req.payload[bit_counter];
                    //`uvm_info("sent_uart_frame", $sformatf("rx_bit counter %d bit = %b",bit_counter,req.payload[bit_counter]), UVM_LOW);
                    //`uvm_info("rx_byte =", $sformatf("%b",$root.top.dut1.uart_dut.rx_byte), UVM_LOW);
                end else begin
                    uart_vi_in.i_uart_rxd = req.stop_bits;
                    //`uvm_info("sent_uart_frame", $sformatf("rx_bit counter %d stop = %b",bit_counter,req.stop_bits), UVM_LOW);
               
                end
                
                bit_counter++;
                //uvm_info("driver_bit", $sformatf("driver %d",bit_counter), UVM_LOW);
        end
        //`uvm_info("uart_driver_frame =", $sformatf("%b",req.payload), UVM_LOW);
        //`uvm_info("rx_byte =", $sformatf("%b",$root.top.dut1.uart_dut.rx_byte), UVM_LOW);
        //`uvm_info("i_wb_we", $sformatf("%b",$root.top.dut1.uart_dut.i_wb_we), UVM_LOW);
    endtask : sent_uart_frame


endclass: uart_driver_in

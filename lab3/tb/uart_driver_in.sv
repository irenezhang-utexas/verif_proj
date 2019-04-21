
//Get a Uart frame and transfer it it to serialized data
class uart_driver_in extends uvm_driver#(uart_rx_frame);



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
   


    task uart_driver_in::run_phase(uvm_phase phase);
        fork
            get_and_drive();
        join
    endtask : run_phase

    task uart_driver_in::get_and_drive();
        while (1) begin
            fork
                begin
                    forever begin
                        //@(posedge uart_vi_in.i_uart_clk)//this must be synconized with sampler in monitor
                        if(！uart_vi_in.o_uart_rts_n)) begin
                            seq_item_port.get_next_item(req);
                            send_uart_frame(req);
                            seq_item_port.item_done();
                        end
                            
                    end
                end
            join_any
            disable fork;
        end
    endtask : get_and_drive

    task uart_driver_in::sent_uart_frame();
        int bit_counter = 0;

        //wait untial o_uart_rts_o is low
       //

        while(bit_counter < 10) begin
            @(posedge uart_vi_in.i_uart_clk)
                //sending start bity
                if(bit_counter == 0)begin
                    uart_vi_in.i_uart_rxd = uart_vi_in.start_bit;
                end
                //sending data
                if ((num_of_bits_sent > 0) && (num_of_bits_sent < 9)) begin
                    wait(uart_vi_in.o_uart_rts_n);
                    uart_vi_in.i_uart_rxd = uart_vi_in.payload[bit_counter-1];
                end
                //sening stop
                if ((num_of_bits_sent == 9) begin
                    uart_vi_in.i_uart_rxd = uart_vi_in.stop_bits[0];
                end
                bit_counter++;
        end
    endtask : sent_uart_frame


endclass: uart_driver_in

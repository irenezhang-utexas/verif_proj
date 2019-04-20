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

        assert( uvm_config_db #(uart_dut_config)::get(this, "", "dut_config", dut_config_0) );
        uart_vi_in=dut_config_0.uart_vi_in;

    endfunction: build_phase


    task run_phase(uvm_phase phase);
    @(posedge uart_vi_in.i_uart_clk);
      forever
      begin
        uart_rx_frame frame;
        frame = uart_rx_frame::type_id::create("frame");

        int monitor_counter = 0;

        //driver start sampling the frame from outside
        wait(!uart_vi_in.o_uart_rts_n);

        while(monitor_counter < 10) begin
            @(posedge uart_vi_in.i_uart_clk)
                //sending start bity
                if(monitor_counter == 0)begin
                    frame.start_bit= uart_vi_in.i_uart_rxd;
                end
                //sending data
                if ((num_of_bits_sent > 0) && (num_of_bits_sent < 9)) begin
                    wait(uart_vi_in.o_uart_rts_n);
                    frame.payload[monitor_counter-1] = uart_vi_in.i_uart_rxd;
                end
                //sening stop
                if ((num_of_bits_sent == 9) begin
                    frame.stop_bits = uart_vi_in.i_uart_rxd;
                end
                monitor_counter++;
        end

        aport.write(frame);
      end
    endtask: run_phase

endclass: uart_monitor_in
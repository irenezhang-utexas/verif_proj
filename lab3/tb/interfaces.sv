interface dut_in;
    logic           	i_clk;

    logic   [31:0]	i_wb_adr;
    logic   [3:0]   	i_wb_sel;
    logic		i_wb_we;
    logic   [31:0]  	i_wb_dat;
    logic		i_wb_cyc;
    logic		i_wb_stb;

endinterface: dut_in


interface dut_out;
    logic	 	i_clk;
    logic [31:0] 	o_wb_dat;
    logic	 	o_wb_ack;
    logic		o_wb_err;

endinterface: dut_out

interface uart_in;
    logic		i_uart_clk;
    logic		i_uart_cts_n;
    logic		i_uart_rxd;
endinterface: uart_in

interface uart_out;
    logic		i_uart_clk;
    logic		o_uart_txd;
    logic		o_uart_rts_n;
endinterface: uart_out


`timescale 1ns / 100ps
`include "uvm_macros.svh"
import uart_pkg::*;
import uvm_pkg::*;

module dut(dut_in _in, dut_out _out, uart_in _uart_in, uart_out _uart_out);
uart uart_dut(
	.i_clk		(_in.i_clk),

	.i_wb_adr	(_in.i_wb_adr),		// w/r addr
	//.i_wb_sel	(_in.i_wb_sel),		// not used
	.i_wb_we	(_in.i_wb_we),		// write enable
	.o_wb_dat	(_out.o_wb_dat),	// read data
	.i_wb_dat	(_in.i_wb_dat),		// write data
	//.i_wb_cyc	(_in.i_wb_cyc),		// not used
	.i_wb_stb	(_in.i_wb_stb),		// wb pre-cyle strobe
	.o_wb_ack	(_out.o_wb_ack), 	// uart ack to wb
	.o_wb_err	(_out.o_wb_err),	// == 1'b0

	.i_uart_cts_n	(_uart_in.i_uart_cts_n), 	// tx
	.o_uart_txd	(_uart_out.o_uart_txd), 	// tx serial send
	.o_uart_rts_n	(_uart_in.o_uart_rts_n), 	// for rx, ack wb to pop fifo
	.i_uart_rxd	(_uart_in.i_uart_rxd) 	// rx serial receive

);
endmodule: dut

module top;    
`define AMBER_UART_BAUD 230400
`define AMBER_CLK_DIVIDER 20
`ifndef Veritak
localparam integer UART_BAUD         = `AMBER_UART_BAUD;            // Hz

localparam integer CLK_FREQ          = 800.0 / `AMBER_CLK_DIVIDER ; // MHz

localparam integer UART_BIT_PERIOD   = 1000000000 / UART_BAUD;      // nS
localparam integer UART_BIT_PERIOD_HALF   = UART_BIT_PERIOD / 2;      // nS
localparam integer UART_WORD_PERIOD  = ( UART_BIT_PERIOD * 12 );    // nS
localparam integer CLK_PERIOD        = 1000 / CLK_FREQ;             // nS
localparam integer CLK_PERIOD_HALF   = CLK_PERIOD / 2;

localparam integer CLKS_PER_WORD     = UART_WORD_PERIOD / CLK_PERIOD;
localparam integer CLKS_PER_BIT      = CLKS_PER_WORD / 12;

// These are rounded to the nearest whole number
// i.e. 29.485960 -> 29
//      29.566303 -> 30    
localparam [9:0] TX_BITPULSE_COUNT         = CLKS_PER_BIT;
localparam [9:0] TX_CLKS_PER_WORD          = CLKS_PER_WORD;
`endif

localparam [9:0] TX_BITADJUST_COUNT        = TX_CLKS_PER_WORD - 11*TX_BITPULSE_COUNT;

localparam [9:0] RX_BITPULSE_COUNT         = TX_BITPULSE_COUNT-2;
localparam [9:0] RX_HALFPULSE_COUNT        = TX_BITPULSE_COUNT/2 - 4;

dut_in dut_in1();
dut_out dut_out1();
uart_in uart_in1();
uart_out uart_out1();

initial begin
    dut_in1.i_clk<=0;
    forever #CLK_PERIOD_HALF dut_in1.i_clk<=~dut_in1.i_clk;
end

initial begin
    dut_out1.i_clk<=0;
    forever #CLK_PERIOD_HALF dut_out1.i_clk<=~dut_out1.i_clk;
end

initial begin
    uart_in1.i_uart_clk<=0;
    forever #UART_BIT_PERIOD_HALF uart_in1.i_uart_clk<=~uart_in1.i_uart_clk;
end

initial begin
    uart_out1.i_uart_clk<=0;
    forever #UART_BIT_PERIOD_HALF uart_out1.i_uart_clk<=~uart_in1.i_uart_clk;
end


dut dut1(dut_in1,dut_out1,uart_in1,uart_out1);

initial begin
    // TODO: what does the following do
    uvm_config_db #(virtual dut_in)::set(null,"uvm_test_top","dut_vi_in",dut_in1);
    uvm_config_db #(virtual dut_out)::set(null,"uvm_test_top","dut_vi_out",dut_out1);
    uvm_config_db #(virtual uart_in)::set(null,"uvm_test_top","dut_vi_in",uart_in1);
    uvm_config_db #(virtual uart_out)::set(null,"uvm_test_top","dut_vi_out",uart_out1);
    // calls $finish after all phases finish
    uvm_top.finish_on_completion=1;

    //fork
    run_test("test1");
    //run_test("test2");
	//join_any
end

endmodule: top

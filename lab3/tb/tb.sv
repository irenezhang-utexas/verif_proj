`timescale 1ns / 100ps
`include "uvm_macros.svh"
import uvm_pkg::*;
import modules_pkg::*;
import sequences::*;
import coverage::*;
import scoreboard::*;
import tests::*;

module dut(dut_in _in, dut_out _out);
uart uart_dut(
	.i_clk		(_in.i_clk),

	.i_wb_adr	(_in.i_wb_adr),
	.i_wb_sel	(_in.i_wb_sel),
	.i_wb_we	(_in.i_wb_we),
	.o_wb_dat	(_out.o_wb_dat),
	.i_wb_dat	(_in.i_wb_dat),
	.i_wb_cyc	(_in.i_wb_cyc),
	.i_wb_stb	(_in.i_wb_stb),
	.o_wb_ack	(_out.o_wb_ack),
	.o_wb_err	(_out.o_wb_err),

	.i_uart_cts_n	(_in.i_uart_cts_n),
	.o_uart_txd	(_out.o_uart_txd),
	.o_uart_rts_n	(_out.o_uart_rts_n),
	.i_uart_rxd	(_in.i_uart_rxd)

);
endmodule: dut

module top;    
dut_in dut_in1();
dut_out dut_out1();

initial begin
    dut_in1.clk<=0;
    forever #50 dut_in1.clk<=~dut_in1.clk;
end

initial begin
    dut_out1.clk<=0;
    forever #50 dut_out1.clk<=~dut_out1.clk;
end


dut dut1(dut_in1,dut_out1);

initial begin
    // TODO: what does the following do
    uvm_config_db #(virtual dut_in)::set(null,"uvm_test_top","dut_vi_in",dut_in1);
    uvm_config_db #(virtual dut_out)::set(null,"uvm_test_top","dut_vi_out",dut_out1);
    // calls $finish after all phases finish
    uvm_top.finish_on_completion=1;

    run_test("rst_test");
end

endmodule: top

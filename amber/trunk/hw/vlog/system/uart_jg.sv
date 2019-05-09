
`include "system_config_defines.vh"
`include "register_addresses.vh"
//`define AMBER_UART_BAUD 230400

parameter WB_DWIDTH = 32;
parameter WB_SWIDTH = 4;

module uart_jg  (
input                       i_clk,

input       [31:0]          i_wb_adr,
input       [WB_SWIDTH-1:0] i_wb_sel,
input                       i_wb_we,
input      [WB_DWIDTH-1:0] o_wb_dat,
input       [WB_DWIDTH-1:0] i_wb_dat,
input                       i_wb_cyc,
input                       i_wb_stb,
input                      o_wb_ack,
input                      o_wb_err,

input                      o_uart_int,

input                       i_uart_cts_n,   // Clear To Send
input                      o_uart_txd,     // Transmit data
input                      o_uart_rts_n,   // Request to Send
input                       i_uart_rxd      // Receive data

);

`include "register_addresses.vh"


localparam [3:0] TXD_IDLE  = 4'd0,
                 TXD_START = 4'd1,
                 TXD_DATA0 = 4'd2,
                 TXD_DATA1 = 4'd3,
                 TXD_DATA2 = 4'd4,
                 TXD_DATA3 = 4'd5,
                 TXD_DATA4 = 4'd6,
                 TXD_DATA5 = 4'd7,
                 TXD_DATA6 = 4'd8,
                 TXD_DATA7 = 4'd9,
                 TXD_STOP1 = 4'd10,
                 TXD_STOP2 = 4'd11,
                 TXD_STOP3 = 4'd12;
                 
localparam [3:0] RXD_IDLE       = 4'd0,
                 RXD_START      = 4'd1,
                 RXD_START_MID  = 4'd2,
                 RXD_START_MID1 = 4'd3,
                 RXD_DATA0      = 4'd4,
                 RXD_DATA1      = 4'd5,
                 RXD_DATA2      = 4'd6,
                 RXD_DATA3      = 4'd7,
                 RXD_DATA4      = 4'd8,
                 RXD_DATA5      = 4'd9,
                 RXD_DATA6      = 4'd10,
                 RXD_DATA7      = 4'd11,
                 RXD_STOP       = 4'd12;


localparam RX_INTERRUPT_COUNT = 24'h3fffff; 


generate
if (WB_DWIDTH == 128) 
    begin : wb128
    assign wb_wdata32   = i_wb_adr[3:2] == 2'd3 ? i_wb_dat[127:96] :
                          i_wb_adr[3:2] == 2'd2 ? i_wb_dat[ 95:64] :
                          i_wb_adr[3:2] == 2'd1 ? i_wb_dat[ 63:32] :
                                                  i_wb_dat[ 31: 0] ;
                                                                                                                                            
    assign o_wb_dat    = {4{uart.wb_rdata32}};
    end
else
    begin : wb32
    assign wb_wdata32  = i_wb_dat;
    assign o_wb_dat    = uart.wb_rdata32;
    end
endgenerate



// 1.ASSUMPTIONS
NO_INTERRUPT: assume property (@(posedge i_clk) (i_wb_adr[15:0] == AMBER_UART_CR) |=> (uart.wb_wdata32[7:0] == 0) );
// 2. ASSERTIONS

// 2.1 tx FIFO

// 2.1.1 check tx_state sequence
TX_STATE0: assert property(@(posedge i_clk) (uart.txd_state == TXD_IDLE) |=> (uart.txd_state == TXD_IDLE) || (uart.txd_state == TXD_START)); // what about if statement ????

TX_STATE1to11: assert property(@(posedge i_clk) (uart.txd_state > TXD_IDLE) && (uart.txd_state < TXD_STOP3) |=> (uart.txd_state == $past(uart.txd_state,1))|| (uart.txd_state == ($past(uart.txd_state,1) + 4'd1)));

TX_STATE_12: assert property(@(posedge i_clk) (uart.txd_state == TXD_STOP3) |=> ((uart.txd_state == TXD_STOP3) || (uart.txd_state == TXD_IDLE)));

// 2.1.2 check tx_state range
TX_STATE_RANGE: assert property(@(posedge i_clk) uart.txd_state <= 4'd12 ); // ???????????

// 2.1.3 TODO: check tx_state no deadlock

// 2.1.4 FIFO no change when full
TX_FIFO_FULL: assert property (@(posedge i_clk) (uart.tx_fifo_full && uart.fifo_enable |=> (uart.tx_fifo_wp == $past(uart.tx_fifo_wp,1))));

// 2.2 rx FIFO
// 2.2.1 check rx_state sequence
RX_STATE0: assert property(@(posedge i_clk) (uart.rxd_state == RXD_IDLE) |=> (uart.rxd_state == RXD_IDLE) || (uart.rxd_state == RXD_START));

RX_STATE1to11: assert property(@(posedge i_clk) ((uart.rxd_state > RXD_IDLE) && (uart.rxd_state < RXD_STOP)) |=> ((uart.rxd_state == $past(uart.rxd_state,1))|| (uart.rxd_state == ($past(uart.rxd_state,1) + 4'd1)))); // ???????????????

RX_STATE_12: assert property(@(posedge i_clk) (uart.rxd_state == RXD_STOP) |=> (uart.rxd_state == RXD_STOP) || (uart.rxd_state == RXD_IDLE));

// 2.2.2 check rx_state range
RX_STATE_RANGE: assert property(@(posedge i_clk) uart.rxd_state <= 4'd12 ); // ???????????????

// 2.2.3 TODO: check rx_state no deadlock

// 2.2.4 FIFO no change when full
RX_FIFO_FULL1: assert property (@(posedge i_clk)  ((uart.rxd_state == RXD_IDLE) && (uart.rx_fifo_full)) |=> ~uart.rxen);
RX_FIFO_FULL2: assert property (@(posedge i_clk)  ((uart.rxd_state == RXD_IDLE) && ~(uart.rx_fifo_full)) |=> uart.rxen);
// TODO: wr ptr not change when full

// 2.2.4.1 TODO: rx fifo state == IDLE


// 2.2.5.1 rx_full & rx_empty

// 2.2.5.1.1 rx_full and rx_empty not asserted at the same time
RX_FULL_EMPTY: assert property(@(posedge i_clk)  ~(uart.rx_fifo_empty && uart.rx_fifo_full)); 

// 2.2.5.1.2 rise rx_full only on push
RX_FULL_ROSE_ON_PUSH: assert property (@(posedge i_clk) ~uart.rx_fifo_full ##1 uart.rx_fifo_full |=> ($past(uart.rx_fifo_push,2) || $past(uart.fifo_enable,2))); 

// 2.2.5.1.3 fell rx_full only on pop
RX_FULL_FELL_ON_POP: assert property (@(posedge i_clk) uart.rx_fifo_full ##1 ~uart.rx_fifo_full |=> $past(uart.rx_fifo_pop,2) || $past(uart.fifo_enable,2)); 


// 2.2.5.1.4 rose rx_empty only on pop
RX_EMPTY_ROSE_ON_POP: assert property (@(posedge i_clk) ~uart.rx_fifo_empty ##1 uart.rx_fifo_empty |=> $past(uart.rx_fifo_pop,2) || $past(uart.fifo_enable,2)); 

// 2.2.5.1.5 fell rx_empty only on push
RX_EMPTY_FELL_ON_PUSH: assert property (@(posedge i_clk) uart.rx_fifo_empty ##1 ~uart.rx_fifo_empty |=> $past(uart.rx_fifo_push,2) || $past(uart.fifo_enable,2));

// 2.2.5.2 tx_full & rx_empty

// 2.2.5.2.1 tx_full and tx_empty not asserted at the same time
TX_FULL_EMPTY: assert property(@(posedge i_clk) ~(uart.tx_fifo_empty && uart.tx_fifo_full)); // reset

// 2.2.5.1.2 rise rx_full only on push
TX_FULL_ROSE_ON_PUSH: assert property (@(posedge i_clk) ~uart.tx_fifo_full ##1 uart.tx_fifo_full |=> $past(uart.tx_fifo_push,2) || $past(uart.fifo_enable,2));

// 2.2.5.1.3 fell rx_full only on pop
TX_FULL_FELL_ON_POP: assert property (@(posedge i_clk) uart.tx_fifo_full ##1 ~uart.tx_fifo_full |=> $past(uart.tx_fifo_pop_not_empty ,2) || $past(uart.fifo_enable,2) || $past(uart.fifo_enable,1));

// 2.2.5.1.4 rose rx_empty only on pop
TX_EMPTY_ROSE_ON_POP: assert property (@(posedge i_clk) ~uart.tx_fifo_empty ##1 uart.tx_fifo_empty |=> $past(uart.tx_fifo_pop_not_empty,2) || $past(uart.fifo_enable,2) || $past(uart.fifo_enable,1));

// 2.2.5.1.5 fell rx_empty only on push
TX_EMPTY_FELL_ON_PUSH: assert property (@(posedge i_clk) uart.tx_fifo_empty ##1 ~uart.tx_fifo_empty |=> $past(uart.tx_fifo_push,2) || $past(uart.fifo_enable,2)); 

// 2.3 pointers

// 2.3.1 check tx_fifo_wp
// 2.3.1.1 pointer change < 2
TX_RPTR_CHANGE: assert property ( @(posedge i_clk) uart.tx_fifo_rp |=> ((uart.tx_fifo_rp - $past(uart.tx_fifo_rp,1)) < 2) || ($past(uart.tx_fifo_rp,1) == 5'h1f) || ~$past(uart.fifo_enable,1)); 
TX_WPTR_CHANGE: assert property ( @(posedge i_clk) uart.tx_fifo_wp |=> ((uart.tx_fifo_wp - $past(uart.tx_fifo_wp,1)) < 2) || ~$past(uart.fifo_enable,1)); 

// 2.3.2 check rx_fifo_wp
// 2.3.2.1 pointer change < 2
RX_RPTR_CHANGE: assert property ( @(posedge i_clk) uart.rx_fifo_rp |=> ((uart.rx_fifo_rp - $past(uart.rx_fifo_rp,1)) < 2) || ($past(uart.rx_fifo_rp,1) == 5'h1f) || ~$past(uart.fifo_enable,1)); 
RX_WPTR_CHANGE: assert property ( @(posedge i_clk) uart.rx_fifo_wp |=> ((uart.rx_fifo_wp - $past(uart.rx_fifo_wp,1)) < 2) || ~$past(uart.fifo_enable,1)); 


// 2.4.5 check fifo not enabled
// 2.4.5.1 wr ptrs no change
FIFO_DIS_WR_PTR0: assert property ( @(posedge i_clk) !uart.fifo_enable |=> uart.tx_fifo_wp == 0);
FIFO_DIS_WR_PTR1: assert property ( @(posedge i_clk) !uart.fifo_enable |=> uart.tx_fifo_rp == 0);
FIFO_DIS_WR_CNT: assert property ( @(posedge i_clk) !uart.fifo_enable |=> uart.tx_fifo_count == 0);

// 2.4 data correctness

// 2.4.1 check write data
sequence wr_data_check(REG_ADR);
uart.wb_start_write && (i_wb_adr[15:0] == REG_ADR);
endsequence

AMBER_UART_RSR_WR: assert property (@(posedge i_clk) wr_data_check(AMBER_UART_RSR) |=> uart.uart_rsr_reg[7:0] == $past(uart.wb_wdata32[7:0],1));
AMBER_UART_LCRH_WR: assert property (@(posedge i_clk) wr_data_check(AMBER_UART_LCRH) |=> uart.uart_lcrh_reg[7:0] == $past(uart.wb_wdata32[7:0],1));
AMBER_UART_LCRM_WR: assert property (@(posedge i_clk) wr_data_check(AMBER_UART_LCRM) |=> uart.uart_lcrm_reg[7:0] == $past(uart.wb_wdata32[7:0],1));
AMBER_UART_LCRL_WR: assert property (@(posedge i_clk) wr_data_check(AMBER_UART_LCRL) |=> uart.uart_lcrl_reg[7:0] == $past(uart.wb_wdata32[7:0],1));
AMBER_UART_CR_WR: assert property (@(posedge i_clk) wr_data_check(AMBER_UART_CR) |=> uart.uart_cr_reg[7:0] == $past(uart.wb_wdata32[7:0],1));
TX_FIFO_WR0: assert property (@(posedge i_clk) uart.tx_fifo_push_not_full && uart.fifo_enable |=> uart.tx_fifo[$past(uart.tx_fifo_wp[3:0],1)] == $past(uart.wb_wdata32[7:0],1));
TX_FIFO_WR1: assert property (@(posedge i_clk) uart.tx_fifo_push_not_full && ~(uart.fifo_enable) |=> uart.tx_fifo[0] == $past(uart.wb_wdata32[7:0],1));



// 2.4.2 check read data
AMBER_UART_CID0_RD: assert property (@(posedge i_clk)uart.wb_start_read && (i_wb_adr[15:0] == AMBER_UART_CID0) |=> (o_wb_dat == 32'h0d));
AMBER_UART_CID1_RD: assert property (@(posedge i_clk)uart.wb_start_read && (i_wb_adr[15:0] == AMBER_UART_CID1) |=> (o_wb_dat == 32'hf0));
AMBER_UART_CID2_RD: assert property (@(posedge i_clk)uart.wb_start_read && (i_wb_adr[15:0] == AMBER_UART_CID2) |=> (o_wb_dat == 32'h05));
AMBER_UART_CID3_RD: assert property (@(posedge i_clk)uart.wb_start_read && (i_wb_adr[15:0] == AMBER_UART_CID3) |=> (o_wb_dat == 32'hb1));

AMBER_UART_PID0_RD: assert property (@(posedge i_clk)uart.wb_start_read && (i_wb_adr[15:0] == AMBER_UART_PID0) |=> (o_wb_dat == 32'h10));
AMBER_UART_PID1_RD: assert property (@(posedge i_clk)uart.wb_start_read && (i_wb_adr[15:0] == AMBER_UART_PID1) |=> (o_wb_dat == 32'h10));
AMBER_UART_PID2_RD: assert property (@(posedge i_clk)uart.wb_start_read && (i_wb_adr[15:0] == AMBER_UART_PID2) |=> (o_wb_dat == 32'h04));
AMBER_UART_PID3_RD: assert property (@(posedge i_clk)uart.wb_start_read && (i_wb_adr[15:0] == AMBER_UART_PID3) |=> (o_wb_dat == 32'h00));


AMBER_UART_DR_RD0: assert property (@(posedge i_clk)uart.wb_start_read && (i_wb_adr[15:0] == AMBER_UART_DR) && uart.fifo_enable |=> (uart.o_wb_dat == {24'h0,$past(uart.rx_fifo[uart.rx_fifo_rp[3:0]],1)}));
AMBER_UART_DR_RD1: assert property (@(posedge i_clk)uart.wb_start_read && (i_wb_adr[15:0] == AMBER_UART_DR) && ~uart.fifo_enable |=> (uart.o_wb_dat == {24'h0,$past(uart.rx_fifo[0],1)}));

AMBER_UART_RSR_RD: assert property (@(posedge i_clk)uart.wb_start_read && (i_wb_adr[15:0] == AMBER_UART_RSR) |=> (o_wb_dat == {24'h0, uart.uart_rsr_reg}));
AMBER_UART_LCRH_RD: assert property (@(posedge i_clk)uart.wb_start_read && (i_wb_adr[15:0] == AMBER_UART_LCRH) |=> (o_wb_dat == {24'h0, uart.uart_lcrh_reg}));
AMBER_UART_LCRM_RD: assert property (@(posedge i_clk)uart.wb_start_read && (i_wb_adr[15:0] == AMBER_UART_LCRM) |=> (o_wb_dat == {24'h0, uart.uart_lcrm_reg}));
AMBER_UART_LCRL_RD: assert property (@(posedge i_clk)uart.wb_start_read && (i_wb_adr[15:0] == AMBER_UART_LCRL) |=> (o_wb_dat == {24'h0, uart.uart_lcrl_reg}));
AMBER_UART_CR_RD: assert property (@(posedge i_clk)uart.wb_start_read && (i_wb_adr[15:0] == AMBER_UART_CR) |=> (o_wb_dat == {24'h0, uart.uart_cr_reg}));


wire [7:0] uart_fr_reg = {uart.tx_fifo_empty, uart.rx_fifo_full, uart.tx_fifo_full,uart.rx_fifo_empty, !uart.tx_fifo_empty, 1'd1, 1'd1, !uart.uart0_cts_n_d[3]};


wire [8:0] uart_iir_reg = {6'd0,uart.tx_interrupt, uart.rx_interrupt, 1'd0};

AMBER_UART_FR_RD: assert property (@(posedge i_clk) uart.wb_start_read && (i_wb_adr[15:0] == AMBER_UART_FR) |=> (uart.o_wb_dat == {24'h0, $past(uart_fr_reg,1)}));


AMBER_UART_IIR_RD: assert property (@(posedge i_clk) uart.wb_start_read && (i_wb_adr[15:0] == AMBER_UART_IIR) |=> (uart.o_wb_dat == {24'h0, $past(uart_iir_reg,1)}));


// 2.4.2.1 check default read
wire default_addr = (i_wb_adr[15:0] != AMBER_UART_CID0) && (i_wb_adr[15:0] != AMBER_UART_CID1) && (i_wb_adr[15:0] != AMBER_UART_CID2)&& (i_wb_adr[15:0] != AMBER_UART_CID3)&& (i_wb_adr[15:0] != AMBER_UART_PID0)&& (i_wb_adr[15:0] != AMBER_UART_PID1)&& (i_wb_adr[15:0] != AMBER_UART_PID2)&& (i_wb_adr[15:0] != AMBER_UART_PID3)&& (i_wb_adr[15:0] != AMBER_UART_DR)&& (i_wb_adr[15:0] != AMBER_UART_RSR)&& (i_wb_adr[15:0] != AMBER_UART_LCRH)&& (i_wb_adr[15:0] != AMBER_UART_LCRM)&& (i_wb_adr[15:0] != AMBER_UART_LCRL) && (i_wb_adr[15:0] != AMBER_UART_CR) && (i_wb_adr[15:0] != AMBER_UART_FR) && (i_wb_adr[15:0] != AMBER_UART_IIR);

DEFAULT_READ0: assert property(@(posedge i_clk) uart.wb_start_read && default_addr |=> o_wb_dat == 32'h00c0ffee);


// 2.4.3 check fifo not enabled
// 2.4.3 fifo not enabled, fifo is empty or full
// ASSERTION FAIL if no push/pop after switching to fifo_disable
RX_EMPTY_OR_FULL: assert property(@(posedge i_clk) ~uart.fifo_enable |=> uart.rx_fifo_empty ^ uart.rx_fifo_full);

// 2.5 interrupt status




// 2.6 random
ACK_ON_WR: assert property(@(posedge i_clk) i_wb_stb && i_wb_we |-> o_wb_ack);

wire rx_start_bit = (uart.rxd_d == 5'b11000) || (uart.rxd_d == 5'b11100);

RX_START: assert property(uart.rx_start == rx_start_bit);

WB_ERR: assert property(uart.o_wb_err == 1'b0);

// COVERAGE

// cover tx_fifo empty
TX_FIFO_FULL1_COV: cover property (uart.tx_fifo_empty == 1'b1);

// cover tx_fifo full
TX_FIFO_FULL2_COV: cover property (uart.tx_fifo_full == 1'b1);

// cover rx_fifo empty
RX_FIFO_FULL1_COV: cover property (uart.rx_fifo_empty == 1'b1);

// cover rx_fifo full
RX_FIFO_FULL2_COV: cover property (uart.rx_fifo_full == 1'b1);

WB_READ: cover property (i_wb_stb && ~i_wb_we);

WB_WRITE: cover property (i_wb_stb && i_wb_we);

// cover all states
// cover address
CID0_ADR: cover property ( (i_wb_adr[15:0] == AMBER_UART_CID0));
CID1_ADR: cover property ( (i_wb_adr[15:0] == AMBER_UART_CID1));
CID2_ADR: cover property ( (i_wb_adr[15:0] == AMBER_UART_CID2));
CID3_ADR: cover property ( (i_wb_adr[15:0] == AMBER_UART_CID3));
PID0_ADR: cover property ( (i_wb_adr[15:0] == AMBER_UART_PID0));
PID1_ADR: cover property ( (i_wb_adr[15:0] == AMBER_UART_PID1));
PID2_ADR: cover property ( (i_wb_adr[15:0] == AMBER_UART_PID2));
PID3_ADR: cover property ( (i_wb_adr[15:0] == AMBER_UART_PID3));
DR_ADR: cover property ( (i_wb_adr[15:0] == AMBER_UART_DR ));
RSR_ADR: cover property ( (i_wb_adr[15:0] == AMBER_UART_RSR));
LCRH_ADR: cover property ( (i_wb_adr[15:0] == AMBER_UART_LCRH ));
LCRM_ADR: cover property ( (i_wb_adr[15:0] == AMBER_UART_LCRM));
LCRL_ADR: cover property ( (i_wb_adr[15:0] == AMBER_UART_LCRL));
CR_ADR: cover property ( (i_wb_adr[15:0] == AMBER_UART_CR ));
FR_ADR: cover property ( (i_wb_adr[15:0] == AMBER_UART_FR));
IIR_ADR: cover property ( (i_wb_adr[15:0] == AMBER_UART_IIR));
ICR_ADR: cover property ( (i_wb_adr[15:0] == AMBER_UART_ICR));

endmodule





module Wrapper;

bind uart uart_jg uart_jg1 (

	.i_clk(i_clk),
	.i_wb_adr(i_wb_adr),
	.i_wb_sel(i_wb_sel),
	.i_wb_we(i_wb_we),
	.o_wb_dat(o_wb_dat),
	.i_wb_dat(i_wb_dat),
	.i_wb_cyc(i_wb_cyc),
	.i_wb_stb(i_wb_stb),
	.o_wb_ack(o_wb_ack),
	.o_wb_err(o_wb_err),
	.o_uart_int(o_uart_int),
        .i_uart_cts_n(i_uart_cts_n),   
        .o_uart_txd(o_uart_txd),     
        .o_uart_rts_n(o_uart_rts_n),  
        .i_uart_rxd(i_uart_rxd) 
);

endmodule









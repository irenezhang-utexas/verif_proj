
`include "system_config_defines.vh"
`include "register_addresses.vh"
`define AMBER_UART_BAUD 230400

module uart  (
input                       i_clk,

input       [31:0]          i_wb_adr,
input       [WB_SWIDTH-1:0] i_wb_sel,
input                       i_wb_we,
output      [WB_DWIDTH-1:0] o_wb_dat,
input       [WB_DWIDTH-1:0] i_wb_dat,
input                       i_wb_cyc,
input                       i_wb_stb,
output                      o_wb_ack,
output                      o_wb_err,

output                      o_uart_int,

input                       i_uart_cts_n,   // Clear To Send
output                      o_uart_txd,     // Transmit data
output                      o_uart_rts_n,   // Request to Send
input                       i_uart_rxd,      // Receive data

input [3:0]		    txd_state,
input [3:0]		    rxd_state
);

// 1.ASSUMPTIONS

// 2. ASSERTIONS

// 2.1 tx FIFO

// 2.1.1 check tx_state sequence
TX_STATE0: assert property(@(posedge clk) (txd_state == TXD_IDLE) |=> (txd_state == TXD_IDLE) || (txd_state == TXD_START));

TX_STATE1to11: assert property(@(posedge clk) (txd_state > TXD_IDLE) && (txd_state < TXD_STOP3) |=> (txd_state == $past(txd_state,1))|| (txd_state == ($past(txd_state,1) + 4'd1)));

TX_STATE_12: assert property(@(posedge clk) (txd_state == TXD_STOP3) |=> (txd_state == TXD_STOP3) || (txd_state == TXD_IDLE));

// 2.1.2 check tx_state range
TX_STATE_RANGE: assert property(@(posedge clk) txd_state <= 4'd12 );

// 2.1.3 TODO: check tx_state no deadlock

// 2.1.4 FIFO no change when full
TX_FIFO_FULL: assert property (@(posedge clk) tx_fifo_full |=> (tx_fifo_wp == $(tx_fifo_wp,1));

// 2.2 rx FIFO
// 2.2.1 check rx_state sequence
RX_STATE0: assert property(@(posedge clk) (rxd_state == RXD_IDLE) |=> (rxd_state == RXD_IDLE) || (rxd_state == RXD_START));

RX_STATE1to11: assert property(@(posedge clk) (rxd_state > RXD_IDLE) && (rxd_state < RXD_STOP3) |=> (rxd_state == $past(rxd_state,1))|| (rxd_state == ($past(rxd_state,1) + 4'd1)));

RX_STATE_12: assert property(@(posedge clk) (rxd_state == RXD_STOP3) |=> (rxd_state == RXD_STOP3) || (rxd_state == RXD_IDLE));

// 2.2.2 check rx_state range
RX_STATE_RANGE: assert property(@(posedge clk) rxd_state <= 4'd12 );

// 2.2.3 TODO: check rx_state no deadlock

// 2.2.4 FIFO no change when full
RX_FIFO_FULL: assert property (@(posedge clk) rx_fifo_full |=> ~rxen);
// TODO: wr ptr not change when full

// 2.2.4.1 TODO: rx fifo state == IDLE


// 2.2.5.1 rx_full & rx_empty

// 2.2.5.1.1 rx_full and rx_empty not asserted at the same time
RX_FULL_EMPTY: assert property(@(posedge clk) ~(rx_fifo_empty && rx_fifo_full));

// 2.2.5.1.2 rise rx_full only on push
RX_FULL_ROSE_ON_PUSH: assert property (@(posedge clk) $rose(rx_fifo_full) |-> $past(rx_fifo_push,1) && $past(fifo_enable,1));

// 2.2.5.1.3 fell rx_full only on pop
RX_FULL_FELL_ON_POP: assert property (@(posedge clk) $fell(rx_fifo_full) |-> $past(rx_fifo_pop,1) && $past(fifo_enable,1));


// 2.2.5.1.4 rose rx_empty only on pop
RX_FULL_ROSE_ON_POP: assert property (@(posedge clk) $rose(rx_fifo_empty) |-> $past(rx_fifo_pop,1) && $past(fifo_enable,1));

// 2.2.5.1.5 fell rx_empty only on push
RX_FULL_FELL_ON_PUSH: assert property (@(posedge clk) $fell(rx_fifo_empty) |-> $past(rx_fifo_push,1) && $past(fifo_enable,1));

// 2.2.5.2 tx_full & rx_empty

// 2.2.5.2.1 tx_full and tx_empty not asserted at the same time
TX_FULL_EMPTY: assert property(@(posedge clk) ~(tx_fifo_empty && tx_fifo_full));

// 2.2.5.1.2 rise rx_full only on push
TX_FULL_ROSE_ON_PUSH: assert property (@(posedge clk) $rose(tx_fifo_full) |-> $past(tx_fifo_push,1) && $past(fifo_enable,1));

// 2.2.5.1.3 fell rx_full only on pop
TX_FULL_FELL_ON_POP: assert property (@(posedge clk) $fell(tx_fifo_full) |-> $past(tx_fifo_pop,1) && $past(fifo_enable,1));


// 2.2.5.1.4 rose rx_empty only on pop
TX_FULL_ROSE_ON_POP: assert property (@(posedge clk) $rose(tx_fifo_empty) |-> $past(tx_fifo_pop,1) && $past(fifo_enable,1));

// 2.2.5.1.5 fell rx_empty only on push
TX_FULL_FELL_ON_PUSH: assert property (@(posedge clk) $fell(tx_fifo_empty) |-> $past(tx_fifo_push,1) && $past(fifo_enable,1));



// 2.3 pointers

// 2.3.1 check tx_fifo_wp
// 2.3.1.1 pointer change < 2
TX_RPTR_CHANGE: assert property ( @(posedge clk) rx_fifo_wp - $past(rx_fifo_wp,1) < 2); 
TX_WPTR_CHANGE: assert property ( @(posedge clk) tx_fifo_wp - $past(tx_fifo_wp,1) < 2); 

// 2.3.2 check rx_fifo_wp
// 2.3.2.1 pointer change < 2
RX_WPTR_CHANGE: assert property ( @(posedge clk) rx_fifo_rp - $past(rx_fifo_rp,1) < 2); 
RX_RPTR_CHANGE: assert property ( @(posedge clk) rx_fifo_wp - $past(rx_fifo_wp,1) < 2); 

// 2.3.3 check rx_fifo_pop on addr == AMBER_UART_DR
RX_FIFO_POP0: assert property ( @(posedge clk) rx_fifo_rp != $past(rx_fifo_rp,1) |-> $past(i_wb_stb,2) && ~$past(i_wb_we,2));
RX_FIFO_POP1: assert property ( @(posedge clk) rx_fifo_rp != $past(rx_fifo_rp,1) |-> $past(i_wb_adr,1)[15:0] == AMBER_UART_DR);

// 2.3.4 check tx_fifo_push on addr == AMBER_UART_DR
TX_FIFO_POP0: assert property ( @(posedge clk) tx_fifo_rp != $past(rx_fifo_rp,1) |-> $past(i_wb_stb,2) && $past(i_wb_we,2));
TX_FIFO_POP1: assert property ( @(posedge clk) tx_fifo_rp != $past(rx_fifo_rp,1) |-> $past(i_wb_adr,1)[15:0] == AMBER_UART_DR);

// 2.4.5 check fifo not enabled
// 2.4.5.1 wr ptrs no change
FIFO_DIS_WR_PTR0: assert property ( @(posedge clk) !fifo_enable |=> tx_fifo_wp == 0);
FIFO_DIS_WR_PTR1: assert property ( @(posedge clk) !fifo_enable |=> tx_fifo_rp == 0);
FIFO_DIS_WR_CNT: assert property ( @(posedge clk) !fifo_enable |=> tx_fifo_count == 0);

// 2.4.5.2 rd ptrs no change
FIFO_DIS_RD_PTR0: assert property ( @(posedge clk) !fifo_enable |=> rx_fifo_wp == 0);
FIFO_DIS_RD_PTR1: assert property ( @(posedge clk) !fifo_enable |=> rx_fifo_rp == 0);
FIFO_DIS_RD_CNT: assert property ( @(posedge clk) !fifo_enable |=> rx_fifo_count == 0);

// 2.4 data correctness

// 2.4.1 check write data







// 2.4.2 check read data





// 2.4.2.1 check default read
DEFAULT_READ0: assert property(@(posedge clk) i_wb_stb && ~i_wb_we && (~$past(i_wb_stb,1) || ~$past(i_wb_we,1)) |-> o_wb_dat == 32'h00c0ffee);


// 2.4.3 check fifo not enabled
// 2.4.3 fifo not enabled, fifo is empty or full
RX_EMPTY_OR_FULL: assert property(@(posedge clk) ~fifo_enable |=> rx_fifo_empty ^ rx_fifo_full);

// 2.5 interrupt status





// 2.6 random
ACK_ON_WR: assert property(@(posedge clk) i_wb_stb && i_wb_we |=> o_wb_ack);

wire rx_start_bit = (rxd_d == 5'b11000) || (rxd_d == 5'b11100);

RX_START: assert property(uart.rx_start == rx_start_bit);

WB_ERR: assert property(o_wb_err == 1'b0);

// COVERAGE

// cover tx_fifo empty
TX_FIFO_FULL: cover property (uart.tx_fifo_empty == 1'b1);

// cover tx_fifo full
TX_FIFO_FULL: cover property (uart.tx_fifo_full == 1'b1);

// cover rx_fifo empty
RX_FIFO_FULL: cover property (uart.rx_fifo_empty == 1'b1);

// cover rx_fifo full
RX_FIFO_FULL: cover property (uart.rx_fifo_full == 1'b1);

WB_READ: cover property (i_wb_stb && ~i_wb_we);

WB_WRITE: cover property (i_wb_stb && i_wb_we);




endmodule


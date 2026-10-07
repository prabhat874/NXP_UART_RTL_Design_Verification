`timescale 1ns/1ps
module uart_loopback #(
    parameter integer CLK_FREQ_HZ = 1_000_000,
    parameter integer BAUD_RATE   = 10_000
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output wire       tx,
    output wire       busy,
    output wire       done,
    output wire [7:0] rx_data,
    output wire       rx_valid,
    output wire       framing_error
);
    wire tx_busy;
    wire tx_done;

    uart_tx #(.CLK_FREQ_HZ(CLK_FREQ_HZ), .BAUD_RATE(BAUD_RATE)) u_tx (
        .clk(clk), .rst(rst), .tx_start(tx_start), .tx_data(tx_data),
        .tx(tx), .busy(tx_busy), .done(tx_done)
    );

    uart_rx #(.CLK_FREQ_HZ(CLK_FREQ_HZ), .BAUD_RATE(BAUD_RATE)) u_rx (
        .clk(clk), .rst(rst), .rx(tx), .rx_data(rx_data),
        .rx_valid(rx_valid), .busy(), .framing_error(framing_error)
    );

    assign busy = tx_busy;
    assign done = tx_done;
endmodule

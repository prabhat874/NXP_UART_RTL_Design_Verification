`timescale 1ns/1ps
module uart_tx #(
    parameter integer CLK_FREQ_HZ = 50_000_000,
    parameter integer BAUD_RATE   = 115200
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx,
    output reg        busy,
    output reg        done
);
    localparam integer CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;
    localparam integer CW = (CLKS_PER_BIT <= 2) ? 1 : $clog2(CLKS_PER_BIT);

    reg [CW-1:0] clk_count;
    reg [3:0] bit_index;
    reg [9:0] frame;

    always @(posedge clk) begin
        if (rst) begin
            tx        <= 1'b1;
            busy      <= 1'b0;
            done      <= 1'b0;
            clk_count <= 0;
            bit_index <= 0;
            frame     <= 10'h3FF;
        end else begin
            done <= 1'b0;

            if (!busy) begin
                tx <= 1'b1;
                if (tx_start) begin
                    frame     <= {1'b1, tx_data, 1'b0}; // stop, data, start
                    busy      <= 1'b1;
                    bit_index <= 0;
                    clk_count <= 0;
                    tx        <= 1'b0;
                end
            end else begin
                if (clk_count == CLKS_PER_BIT-1) begin
                    clk_count <= 0;
                    if (bit_index == 9) begin
                        busy      <= 1'b0;
                        done      <= 1'b1;
                        tx        <= 1'b1;
                        bit_index <= 0;
                    end else begin
                        bit_index <= bit_index + 1'b1;
                        tx        <= frame[bit_index + 1'b1];
                    end
                end else begin
                    clk_count <= clk_count + 1'b1;
                end
            end
        end
    end
endmodule

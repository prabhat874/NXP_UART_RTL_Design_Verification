`timescale 1ns/1ps
module uart_rx #(
    parameter integer CLK_FREQ_HZ = 50_000_000,
    parameter integer BAUD_RATE   = 115200
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,
    output reg [7:0]  rx_data,
    output reg        rx_valid,
    output reg        busy,
    output reg        framing_error
);
    localparam integer CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;
    localparam integer HALF_BIT     = CLKS_PER_BIT / 2;
    localparam integer CW = (CLKS_PER_BIT <= 2) ? 1 : $clog2(CLKS_PER_BIT);

    reg [CW-1:0] clk_count;
    reg [3:0] bit_index;
    reg [7:0] data_reg;
    reg [1:0] state;

    localparam IDLE=2'd0, START=2'd1, DATA=2'd2, STOP=2'd3;

    always @(posedge clk) begin
        if (rst) begin
            rx_data       <= 8'h00;
            rx_valid      <= 1'b0;
            busy          <= 1'b0;
            framing_error <= 1'b0;
            clk_count     <= 0;
            bit_index     <= 0;
            data_reg      <= 0;
            state         <= IDLE;
        end else begin
            rx_valid <= 1'b0;
            framing_error <= 1'b0;

            case (state)
                IDLE: begin
                    busy <= 1'b0;
                    clk_count <= 0;
                    bit_index <= 0;
                    if (!rx) begin
                        busy <= 1'b1;
                        state <= START;
                        clk_count <= 0;
                    end
                end

                START: begin
                    if (clk_count == HALF_BIT-1) begin
                        clk_count <= 0;
                        if (!rx) begin
                            bit_index <= 0;
                            state <= DATA;
                        end else begin
                            busy <= 1'b0;
                            state <= IDLE;
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                DATA: begin
                    if (clk_count == CLKS_PER_BIT-1) begin
                        clk_count <= 0;
                        data_reg[bit_index] <= rx;
                        if (bit_index == 7) begin
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                STOP: begin
                    if (clk_count == CLKS_PER_BIT-1) begin
                        clk_count <= 0;
                        busy <= 1'b0;
                        state <= IDLE;
                        if (rx) begin
                            rx_data <= data_reg;
                            rx_valid <= 1'b1;
                        end else begin
                            framing_error <= 1'b1;
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule

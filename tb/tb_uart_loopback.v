`timescale 1ns/1ps
module tb_uart_loopback;
    localparam CLK_FREQ_HZ = 1_000_000;
    localparam BAUD_RATE   = 10_000;

    reg clk = 0;
    reg rst = 1;
    reg tx_start = 0;
    reg [7:0] tx_data = 0;
    wire tx, busy, done;
    wire [7:0] rx_data;
    wire rx_valid, framing_error;

    uart_loopback #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk), .rst(rst), .tx_start(tx_start), .tx_data(tx_data),
        .tx(tx), .busy(busy), .done(done), .rx_data(rx_data),
        .rx_valid(rx_valid), .framing_error(framing_error)
    );

    always #5 clk = ~clk; // 100 MHz simulation clock

    task send_and_check;
        input [7:0] value;
        begin
            @(posedge clk);
            while (busy) @(posedge clk);
            tx_data <= value;
            tx_start <= 1'b1;
            @(posedge clk);
            tx_start <= 1'b0;

            wait (rx_valid);
            #1;
            if (rx_data !== value) begin
                $display("FAIL: TX=0x%02h RX=0x%02h", value, rx_data);
                $fatal(1);
            end else begin
                $display("PASS: TX=0x%02h RX=0x%02h", value, rx_data);
            end
            if (framing_error) begin
                $display("FAIL: framing error detected");
                $fatal(1);
            end
            @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("sim/uart_loopback.vcd");
        $dumpvars(0, tb_uart_loopback);

        repeat (5) @(posedge clk);
        rst <= 1'b0;

        send_and_check(8'h55);
        send_and_check(8'hA3);
        send_and_check(8'h00);
        send_and_check(8'hFF);
        send_and_check(8'h5A);

        $display("====================================");
        $display("UART RTL VERIFICATION PASSED");
        $display("====================================");
        $finish;
    end
endmodule

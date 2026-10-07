#!/bin/bash
mkdir -p sim
iverilog -g2012 -o sim/uart_tb.vvp rtl/uart_tx.v rtl/uart_rx.v rtl/uart_loopback.v tb/tb_uart_loopback.v && vvp sim/uart_tb.vvp

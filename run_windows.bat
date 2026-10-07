@echo off
if not exist sim mkdir sim
iverilog -g2012 -o sim\uart_tb.vvp rtl\uart_tx.v rtl\uart_rx.v rtl\uart_loopback.v tb\tb_uart_loopback.v
if errorlevel 1 exit /b 1
vvp sim\uart_tb.vvp

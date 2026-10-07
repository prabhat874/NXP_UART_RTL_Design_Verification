# UART RTL Design and Verification Project

NXP-oriented VLSI / RTL portfolio project.

## Contents
- `rtl/uart_tx.v` - synthesizable UART transmitter
- `rtl/uart_rx.v` - synthesizable UART receiver
- `rtl/uart_loopback.v` - TX-to-RX integration wrapper
- `tb/tb_uart_loopback.v` - self-checking simulation testbench
- `sim/` - generated VCD waveform and simulation executable

## Requirements
Icarus Verilog (`iverilog`) and GTKWave (optional for waveform viewing).

## Run on Windows PowerShell
From the project root:

```powershell
iverilog -g2012 -o sim\uart_tb.vvp rtl\uart_tx.v rtl\uart_rx.v rtl\uart_loopback.v tb\tb_uart_loopback.v
vvp sim\uart_tb.vvp
```

Expected result includes:

```text
PASS: TX=0x55 RX=0x55
PASS: TX=0xA3 RX=0xA3
PASS: TX=0x00 RX=0x00
PASS: TX=0xFF RX=0xFF
PASS: TX=0x5A RX=0x5A
UART RTL VERIFICATION PASSED
```

## View waveform
After running `vvp`:

```powershell
gtkwave sim\uart_loopback.vcd
```

If GTKWave is not installed, the simulation still works; the VCD file is generated for later waveform inspection.

## Design notes
The testbench uses a 1 MHz logical UART clock parameter and 10 kbaud for fast simulation. The RTL itself is parameterized and can be configured for a real FPGA clock and baud rate, e.g. 50 MHz / 115200.

## Interview topics to prepare
- UART frame structure
- Why UART is asynchronous
- Start and stop bit detection
- Baud-rate generation
- FSM design
- Blocking vs non-blocking assignments
- Synthesizable vs simulation-only Verilog
- Counters and clock-domain/timing considerations
- Self-checking testbench methodology
- Synthesis and FPGA implementation flow

# UART Energy Arbitrage Controller

SystemVerilog implementation of a UART-connected energy arbitrage controller for the DE1-SoC board.

The FPGA receives electricity price samples over UART, tracks battery state of charge internally, and returns the selected action plus the updated battery percentage.

## Project Structure

- `DE1_SoC.sv` - DE1-SoC board wrapper
- `rtl/` - synthesizable SystemVerilog modules
- `tb/` - ModelSim testbenches
- `DE1_SoC.qpf`, `DE1_SoC.qsf`, `DE1_SoC.sdc` - Quartus project files
- `Launch_ModelSim.bat`, `topLevelrunlab.do`, `topLevel_wave.do` - main ModelSim flow
- `runlab.do`, `wave.do` - smaller FSM-only ModelSim flow

## Architecture

The design is split into three main blocks:

- UART stack: `receiver`, `transmitter`, FIFOs, and the combined `top_uart`
- Controller: `uart_energy_controller`, which parses incoming price bytes, owns SOC, and sends response bytes
- Decision FSM: `energy_arbitrage_fsm`, which chooses charge, discharge, or idle

The top-level project entity is `DE1_SoC`. It wraps `uart_energy_top` and connects the design to board-level pins.

See `docs/block_diagram.md` for the full block diagram and signal map.

## UART Protocol

The host sends one 16-bit price sample as two UART bytes:

1. `price[15:8]`
2. `price[7:0]`

SOC is not sent by the host. The FPGA initializes SOC to `100` on reset and updates it after each decision.

The controller sends two UART bytes back:

1. status byte
2. updated SOC

Status byte values:

- `0x42` / `B` - buy / charge
- `0x53` / `S` - sell / discharge
- `0x49` / `I` - idle

## Decision Policy

- Charge when `price < 3000` and `soc < 90`
- Discharge when `price > 3600` and `soc > 20`
- Idle otherwise

After the decision:

- Charge increments SOC by 1, saturated at 100
- Discharge decrements SOC by 1, saturated at 0
- Idle leaves SOC unchanged

## DE1-SoC Mapping

- `CLOCK_50` - system clock
- `KEY[0]` - reset, active low on the board
- `GPIO_0[0]` - UART RX into FPGA
- `GPIO_0[1]` - UART TX from FPGA
- `LEDR[0]` - charge
- `LEDR[1]` - discharge
- `LEDR[2]` - idle
- `LEDR[4:3]` - FSM state
- `LEDR[9:5]` - lower five bits of SOC

## ModelSim

This repo uses the same ModelSim-style flow as the pipelined CPU project.

Open ModelSim with:

```text
Launch_ModelSim.bat
```

Main simulation:

```tcl
do topLevelrunlab.do
```

FSM-only simulation:

```tcl
do runlab.do
```

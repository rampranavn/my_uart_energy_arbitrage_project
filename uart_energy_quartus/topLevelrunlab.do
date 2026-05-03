# Create work library
vlib work

# Compile SystemVerilog
#     All SystemVerilog files that are part of this design should have
#     their own "vlog" line below.
vlog -sv "./rtl/boud_generator.sv"
vlog -sv "./rtl/fifo.sv"
vlog -sv "./rtl/transmitter.sv"
vlog -sv "./rtl/receiver.sv"
vlog -sv "./rtl/top_transmitter.sv"
vlog -sv "./rtl/top_receiver.sv"
vlog -sv "./rtl/top_uart.sv"
vlog -sv "./rtl/energy_arbitrage_fsm.sv"
vlog -sv "./rtl/uart_energy_controller.sv"
vlog -sv "./rtl/uart_energy_top.sv"
vlog -sv "./tb/tb_uart_energy_top.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work tb_uart_energy_top

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do topLevel_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End

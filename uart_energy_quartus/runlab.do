# Create work library
vlib work

# Compile SystemVerilog
#     This shorter lab run focuses only on the energy arbitrage FSM.
vlog -sv "./rtl/energy_arbitrage_fsm.sv"
vlog -sv "./tb/tb_energy_arbitrage_fsm.sv"

# Call vsim to invoke simulator
vsim -voptargs="+acc" -t 1ps -lib work tb_energy_arbitrage_fsm

# Source the wave do file
do wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End

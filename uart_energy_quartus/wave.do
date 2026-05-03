onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_energy_arbitrage_fsm/clk
add wave -noupdate /tb_energy_arbitrage_fsm/rst
add wave -noupdate /tb_energy_arbitrage_fsm/valid
add wave -noupdate -radix unsigned /tb_energy_arbitrage_fsm/price
add wave -noupdate -radix unsigned /tb_energy_arbitrage_fsm/soc
add wave -noupdate /tb_energy_arbitrage_fsm/charge
add wave -noupdate /tb_energy_arbitrage_fsm/discharge
add wave -noupdate /tb_energy_arbitrage_fsm/idle
add wave -noupdate -radix binary /tb_energy_arbitrage_fsm/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 220
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {500 ns}

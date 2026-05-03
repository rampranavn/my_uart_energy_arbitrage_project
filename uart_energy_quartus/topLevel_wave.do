onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_uart_energy_top/clk
add wave -noupdate /tb_uart_energy_top/rst
add wave -noupdate /tb_uart_energy_top/rx
add wave -noupdate /tb_uart_energy_top/tx
add wave -noupdate -radix unsigned /tb_uart_energy_top/soc
add wave -noupdate -radix unsigned /tb_uart_energy_top/price
add wave -noupdate /tb_uart_energy_top/charge
add wave -noupdate /tb_uart_energy_top/discharge
add wave -noupdate /tb_uart_energy_top/idle
add wave -noupdate -radix binary /tb_uart_energy_top/energy_state
add wave -noupdate -radix unsigned /tb_uart_energy_top/dut/CTRL/soc
add wave -noupdate -radix unsigned /tb_uart_energy_top/dut/CTRL/response_soc
add wave -noupdate -radix unsigned /tb_uart_energy_top/dut/CTRL/price
add wave -noupdate -radix binary /tb_uart_energy_top/dut/CTRL/byte_state
add wave -noupdate /tb_uart_energy_top/dut/CTRL/sample_valid
add wave -noupdate /tb_uart_energy_top/dut/CTRL/wr_uart
add wave -noupdate /tb_uart_energy_top/dut/CTRL/rd_uart
add wave -noupdate -radix hexadecimal /tb_uart_energy_top/dut/CTRL/tx_data
add wave -noupdate -radix hexadecimal /tb_uart_energy_top/dut/CTRL/rx_data
add wave -noupdate /tb_uart_energy_top/dut/CTRL/tx_full
add wave -noupdate /tb_uart_energy_top/dut/CTRL/rx_empty
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
WaveRestoreZoom {0 ns} {1 ms}

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /DE1_SoC_testbench/CLOCK_PERIOD
add wave -noupdate /DE1_SoC_testbench/HEX5
add wave -noupdate /DE1_SoC_testbench/HEX4
add wave -noupdate /DE1_SoC_testbench/HEX3
add wave -noupdate /DE1_SoC_testbench/HEX2
add wave -noupdate /DE1_SoC_testbench/HEX1
add wave -noupdate /DE1_SoC_testbench/HEX0
add wave -noupdate /DE1_SoC_testbench/inc_hour
add wave -noupdate /DE1_SoC_testbench/pp
add wave -noupdate /DE1_SoC_testbench/entr_wait
add wave -noupdate /DE1_SoC_testbench/exit_wait
add wave -noupdate /DE1_SoC_testbench/led_p
add wave -noupdate /DE1_SoC_testbench/led_full
add wave -noupdate /DE1_SoC_testbench/entr_open
add wave -noupdate /DE1_SoC_testbench/exit_open
add wave -noupdate /DE1_SoC_testbench/clk
add wave -noupdate /DE1_SoC_testbench/reset
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8929 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 100
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {7300 ps} {11300 ps}

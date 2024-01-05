onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /hw1p1_testbench/S
add wave -noupdate /hw1p1_testbench/x
add wave -noupdate /hw1p1_testbench/y
add wave -noupdate /hw1p1_testbench/reset
add wave -noupdate /hw1p1_testbench/clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10300 ps} 0}
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
WaveRestoreZoom {2188 ps} {5558 ps}

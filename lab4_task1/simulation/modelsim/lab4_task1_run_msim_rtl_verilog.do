transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab4_task1 {C:/Users/there/OneDrive - UW/CSE 371/lab4_task1/DE1_SoC_task1.sv}
vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab4_task1 {C:/Users/there/OneDrive - UW/CSE 371/lab4_task1/double_seg7.sv}
vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab4_task1 {C:/Users/there/OneDrive - UW/CSE 371/lab4_task1/bit_counter.sv}
vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab4_task1 {C:/Users/there/OneDrive - UW/CSE 371/lab4_task1/bc_data.sv}
vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab4_task1 {C:/Users/there/OneDrive - UW/CSE 371/lab4_task1/bc_ctrl.sv}


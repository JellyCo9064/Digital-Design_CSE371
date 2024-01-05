transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab2_task2 {C:/Users/there/OneDrive - UW/CSE 371/lab2_task2/ram32x4.v}
vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab2_task2 {C:/Users/there/OneDrive - UW/CSE 371/lab2_task2/double_seg7.sv}
vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab2_task2 {C:/Users/there/OneDrive - UW/CSE 371/lab2_task2/fiveb_counter.sv}
vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab2_task2 {C:/Users/there/OneDrive - UW/CSE 371/lab2_task2/lab2_task2.sv}


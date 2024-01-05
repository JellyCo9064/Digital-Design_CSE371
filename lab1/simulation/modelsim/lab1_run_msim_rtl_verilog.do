transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab1 {C:/Users/there/OneDrive - UW/CSE 371/lab1/sensor.sv}
vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab1 {C:/Users/there/OneDrive - UW/CSE 371/lab1/fiveb_counter.sv}
vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab1 {C:/Users/there/OneDrive - UW/CSE 371/lab1/double_seg7.sv}
vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab1 {C:/Users/there/OneDrive - UW/CSE 371/lab1/parking_lot.sv}


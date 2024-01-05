transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab6 {C:/Users/there/OneDrive - UW/CSE 371/lab6/ram8x16.v}
vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab6 {C:/Users/there/OneDrive - UW/CSE 371/lab6/seg7.sv}
vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab6 {C:/Users/there/OneDrive - UW/CSE 371/lab6/rh_ctrl.sv}
vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab6 {C:/Users/there/OneDrive - UW/CSE 371/lab6/rh_data.sv}
vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab6 {C:/Users/there/OneDrive - UW/CSE 371/lab6/DE1_SoC.sv}
vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab6 {C:/Users/there/OneDrive - UW/CSE 371/lab6/pulse_gen.sv}
vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab6 {C:/Users/there/OneDrive - UW/CSE 371/lab6/car_tracking.sv}


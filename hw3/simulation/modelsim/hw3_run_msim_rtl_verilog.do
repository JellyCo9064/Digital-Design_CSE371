transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/hw3 {C:/Users/there/OneDrive - UW/CSE 371/hw3/hw3p3.sv}


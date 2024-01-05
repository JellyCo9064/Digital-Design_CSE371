transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab5_test {C:/Users/there/OneDrive - UW/CSE 371/lab5_test/lab5rom.v}
vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/lab5_test {C:/Users/there/OneDrive - UW/CSE 371/lab5_test/tone_generator.sv}


transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/hw2 {C:/Users/there/OneDrive - UW/CSE 371/hw2/sync_rom.sv}
vlog -sv -work work +incdir+C:/Users/there/OneDrive\ -\ UW/CSE\ 371/hw2 {C:/Users/there/OneDrive - UW/CSE 371/hw2/sign_mag_add.sv}


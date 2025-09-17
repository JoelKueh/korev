
sim:


test_fetch:
	iverilog -g2012 -s fetchtb \
		./src/cpu/fetch.sv \
		./src/cpu/mmu.sv \
		./tb/cpu/fetch/fetchtb.sv \
		-o ./bin/tb/cpu/fetch/Vfetchtb
#	verilator --cc --binary \
#		--Mdir ./bin/tb/cpu/fetch \
#		--top-module fetchtb \
#		./src/cpu/fetch.sv \
#		./src/cpu/mmu.sv \
#		./tb/cpu/fetch/fetchtb.sv
	./tb/cpu/fetch/testfetch.sh

test_decode:


test_exec:


test_mem:


test: test_fetch, test_decode, test_exec, test_mem



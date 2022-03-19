VCS = vcs -V -sverilog +vc -Mupdate -line -full64 +vcs+vcdpluson -debug_pp +lint=TFIPC-L

HEADERS = ../sys_def.sv
TESTBENCH = tb_bcp.sv
SIMFILES  = bcp_pe.sv

all:    simv
	./simv | tee program.out

.PHONY: all

# Simulation:

sim:	simv
	./simv | tee program.out

simv:	$(HEADERS) $(SIMFILES) $(TESTBENCH)
	$(VCS) $^ -o simv

.PHONY: sim

dve:	simv
	./simv -gui &

dve_syn: syn_simv 
	./syn_simv -gui &

.PHONY: dve dve_syn

clean:
	rm -rf *simv *simv.daidir csrc vcs.key program.out *.key
	rm -rf vis_simv vis_simv.daidir
	rm -rf dve* inter.vpd DVEfiles
	rm -rf syn_simv syn_simv.daidir syn_program.out
	rm -rf synsimv synsimv.daidir csrc vcdplus.vpd vcs.key synprog.out pipeline.out writeback.out vc_hdrs.h
	rm -f *.elf *.dump *.mem debug_bin

nuke:	clean
	rm -rf synth/*.vg synth/*.rep synth/*.ddc synth/*.chk synth/*.log synth/*.syn synth/*svsim.sv synth/*.res
	rm -rf synth/*.out command.log synth/*.db synth/*.svf synth/*.mr synth/*.pvl
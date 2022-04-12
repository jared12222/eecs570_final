VCS = vcs -V -sverilog +vc -Mupdate -line -full64 +vcs+vcdpluson -debug_pp +lint=TFIPC-L +vcs+loopreport
LIB = /afs/umich.edu/class/eecs470/lib/verilog/lec25dscc25.v

# TESTBENCH =  tb_generate.sv
TESTBENCH =  tb_top.sv utilities.cpp
SIMFILES  =  top.sv proc.sv
SIMFILES  += ./bcp/bcp_pe.sv
SIMFILES  += ./latency_buffer/L_buffer_singleload.sv
SIMFILES  += ./cla_queue/cla_queue.sv ./uc/queue.sv
SIMFILES  += $(wildcard ./uc/uc*.sv)
SIMFILES  += ./cla_queue/gst.sv
SYNFILES  =  top.vg
HEADERS   =  sys_def.sv
TCL       =  top.tcl

export SIMFILES
export HEADERS
export TESTBENCH


top.vg:		sys_def.sv top.sv ./uc/uc_arbiter_mstack.sv ./latency_buffer/L_buffer_singleload.sv ./uc/uc_arbiter.sv ./uc/uc_arbiter_wrapper.sv ./cla_queue/gst.sv $(TCL)
	dc_shell-t -f $(TCL) | tee top_synth.out

proc.vg:	sys_def.sv proc.sv ./bcp/bcp_pe.sv ./cla_queue/cla_queue.sv ./uc/queue.sv proc.tcl
	dc_shell-t -f ./proc.tcl | tee proc_synth.out

all:    simv
	./simv | tee program.out

.PHONY: all


# Simulation:

sim:	simv
	./simv | tee program.out

simv:	$(HEADERS) $(INCLUDES) $(SIMFILES) $(TESTBENCH)
	$(VCS) $^ -o simv | tee compile.out

.PHONY: sim

dve:	simv
	./simv -gui &

syn_simv:	$(HEADERS) $(SYNFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SYNFILES) $(LIB) -o syn_simv

syn:	syn_simv
	./syn_simv | tee syn.out

proc_syn_simv:	$(HEADERS) proc.vg engine_null_testbench.sv
	$(VCS) engine_null_testbench.sv proc.vg $(LIB) -o proc_syn_simv

proc_syn:	_syn_simv
	./proc_syn_simv | tee proc_syn.out

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

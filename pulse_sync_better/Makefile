help:
	-@echo "######################################################################"
	-@echo "FROM EACH test_<name> DIRECTORY...."
	-@echo "make vcst    	=> Run VC Static on current testcase"
	-@echo "make clean  	=> Clean up current testcase directory"
	-@echo "FROM examples DIRECTORY...."
	-@echo "make all  		=> Run VCST"
	-@echo "make allclean	=> Clean up current all testcase directories"
	-@echo "make help   	=> Generate this help menu      "
	-@echo "NOTE: Refer to README file for more details on the testcase"
	-@echo "######################################################################"
vcs:
	vcs -full64 -kdb -lca -debug_access+all -sverilog +define+TB_SIM -timescale=1ns/1ns -f ./filelist.f -l vcs.log -R
verdi:
	verdi -ssf wave.fsdb&
vcst:
	$(VC_STATIC_HOME)/bin/vc_static_shell -file vcst.tcl -output_log_file vcst.screen.log

clean:
	-@rm -rf vcst_rtdb
	-@rm -rf vcst_command.log
	-@rm -rf db_read.log
	-@rm -rf lib.defs
	-@rm -rf vlogImport.log
	-@rm -rf detail.log
	-@rm -rf summary.log
	-@rm -rf report_cdc*
	-@rm -rf *.screen.log
	-@rm -rf *.log
	-@rm -rf *.rpt
	-@rm -rf simv*

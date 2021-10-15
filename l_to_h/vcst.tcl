set_app_var enable_cdc true
read_file -format verilog -top l_to_h -vcs {-f ./filelist.f }

read_sdc clk.sdc

check_cdc

report_cdc -file report_cdc.summary.log
report_cdc -verbose -file report_cdc.detailed.log

view_activity

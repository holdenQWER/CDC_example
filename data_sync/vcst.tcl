set_app_var enable_cdc true
read_file -format verilog -top data_sync -vcs {-f ./filelist.f }

read_sdc clk.sdc

configure_cdc_data_sync -to_clock {clk_d} -from_obj {data_sync/data_r} -des_enable_expr {data_sync/data_sel_d}
check_cdc
report_cdc -file report_cdc.summary.log
report_cdc -verbose -file report_cdc.detailed.log

view_activity

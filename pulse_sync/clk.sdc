create_clock -name c1  -period 10 {clk_s}
create_clock -name c2  -period 5 {clk_d}

set_clock_groups -asynchronous -group {c1} -group {c2}

create_reset -async -sense low -clock {c1} {rstn_s}

set_input_delay 1 -clock c1 event_s
set_input_delay 1 -clock c1 rstn_s


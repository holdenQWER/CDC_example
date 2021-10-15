module pulse_sync(input clk_s,
                  input rstn_s,
                  input event_s,
                  input clk_d,
                  input rstn_d,
                  output event_d);
            

   reg event_s_toggle;
   reg event_d_dly;
   wire event_d_sync;

	always @(posedge clk_s or negedge rstn_s)
      if(~rstn_s)
         event_s_toggle <= 1'b0;
      else
        event_s_toggle <= event_s_toggle ^ event_s;

   sync_cell u_2dff_sync(.clk(clk_d),
                         .rst_n(rstn_d),
                         .in(event_s_toggle),
                         .out(event_d_sync));

	always @(posedge clk_d or negedge rstn_d)
      if(~rstn_d)
         event_d_dly <= 1'b0;
      else
         event_d_dly <= event_d_sync;

   assign event_d = event_d_dly ^ event_d_sync;

endmodule

`ifdef TB_SIM
module tb();

   logic clk1,clk2;
   logic rstn1,rstn2;
   logic ctrl_in;
   logic ctrl_out;

   initial begin
      clk1 = 0;
      clk2 = 0;
   end

   always  #5   clk1 = ~clk1;
   always  #10  clk2 = ~clk2;

   initial begin
      #17 rstn1 = 0;
      #17 rstn2 = 0;
      @(posedge clk1);
      @(posedge clk1);
      @(posedge clk1);
      rstn1 = 1;
      rstn2 = 1;
   end
   initial begin
      ctrl_in = 0;
      #130 ctrl_in = 1;
      #10 ctrl_in = 0;
      #30 ctrl_in = 1;
      #10 ctrl_in = 0;
      #30 ctrl_in = 1;
      #10 ctrl_in = 0;
      #30 ctrl_in = 1;
      #10 ctrl_in = 0;
      #10 ctrl_in = 1;
      #10 ctrl_in = 0;
      #10 ctrl_in = 1;
      #10 ctrl_in = 0;
      repeat(20) @(posedge clk1);
      $finish;
   end

   pulse_sync u_dut(.clk_s(clk1),
                    .rstn_s(rstn1),
                    .event_s(ctrl_in),
                    .clk_d(clk2),
                    .rstn_d(rstn2),
                    .event_d(ctrl_out));

   initial begin
      $fsdbDumpfile("wave.fsdb");
      $fsdbDumpvars;
   end

endmodule
`endif

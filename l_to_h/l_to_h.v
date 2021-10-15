module l_to_h (input clk_s,
               input rstn_s,
               input event_s,
               input clk_d,
               output event_d);
            
   reg event_s_dly;
   reg event_d_dly1;
   reg event_d_dly2;
   wire event_d_sync;

	always @(posedge clk_s or negedge rstn_s)
      if(~rstn_s)
         event_s_dly <= 1'b0;
      else
         event_s_dly <= event_s;

   rstn_sync u_rstn_sync(.clk(clk_d),
                         .rstn_in(rstn_s),
                         .rstn_out(rstn_d));

   sync_cell u_sync_l   (.clk(clk_d),
                         .rst_n(rstn_d),
                         .in(event_s_dly),
                         .out(event_d_sync));

	always @(posedge clk_d or negedge rstn_d)
      if(~rstn_d) begin
         event_d_dly1 <= 1'b0;
      end
      else begin
         event_d_dly1 <= event_d_sync;
      end

   assign event_d = event_d_sync & ~event_d_dly1;
endmodule

`ifdef SIM
module tb();

   logic clk1,clk2;
   logic rstn;
   logic ctrl_in;
   logic ctrl_out;

   initial begin
      clk1 = 0;
      clk2 = 0;
   end

   always  #20   clk1 = ~clk1;
   always  #5  clk2 = ~clk2;

   initial begin
      #17 rstn = 0;
      @(posedge clk1);
      @(posedge clk1);
      @(posedge clk1);
      rstn = 1;
   end
   initial begin
      ctrl_in = 0;
      #130 ctrl_in = 1;
      #40 ctrl_in = 0;
      #15 ctrl_in = 1;
      #40 ctrl_in = 0;
      repeat(20) @(posedge clk1);
      $finish;
   end

   l_to_h u_dut (.clk_s(clk1),
                 .rstn_s(rstn),
                 .event_s(ctrl_in),
                 .clk_d(clk2),
                 .event_d(ctrl_out));

   initial begin
      $fsdbDumpfile("wave.fsdb");
      $fsdbDumpvars;
   end

endmodule
`endif

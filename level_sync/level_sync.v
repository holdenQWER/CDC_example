module level_sync(input clk_s,
                  input rstn_s,
                  input ctrl_s,
                  input clk_d,
                  output ctrl_d);
            
   reg ctrl_s_d;
   wire rstn_d;

	always @(posedge clk_s or negedge rstn_s)
      if(~rstn_s)
         ctrl_s_d <= 1'b0;
      else
         ctrl_s_d <= ctrl_s;

   rstn_sync u_rstn_sync(.clk(clk_d),
                         .rstn_in(rstn_s),
                         .rstn_out(rstn_d));

   sync_cell u_2dff_sync(.clk(clk_d),
                         .rst_n(rstn_d),
                         .in(ctrl_s_d),
                         .out(ctrl_d));
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

   initial begin
      #5;
      forever  #5   clk1 = ~clk1;
   end
   always  #10  clk2 = ~clk2;

   initial begin
      #17 rstn = 0;
      @(posedge clk1);
      @(posedge clk1);
      @(posedge clk1);
      rstn = 1;
   end
   initial begin
      ctrl_in = 0;
      #90 ctrl_in = 1;
      #20 ctrl_in = 0;
      repeat(10) @(posedge clk1);
      $finish;
   end

   level_sync u_dut(.clk_s(clk1),
                    .rstn_s(rstn),
                    .ctrl_s(ctrl_in),
                    .clk_d(clk2),
                    .ctrl_d(ctrl_out));

   initial begin
      $fsdbDumpfile("wave.fsdb");
      $fsdbDumpvars;
   end

endmodule
`endif

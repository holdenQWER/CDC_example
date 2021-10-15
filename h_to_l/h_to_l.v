module h_to_l #(parameter CLK_RATO = 2)
       (input clk_s,
        input rstn_s,
        input event_s,
        input clk_d,
        output event_d);
            
   reg event_s_dly;
   reg event_d_sync;
   reg [CLK_RATO-1:0] event_s_expand;
	always @(posedge clk_s or negedge rstn_s)
      if(~rstn_s)
         event_s_dly <= 1'b0;
      else
         event_s_dly <= event_s;

	always @(posedge clk_s or negedge rstn_s)
      if(~rstn_s)
         event_s_expand <= {CLK_RATO{1'b0}};
      else
         event_s_expand <= {event_s_expand[CLK_RATO-2:0],event_s_dly};

   rstn_sync u_rstn_sync(.clk(clk_d),
                         .rstn_in(rstn_s),
                         .rstn_out(rstn_d));

   sync_cell u_sync_l   (.clk(clk_d),
                         .rst_n(rstn_d),
                         .in(|event_s_expand),
                         .out(event_d));

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

   always  #5   clk1 = ~clk1;
   initial begin
      #5;
      forever  #20  clk2 = ~clk2;
   end

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
      #10 ctrl_in = 0;
      repeat(20) @(posedge clk1);
      $finish;
   end

   h_to_l #(.CLK_RATO(4)) u_dut
                                (.clk_s(clk1),
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

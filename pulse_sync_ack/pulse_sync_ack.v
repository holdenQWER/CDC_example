module pulse_sync_ack(input clk_s,
                  input rstn_s,
                  input event_s,
                  input clk_d,
                  input rstn_d,
                  output event_d,
                  output ack_s);
            

   reg event_s_toggle;
   reg event_d_dly;
   wire event_d_sync;

   wire event_ack;
   reg event_ack_dly;
   wire ack_pulse;

   reg state_cur;
   reg state_nxt;
   reg ack_r;
   parameter READY = 1'b0;
   parameter BUSY  = 1'b1;

   always @(posedge clk_s or negedge rstn_s)
      if(~rstn_s) 
         state_cur <= READY;
      else
         state_cur <= state_nxt;

   always @(*) begin
      state_nxt = state_cur;
      case (state_cur)
         READY:begin
            ack_r = 1;
            if(event_s)
               state_nxt = BUSY;
         end
         BUSY: begin
            ack_r = 0;
            if(ack_pulse)
               state_nxt = READY;
         end
         default: begin
            state_nxt = READY;
         end
      endcase
   end

   assign ack_s = ack_r;

	always @(posedge clk_s or negedge rstn_s)
      if(~rstn_s)
         event_s_toggle <= 1'b0;
      else
        event_s_toggle <= event_s_toggle ^ (event_s & ack_s);

   sync_cell u_2dff_sync_s(.clk(clk_d),
                         .rst_n(rstn_d),
                         .in(event_s_toggle),
                         .out(event_d_sync));

	always @(posedge clk_d or negedge rstn_d)
      if(~rstn_d)
         event_d_dly <= 1'b0;
      else
         event_d_dly <= event_d_sync;

   assign event_d = event_d_dly ^ event_d_sync;

   sync_cell u_2dff_sync_d(.clk(clk_s),
                         .rst_n(rstn_s),
                         .in(event_d_dly),
                         .out(event_ack));

	always @(posedge clk_s or negedge rstn_s)
      if(~rstn_s)
         event_ack_dly <= 1'b0;
      else
         event_ack_dly <= event_ack;

   assign ack_pulse = event_ack_dly ^ event_ack;
endmodule

`ifdef SIM
module tb();

   logic clk1,clk2;
   logic rstn1,rstn2;
   logic ctrl_in;
   logic ctrl_out;
   logic ack_out;

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
      repeat(3) begin
         wait(ack_out);
         #1 ctrl_in = 1;
         #10 ctrl_in = 0;
      end
      repeat(3) begin // error stimulus
         #30 ctrl_in = 1;
         #10 ctrl_in = 0;
      end
      repeat(20) @(posedge clk1);
      $finish;
   end

   pulse_sync_ack u_dut(.clk_s(clk1),
                    .rstn_s(rstn1),
                    .event_s(ctrl_in),
                    .clk_d(clk2),
                    .rstn_d(rstn2),
                    .event_d(ctrl_out),
                    .ack_s(ack_out));

   initial begin
      $fsdbDumpfile("wave.fsdb");
      $fsdbDumpvars;
   end

endmodule
`endif

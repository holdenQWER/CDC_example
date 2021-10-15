module data_sync(input clk_s,
                  input rstn_s,
                  input data_vld_s,
                  input [7:0] data_s,
                  input clk_d,
                  input rstn_d,
                  input load_d,
                  output data_vld_d,
                  output reg [7:0] data_d,
                  output ack_s);
            


   reg state_curs;
   reg state_nxts;
   reg [1:0]state_curd;
   reg [1:0]state_nxtd;
   reg ack_r;
   parameter READYS = 1'b0;
   parameter BUSYS  = 1'b1;
   parameter IDLED  = 2'b00;
   parameter WAITD  = 2'b01;
   parameter READYD = 2'b10;

   reg [7:0] data_r;
   reg data_vld;
   wire data_sel_s;
   wire data_sel_d;
   wire ack_sync;
   wire data_vld_sync;

   // source domain data MUX
   always @(posedge clk_s or negedge rstn_s)
      if(~rstn_s) 
         data_r <= 8'h0;
      else if (data_sel_s)
         data_r <= data_s;
         
   // destination domain data MUX
   always @(posedge clk_d or negedge rstn_d)
      if(~rstn_d) 
         data_d <= 8'h0;
      else if (data_sel_d)
         data_d <= data_r;

   // source domain FSM
   always @(posedge clk_s or negedge rstn_s)
      if(~rstn_s) 
         state_curs <= READYS;
      else
         state_curs <= state_nxts;

   always @(*) begin
      state_nxts = state_curs;
      case (state_curs)
         READYS:begin
            ack_r = 1;
            if(data_vld_s)
               state_nxts = BUSYS;
         end
         BUSYS: begin
            ack_r = 0;
            if(ack_sync)
               state_nxts = READYS;
         end
         default: begin
            state_nxts = READYS;
         end
      endcase
   end

   assign ack_s = ack_r;
   assign data_sel_s = data_vld_s & ack_s;

   // source to destination pulse sync
   pulse_sync u_pulse_sync_s(.clk_s(clk_s),
                             .rstn_s(rstn_s),
                             .event_s(data_sel_s),
                             .clk_d(clk_d),
                             .rstn_d(rstn_d),
                             .event_d(data_vld_sync));


   // destination domain FSM
   always @(posedge clk_d or negedge rstn_d)
      if(~rstn_d) 
         state_curd <= IDLED;
      else
         state_curd <= state_nxtd;

   always @(*) begin
      state_nxtd = state_curd;
      case (state_curd)
         IDLED:begin
            data_vld = 0;
            if(data_vld_sync)
               state_nxtd = WAITD;
         end
         WAITD:begin
            data_vld = 1;
            if(load_d)
               state_nxtd = READYD;
         end
         READYD:begin
            data_vld = 0;
            if(!load_d)
               state_nxtd = IDLED;
         end
         default:begin
            state_nxtd = IDLED;
            data_vld = 0;
         end
      endcase
   end

   assign data_sel_d = load_d & data_vld;
   assign data_vld_d = data_vld;

   // destination to source domain sync
   pulse_sync u_pulse_sync_d(.clk_s(clk_d),
                             .rstn_s(rstn_d),
                             .event_s(data_sel_d),
                             .clk_d(clk_s),
                             .rstn_d(rstn_s),
                             .event_d(ack_sync));

endmodule

`ifdef SIM
module tb();

   logic clk1,clk2;
   logic rstn1,rstn2;
   logic data_in_vld,data_out_vld;
   logic [7:0] data_in,data_out;
   logic data_load;
   logic ack_out;
   int count;

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
      data_in = 8'hA0;
      data_load = 0;
      data_in_vld = 0;
      #130;
      repeat(3) begin
         wait(ack_out);
         #1 data_in_vld = 1;
         #10 data_in_vld = 0;
         data_in++;
         wait(data_out_vld);
         repeat(count++) @(posedge clk2);
         #1 data_load = 1;
         #20 data_load = 0;
         repeat(20) @(posedge clk1);
      end
      $finish;
   end

   data_sync u_dut(.clk_s(clk1),
                   .rstn_s(rstn1),
                   .data_vld_s(data_in_vld),
                   .data_s(data_in),
                   .clk_d(clk2),
                   .rstn_d(rstn2),
                   .load_d(data_load),
                   .data_vld_d(data_out_vld),
                   .data_d(data_out),
                   .ack_s(ack_out));

   initial begin
      $fsdbDumpfile("wave.fsdb");
      $fsdbDumpvars;
   end

endmodule
`endif

module sync_cell (input wire clk,
	               input wire rst_n,
                  input wire in,
	               output wire out);

   reg in_d1;
   reg in_d2;

   always @(posedge clk or negedge rst_n) begin
      if(~rst_n) begin
         in_d1 <= 1'b0;
         in_d2 <= 1'b0;
      end
      else begin
         in_d1 <= in;
         in_d2 <= in_d1;
      end
   end

   assign out = in_d2;

endmodule

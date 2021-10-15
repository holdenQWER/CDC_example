module rstn_sync (input wire clk,
                  input wire rstn_in,
                  output wire rstn_out);

   reg rstn_d1;
   reg rstn_d2;

   always @(posedge clk or negedge rstn_in) begin
      if(~rstn_in) begin
         rstn_d1 <= 1'b0;
         rstn_d2 <= 1'b0;
      end
      else begin
         rstn_d1 <= rstn_in;
         rstn_d2 <= rstn_d1;
      end
   end

   assign rstn_out = rstn_d2;

endmodule

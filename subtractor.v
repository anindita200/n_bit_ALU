module subtractor #(parameter DWIDTH = 8) (clk, din1, din2, dout_subtractor);
input clk;
input [DWIDTH-1:0] din1;
input [DWIDTH-1:0] din2;
output [DWIDTH-1:0] dout_subtractor;

reg [DWIDTH-1:0] dout_adder_temp_ff;
adder add2((~din2),1,dout_adder_temp);
adder add3(din1,dout_adder_temp_ff,dout_subtractor);

always @(posedge clk)
begin
	dout_adder_temp_ff <= dout_adder_temp;
end

endmodule
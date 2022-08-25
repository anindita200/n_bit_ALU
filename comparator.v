module comparator #(parameter DWIDTH=8) (a,b,dout_comparator);
input [DWIDTH-1:0] a,b;
output reg [DWIDTH-1:0] dout_comparator;

always @(a or b)
begin
  if(a==b)
  dout_comparator = 0;
  else if (a>b)
  dout_comparator = 2;
  else
  dout_comparator = 1;
end
endmodule
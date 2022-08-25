module not_er #(parameter DWIDTH = 8)(din1,dout_not_er);
input [DWIDTH-1:0] din1;
output [DWIDTH-1:0] dout_not_er;

assign dout_not_er = ~din1;

endmodule
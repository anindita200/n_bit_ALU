module or_er #(parameter DWIDTH = 8) (din1,din2,dout_or_er);
input [DWIDTH-1:0] din1;
input [DWIDTH-1:0] din2;
output [DWIDTH-1:0] dout_or_er;

assign dout_or_er = din1|din2;

endmodule
module and_er #(parameter DWIDTH = 8) (din1,din2,dout_and_er);
input [DWIDTH-1:0] din1;
input [DWIDTH-1:0] din2;
output [DWIDTH-1:0] dout_and_er;

assign dout_and_er = din1 & din2;

endmodule
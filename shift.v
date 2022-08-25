module shift #(parameter DWIDTH = 8)(
input   [DWIDTH-1:0] dir,
input   [DWIDTH-1:0] din,
output  [DWIDTH-1:0]dout
);

assign dout = dir ? din<<1
			      : din>>1;

endmodule
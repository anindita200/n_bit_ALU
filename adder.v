// Verilog code for carry look-ahead adder
module adder #(parameter DWIDTH = 8)(in1, in2, carry_in, sum, carry_out);

input [DWIDTH - 1:0] in1;
input [DWIDTH - 1:0] in2;
input carry_in;
output [DWIDTH - 1:0] sum;
output carry_out;

//assign {carry_out, sum} = in1 + in2 + carry_in;

wire [DWIDTH - 1:0] gen;
wire [DWIDTH - 1:0] pro;
wire [DWIDTH:0] carry_tmp;

genvar j, i;
generate
 //assume carry_tmp in is zero
 assign carry_tmp[0] = carry_in;
 
 //carry generator
 for(j = 0; j < DWIDTH; j = j + 1) begin: carry_generator
 assign gen[j] = in1[j] & in2[j];
 assign pro[j] = in1[j] | in2[j];
 assign carry_tmp[j+1] = gen[j] | pro[j] & carry_tmp[j];
 end
 
 //carry out 
 assign carry_out = carry_tmp[DWIDTH];
 
 //calculate sum 
 //assign sum[0] = in1[0] ^ in2 ^ carry_in;
 for(i = 0; i < DWIDTH; i = i+1) begin: sum_without_carry
 assign sum[i] = in1[i] ^ in2[i] ^ carry_tmp[i];
 end 
endgenerate 
endmodule

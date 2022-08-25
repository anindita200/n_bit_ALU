`timescale 1ns/1ps
`define DELAY 10

// Verilog project: Verilog code for multiplier using carry-look-ahead adders
module multiplier #(parameter DWIDTH = 8) (multicand, multiplier, product1, product2);

input [DWIDTH-1:0] multicand;
input [DWIDTH-1:0] multiplier;
output [DWIDTH-1:0] product1;
output [DWIDTH-1:0] product2;
wire [(DWIDTH + DWIDTH - 1):0] product;

assign product1 = product[DWIDTH-1:0];
assign product2 = product[(DWIDTH<<1)-1:DWIDTH];


wire [DWIDTH - 1:0] multicand_tmp [DWIDTH-1:0];
wire [DWIDTH - 1:0] product_tmp [DWIDTH-1:0];
wire [DWIDTH -1:0] carry_tmp;

genvar i, j;
generate 
 //initialize values
 for(j = 0; j < DWIDTH; j = j + 1) begin: for_loop_j
 assign multicand_tmp[j] =  multicand & {DWIDTH{multiplier[j]}};
 end
 
 assign product_tmp[0] = multicand_tmp[0];
 assign carry_tmp[0] = 1'b0;
 assign product[0] = product_tmp[0][0];
 
 for(i = 1; i < DWIDTH; i = i + 1) begin: for_loop_i
 adder #(.DATA_WID(DWIDTH)) add1 (
     // Outputs
     .sum(product_tmp[i]),
     .carry_out(carry_tmp[i]),
     // Inputs
   .carry_in(1'b0),
     .in1(multicand_tmp[i]),
   .in2({carry_tmp[i-1],product_tmp[i-1][7-:7]}));
 assign product[i] = product_tmp[i][0];
 end //end for loop
 assign product[(DWIDTH+DWIDTH-1):DWIDTH] = {carry_tmp[DWIDTH-1],product_tmp[DWIDTH-1][7-:7]};
endgenerate
endmodule

`timescale 1ns/1ps
//`define DELAY #10
 
// Verilog code for carry look-ahead adder
module adder (in1, in2, carry_in, sum, carry_out);
parameter DATA_WID = 8;

input [DATA_WID - 1:0] in1;
input [DATA_WID - 1:0] in2;
input carry_in;
output [DATA_WID - 1:0] sum;
output carry_out;

//assign {carry_out, sum} = in1 + in2 + carry_in;

wire [DATA_WID - 1:0] gen;
wire [DATA_WID - 1:0] pro;
wire [DATA_WID:0] carry_tmp;

genvar j, i;
generate
 //assume carry_tmp in is zero
 assign carry_tmp[0] = carry_in;
 
 //carry generator
 for(j = 0; j < DATA_WID; j = j + 1) begin: carry_generator
 assign gen[j] = in1[j] & in2[j];
 assign pro[j] = in1[j] | in2[j];
 assign carry_tmp[j+1] = gen[j] | pro[j] & carry_tmp[j];
 end
 
 //carry out 
 assign carry_out = carry_tmp[DATA_WID];
 
 //calculate sum 
 //assign sum[0] = in1[0] ^ in2 ^ carry_in;
 for(i = 0; i < DATA_WID; i = i+1) begin: sum_without_carry
 assign sum[i] = in1[i] ^ in2[i] ^ carry_tmp[i];
 end 
endgenerate 
endmodule


// Verilog project: Verilog code for multiplier using carry look ahead adder
`define DELAY 10
module multiplier_tb();
 parameter DWIDTH = 8;
 parameter DWIDTH = 8;
 // /*AUTOREGINPUT*/
 // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
 reg [DWIDTH-1:0] multicand; // To mul1 of cla_multiplier.v
 reg [DWIDTH-1:0]multiplier; // To mul1 of cla_multiplier.v
 // End of automatics

 /*AUTOWIRE*/
 // Beginning of automatic wires (for undeclared instantiated-module outputs)
 wire [(DWIDTH+DWIDTH-1):0]product;// From mul1 of cla_multiplier.v
 // End of automatics

multiplier mul1(/*AUTOINST*/
     // // Outputs
      .product1 (product[(DWIDTH-1):0]),
      .product2 (product[(DWIDTH<<1)-1:DWIDTH]),
     // // Inputs
      .multicand (multicand[DWIDTH-1:0]),
     .multiplier (multiplier[DWIDTH-1:0]));
 
  integer i;
 initial begin
 
//   #(`DELAY) //correct
  multicand = 8'hFF;
  multiplier = 8'h7F;
 
  #(`DELAY) //correct
  multicand = 8'h80;
  multiplier = 8'hF0;
 
  #(`DELAY) //faila
  multicand = 8'h80;
  multiplier = 8'hF0;
 
  #(`DELAY) //correct
  multicand = 8'hF0;
  multiplier = 8'hF7;
 
  #(`DELAY) //correct
  multicand = 8'hFF;
  multiplier = 8'hFF;
 end
  initial begin
  $dumpfile("dump.vcd"); $dumpvars;
  end
endmodule
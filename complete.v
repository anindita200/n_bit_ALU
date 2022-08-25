module top #(parameter DWIDTH = 8)(
inout clk,
input mode,
input [2:0] op,
input [DWIDTH-1:0] din1,
input [DWIDTH-1:0] din2,
output reg [DWIDTH-1:0] dout
);
reg done;
reg [(DWIDTH<<1):0]counter;

reg [(DWIDTH<<1)-1:0] result;	//to store the result of logical or arithmetic operation

wire [(DWIDTH<<1)-1:0] dout_adder;
wire [(DWIDTH<<1)-1:0] dout_subtractor;
wire [(DWIDTH<<1)-1:0] dout_multiplier;
wire [(DWIDTH<<1)-1:0] dout_divider;
wire [(DWIDTH<<1)-1:0] dout_comparator;

adder add1(din1,din2,dout_adder);
subtractor sub1(clk,din1,din2,dout_subtractor);
multiplier mult1(din1,din2,dout_multiplier);
divider div1(.clk(clk),.x(din1),.y(din2),.dout(dout_divider));
comparator comp1(din1,din2,dout_comparator);

wire [DWIDTH-1:0] dout_and;
wire [DWIDTH-1:0] dout_or;
wire [DWIDTH-1:0] dout_xor;
wire [DWIDTH-1:0] dout_not;
wire [DWIDTH-1:0] dout_shift;
wire [DWIDTH-1:0] dout_ashift;

and_er and1(din1,din2,dout_and);
or_er or1(din1,din2,dout_or);
xor_er xor1(din1,din2,dout_xor);
not_er not1(din1,dout_not);
shift_er shift1(din1,dir,dout_shift);
ashift_er ashift1(din1,dir,dout_ashift);

wire [11:0] ssd_temp;
BCD_Convert bin_to_bcd(dout[DWIDTH-1:0], ssd_temp);
ssd_out d2(ssd_temp[11:8] , HEX[2]);
ssd_out d1(ssd_temp[7:4]  , HEX[1]);
ssd_out d0(ssd_temp[3:0]  , HEX[0]);

always @(posedge clk)
begin
	if(done) begin 
	done <= 0;
	counter <= 1;
	end
	else if(~done & mode & op==3) begin
	counter <= counter << 1; 
	done <= (counter == 1<<(DWIDTH<<1) );
	end
	else 
	done <= 1;
end

always @(posedge clk)
begin
	result <= mode ? (op==0 ? dout_adder
						 	: op==1 ? dout_subtractor 
						 	: op==2 ? dout_multiplier 
						 	: op==3 ? dout_divider
						 	: op==4 ? dout_comparator 
						 	: 		  0)
				   : (op==0 ? dout_and
				   			: op==1 ? dout_or
						 	: op==2 ? dout_xor 
						 	: op==3 ? dout_not
						 	: op==4 ? dout_shift
						 	: op==5 ? dout_ashift  
						 	:   	  0 );
end
always @(posedge done)
begin
	dout <= result;
end
endmodule

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



module divider #(parameter DWIDTH=8) (
    input wire logic clk,
    input wire logic start,          // start signal
    input wire logic [DWIDTH-1:0] x,  // dividend
    input wire logic [DWIDTH-1:0] y,  // divisor
    // output     logic [DWIDTH-1:0] q,  // quotient
    // output     logic [DWIDTH-1:0] r   // remainder
    output     logic [(DWIDTH<<1)-1:0] dout
    );
    
    reg  busy;           // calculation in progress
    reg  valid;          // quotient and remainder are valid
    reg  dbz;            // divide by zero flag
    reg [DWIDTH-1:0] q;
    reg [DWIDTH-1:0] r;
    assign dout = {q,r};
    logic [DWIDTH-1:0] y1;            // copy of divisor
    logic [DWIDTH-1:0] q1, q1_next;   // intermediate quotient
    logic [DWIDTH:0] ac, ac_next;     // accumulator (1 bit wider)
  logic [clogb2(DWIDTH)-1:0] i;     // iteration counter

  always @(*) begin
        if (ac >= {1'b0,y1}) begin
            ac_next = ac - y1;
            {ac_next, q1_next} = {ac_next[DWIDTH-1:0], q1, 1'b1};
        end else begin
            {ac_next, q1_next} = {ac, q1} << 1;
        end
    end

    always @(posedge clk) begin
        if (start) begin
            valid <= 0;
            i <= 0;
            if (y == 0) begin  // catch divide by zero
                busy <= 0;
                dbz <= 1;
            end else begin  // initialize values
                busy <= 1;
                dbz <= 0;
                y1 <= y;
                {ac, q1} <= {{DWIDTH{1'b0}}, x, 1'b0};
            end
        end else if (busy) begin
            if (i == DWIDTH-1) begin  // we're done
                busy <= 0;
                valid <= 1;
                q <= q1_next;
                r <= ac_next[DWIDTH:1];  // undo final shift
            end else begin  // next iteration
                i <= i + 1;
                ac <= ac_next;
                q1 <= q1_next;
            end
        end
    end


function integer clogb2;
   input [31:0] value;
   integer  i;
   begin
      clogb2 = 0;
      for(i = 0; 2**i < value; i = i + 1)
    clogb2 = i + 1;
   end
endfunction
endmodule

//Testbench for divider
module divider_tb();

    parameter CLK_PERIOD = 10;  // 10 ns == 100 MHz
    parameter DWIDTH = 8;

    logic clk;
    logic start;            // start signal
    // logic busy;             // calculation in progress
    // logic valid;            // quotient and remainder are valid
    // logic dbz;              // divide by zero flag
    logic [DWIDTH-1:0] x;    // dividend
    logic [DWIDTH-1:0] y;    // divisor
    logic [(DWIDTH<<1)-1:0] dout;    // quotient
   // logic [DWIDTH-1:0] r;    // remainder

    divider #(.DWIDTH(DWIDTH)) divider_inst (.*);

    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        $monitor("\t%d:\t%d /%d =%d (r =) (V=) (DBZ=)",
            $time, x, y, dout/*, valid, dbz*/);
    end

    initial begin
        clk = 1;

        #100    x = 4'b0000;  // 0
                y = 4'b0010;  // 2
                start = 1;
        #10     start = 0;

        #50     x = 4'b0010;  // 2
                y = 4'b0000;  // 0
                start = 1;
        #10     start = 0;

        #50     x = 4'b0111;  // 7
                y = 4'b0010;  // 2
                start = 1;
        #10     start = 0;

        #50     x = 4'b1111;  // 15
                y = 4'b0101;  //  5
                start = 1;
        #10     start = 0;

        #50     x = 4'b0001;  // 1
                y = 4'b0001;  // 1
                start = 1;
        #10     start = 0;

        #50     x = 4'b1000;  // 8
                y = 4'b1001;  // 9
                start = 1;
        #10     start = 0;

        // ...

        #50     $finish;
    end
   initial begin
  $dumpfile("div.vcd"); 
  $dumpvars; 
 end
endmodule

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

module and_er #(parameter DWIDTH = 8) (din1,din2,dout_and_er);
input [DWIDTH-1:0] din1;
input [DWIDTH-1:0] din2;
output [DWIDTH-1:0] dout_and_er;

assign dout_and_er = din1 & din2;

endmodule

module or_er #(parameter DWIDTH = 8) (din1,din2,dout_or_er);
input [DWIDTH-1:0] din1;
input [DWIDTH-1:0] din2;
output [DWIDTH-1:0] dout_or_er;

assign dout_or_er = din1|din2;

endmodule

module xor_er #(parameter DWIDTH = 8)(din1,din2,dout_xor_er);
input [DWIDTH-1:0] din1;
input [DWIDTH-1:0] din2;
output [DWIDTH-1:0] dout_xor_er;

assign dout_xor_er = din1 | din2;

endmodule


module not_er #(parameter DWIDTH = 8)(din1,dout_not_er);
input [DWIDTH-1:0] din1;
output [DWIDTH-1:0] dout_not_er;

assign dout_not_er = ~din1;

endmodule

module shift #(parameter DWIDTH = 8)(
input   [DWIDTH-1:0] dir,
input   [DWIDTH-1:0] din,
output  [DWIDTH-1:0]dout
);

assign dout = dir ? din<<1
			      : din>>1;

endmodule

module ashift #(parameter DWIDTH = 8)(
input   [DWIDTH-1:0] dir,
input   [DWIDTH-1:0] din,
output  [DWIDTH-1:0]dout
);

assign dout = dir ? {din[DWIDTH-1],din[DWIDTH-2:0]<<1}
			      : {din[DWIDTH-1],din[DWIDTH-2:0]>>1};

endmodule

`timescale 1ns / 1ps

module BCD_convert #(parameter DWIDTH = 8)(
    input [DWIDTH-1:0] bin_in,
    output reg [11:0] BCD_out
    );
    
   
    integer i;
    
    always @(bin_in)
    begin
        BCD_out = 0;
        for (i = 0; i < DWIDTH+1; i = i + 1) //use a loop to shift the binary input the same number of times as it has number of bits. In this case, always 10.
        begin
        //Add 3 to any set representing a decimal output if the binary total is 5 or more to ensure proper carrying
            if (BCD_out[3:0] > 4)
                BCD_out[3:0] = BCD_out[3:0] + 3;
            if (BCD_out[7:4] > 4)
                BCD_out[7:4] = BCD_out[7:4] + 3;
            if (BCD_out[11:8] > 4)
                BCD_out[11:8] = BCD_out[11:8] + 3;
            BCD_out = {BCD_out[DWIDTH+1:0], bin_in[DWIDTH+1 - i]};
        end
    end
    
endmodule

`timescale 1ns / 1ps
module display_out(
    input [3:0] LED_BCD,
    output reg [6:0] BCD_display
    );
    
    
    always @(*) //convert the binary decimal representation to a format for the seven segment display
    begin
        case (LED_BCD)
            4'b0000: BCD_display = 7'b0000001; // out = 0
            4'b0001: BCD_display = 7'b1001111; // out = 1
            4'b0010: BCD_display = 7'b0010010; // out = 2
            4'b0011: BCD_display = 7'b0000110; // out = 3
            4'b0100: BCD_display = 7'b1001100; // out = 4
            4'b0101: BCD_display = 7'b0100100; // out = 5
            4'b0110: BCD_display = 7'b0100000; // out = 6
            4'b0111: BCD_display = 7'b0001111; // out = 7
            4'b1000: BCD_display = 7'b0000000; // out = 8
            4'b1001: BCD_display = 7'b0000100; // out = 9
            4'b1010: BCD_display = 7'b1111110; // out = -
            4'b1011: BCD_display = 7'b1111111; // out = no segments lit up
        endcase
    end
endmodule

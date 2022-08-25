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
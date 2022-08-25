

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
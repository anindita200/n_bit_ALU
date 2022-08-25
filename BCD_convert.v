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

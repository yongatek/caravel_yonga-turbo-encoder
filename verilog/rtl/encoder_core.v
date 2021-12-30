`timescale 1ns / 1ps
module encoder_core (
    //inputs
    i_clk, 
    i_rstn, 
    i_valid, 
    i_ena, 
    i_load_si, 
    i_a, 
    i_b, 
    i_si, 
    //outputs
    o_a, 
    o_b, 
    o_y, 
    o_w, 
    o_so
);
	
	parameter  MAX_BLOCK_WIDTH	  = 10,
					 P_WIDTH                           = 10,
					 MAX_DATA_WIDTH       =  MAX_BLOCK_WIDTH+2;
					 
    input       i_clk;
    input       i_rstn;
    input       i_valid; 
    input       i_ena; 
    input       i_load_si; 
    input       i_a;
    input       i_b; 
    input[3:0]  i_si;

    output      o_a; 
    output      o_b; 
    output      o_y; 
    output      o_w; 
    output[3:0] o_so;

    reg[3:0]    s_reg;
//
    

    always @(posedge i_clk)
        begin
            if (i_rstn == 0) //
                s_reg <= 0;
            
            else begin
                
                if (i_load_si == 1)
                    s_reg <= i_si;
                else if (i_valid == 1 && i_ena == 1) 
				begin
                    s_reg[3] <= i_a ^ i_b ^ s_reg[1] ^ s_reg[0];
                    s_reg[2] <= s_reg[3] ^ i_b;
                    s_reg[1] <= s_reg[2];
                    s_reg[0] <= s_reg[1] ^ i_b;
                end
                else
                    s_reg <= s_reg;
            
			end
        end
    
    assign o_a = i_a;
    assign o_b = i_b;
    assign o_y = i_a ^ i_b ^ s_reg[1] ^ s_reg[0] ^ s_reg[3] ^ s_reg[2] ^ s_reg[0];
    assign o_w = i_a ^ i_b ^ s_reg[1] ^ s_reg[0] ^ s_reg[2] ^ s_reg[1] ^ s_reg[0];
    assign o_so = s_reg;

endmodule


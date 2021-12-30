`timescale 1ns / 1ps
module pre_encoder (
    //inputs
    i_clk, 
    i_rstn, 
    i_valid, 
    i_ena, 
    i_load_si, 
    i_a, 
    i_b,
    i_conf_blocksize, 
    
    //outputs
    o_s
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
    input[MAX_BLOCK_WIDTH-1:0]  i_conf_blocksize;

    output[3:0] o_s;

    // wires and registers assigned
    wire[3:0]   o_so;
    wire[3:0]   w_S_out;
    reg [3:0]   nmod15_minus1;
    encoder_core ec1 (
      .i_clk     (i_clk),
      .i_rstn    (i_rstn),
      .i_valid   (i_valid),
      .i_ena     (i_ena),
      .i_load_si (i_load_si),
      .i_a       (i_a),
      .i_b       (i_b),
      .i_si      (4'b0000),
      .o_a       (),
      .o_b       (),
      .o_y       (),
      .o_w       (),
      .o_so      (o_so)
      );

    pre_encoder_rom pre_rom(
        .i_S(o_so),
        .i_nmod15_minus1(nmod15_minus1),
        .o_S_out(w_S_out)
    );

    always @(i_conf_blocksize)
    begin
        case(i_conf_blocksize)
            14: nmod15_minus1 = 10;
            38: nmod15_minus1 = 1;
            51: nmod15_minus1 = 8;
            55: nmod15_minus1 = 9;
            59: nmod15_minus1 = 10;
            62: nmod15_minus1 = 7;
            69: nmod15_minus1 = 5;
            84: nmod15_minus1 = 5;
            85: nmod15_minus1 = 9;
            93: nmod15_minus1 = 11;
            96: nmod15_minus1 = 8;
            100:nmod15_minus1 = 9;
            108:nmod15_minus1 = 11;
            115:nmod15_minus1 = 9;
            123:nmod15_minus1 = 11;
            130:nmod15_minus1 = 9;
            144:nmod15_minus1 = 5;
            170:nmod15_minus1 = 4;
            175:nmod15_minus1 = 9;
            188:nmod15_minus1 = 1;
            194:nmod15_minus1 = 10;
            264:nmod15_minus1 = 5;
            298:nmod15_minus1 = 6;
            333:nmod15_minus1 = 11;
            355:nmod15_minus1 = 9;
            400:nmod15_minus1 = 9;
            438:nmod15_minus1 = 11;
            444:nmod15_minus1 = 5;
            539:nmod15_minus1 = 10;
            599:nmod15_minus1 = 10;
            128:nmod15_minus1 = 1;
            192:nmod15_minus1 = 2;
            256:nmod15_minus1 = 3;
            307:nmod15_minus1 = 12;
            default: nmod15_minus1 = 0;
        endcase
    end

    assign o_s = w_S_out;

endmodule


    
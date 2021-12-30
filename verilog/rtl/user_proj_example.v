// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire rst;
    wire i_bof;
    wire i_eof;
    wire i_valid;
    wire [1:0] i_data;
    wire i_ready;
    wire o_ready;
    wire o_valid;
    wire o_bof;
    wire o_eof;
    wire [5:0] o_data;

    wire rx_fifo_rd;
    wire rx_fifo_wr;
    wire [3:0] rx_fifo_r_data;
    wire [3:0] rx_fifo_w_data;
    wire rx_fifo_empty;
    wire rx_fifo_full;

    wire tx_fifo_rd;
    wire tx_fifo_wr;
    wire [7:0] tx_fifo_r_data;
    wire [7:0] tx_fifo_w_data;
    wire tx_fifo_empty;
    wire tx_fifo_full;

    wire [5:0] param_sel;

    reg  rx_fifo_rd_start;
    reg  tx_fifo_rd_start;
    reg  master_rden;
    reg  wbs_ack_o;

    reg [9:0] i_conf_blocksize;
    reg [9:0] i_conf_p;
    reg [11:0] i_conf_q0;
    reg [11:0] i_conf_q1;
    reg [11:0] i_conf_q2;
    reg [11:0] i_conf_q3;

    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;

    wire valid;
    wire [3:0] wstrb;

    // WB MI A
    assign valid = wbs_cyc_i && wbs_stb_i; 
    assign wstrb = wbs_sel_i & {4{wbs_we_i}};

    assign io_oeb = {(`MPRJ_IO_PADS-1){rst}};

    // IRQ
    assign irq = 3'b000;	// Unused

    assign rx_fifo_rd = rx_fifo_rd_start & (~rx_fifo_empty);

    assign clk      = wb_clk_i;
    assign rst      = wb_rst_i;
    assign i_bof    = (la_data_in[32]) ? io_in[9] : rx_fifo_rd & rx_fifo_r_data[2];
    assign i_eof    = (la_data_in[32]) ? io_in[10] : rx_fifo_rd & rx_fifo_r_data[3];
    assign i_valid  = (la_data_in[32]) ? io_in[11] : rx_fifo_rd;
    assign i_data   = (la_data_in[32]) ? io_in[14:13] : (rx_fifo_rd) ? rx_fifo_r_data[1:0] : 0;
    assign i_ready  = (la_data_in[32]) ? io_in[18] : 1'b1;

    assign wbs_dat_o[14]    = (la_data_in[32]) ? 1'bz : 1'b1;
    assign wbs_dat_o[15]    = (la_data_in[32]) ? 1'bz : tx_fifo_rd_start;
    assign wbs_dat_o[6]     = (la_data_in[32]) ? 1'bz : tx_fifo_r_data[6];
    assign wbs_dat_o[7]     = (la_data_in[32]) ? 1'bz : tx_fifo_r_data[7];
    assign wbs_dat_o[5:0]   = (la_data_in[32]) ? 6'bz : tx_fifo_r_data[5:0]; 
    assign wbs_dat_o[31:16] = 0;
    assign wbs_dat_o[13:8]  = 0;

    assign io_out[12]       = (la_data_in[32]) ? o_ready : 1'bz;   
    assign io_out[17]       = (la_data_in[32]) ? o_valid : 1'bz;
    assign io_out[15]       = (la_data_in[32]) ? o_bof : 1'bz;
    assign io_out[16]       = (la_data_in[32]) ? o_eof : 1'bz;
    assign io_out[24:19]    = (la_data_in[32]) ? o_data : 6'bz;
    assign io_out[31]       = (la_data_in[32]) ? ~wb_clk_i : 1'bz;

    assign param_sel        = (la_data_in[32]) ? io_in[30:25] : la_data_in[38:33];

    turbo_encoder_top turbo_encoder_top_inst(
    .i_clk(clk),
    .i_rstn(~rst),
    .i_bof(i_bof),
    .i_eof(i_eof),
    .i_valid(i_valid),
    .i_data(i_data),
    .i_ready(i_ready),
    .o_ready(o_ready),
    .o_valid(o_valid),
    .o_bof(o_bof),
    .o_eof(o_eof),
    .o_data(o_data),
    .i_conf_blocksize(i_conf_blocksize),
    .i_conf_p(i_conf_p),
    .i_conf_q0(i_conf_q0),
    .i_conf_q1(i_conf_q1),
    .i_conf_q2(i_conf_q2),
    .i_conf_q3(i_conf_q3)
    );

    fifo #(.B(4), .W(8)) rx_fifo_inst(
        .clk(clk),
        .reset(rst),
        .rd(rx_fifo_rd),
        .wr(valid & (~wbs_ack_o) & wbs_dat_i[15]),
        .w_data({wbs_dat_i[7], wbs_dat_i[6], wbs_dat_i[1:0]}),
        .r_data(rx_fifo_r_data),
        .empty(rx_fifo_empty),
        .full(rx_fifo_full)
        );

    fifo #(.B(8), .W(8)) tx_fifo_inst(
        .clk(clk),
        .reset(rst),
        .rd(valid & wbs_ack_o & master_rden ),
        .wr(o_valid),
        .w_data({o_eof, o_bof, o_data}),
        .r_data(tx_fifo_r_data),
        .empty(tx_fifo_empty),
        .full(tx_fifo_full)
        );

    always @(posedge clk) begin
        if (rst) begin
            rx_fifo_rd_start = 0;
            tx_fifo_rd_start = 0;
            master_rden = 0;
            wbs_ack_o = 0;
        end
        else begin 
            if (valid & wbs_dat_i[15] & wbs_dat_i[7]) rx_fifo_rd_start <= 1;
            if (rx_fifo_empty) rx_fifo_rd_start <= 0;
            
            if (o_eof) tx_fifo_rd_start <= 1;
            if (tx_fifo_empty) tx_fifo_rd_start <= 0;

            if ((~wbs_dat_i[13]) & valid & (~wbs_ack_o)) master_rden <= 0;
            if (wbs_dat_i[13] & valid & (~wbs_ack_o)) master_rden <= 1;
            
            wbs_ack_o <= 0;
            if (valid & (~wbs_ack_o)) wbs_ack_o <= 1;

            case(param_sel)

                0:
                    begin
                    i_conf_blocksize <= 14;
                    i_conf_p  <= 9;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 11;
                    i_conf_q2 <= 51;
                    i_conf_q3 <= 19;
                    end

                1:
                    begin
                    i_conf_blocksize <= 38;
                    i_conf_p  <= 17;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 23;
                    i_conf_q2 <= 63;
                    i_conf_q3 <= 11;
                    end

                2:
                    begin
                    i_conf_blocksize <= 51;
                    i_conf_p  <= 23;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 23;
                    i_conf_q2 <= 107;
                    i_conf_q3 <= 107;
                    end

                3:
                    begin
                    i_conf_blocksize <= 55;
                    i_conf_p  <= 23;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 43;
                    i_conf_q2 <= 131;
                    i_conf_q3 <= 115;
                    end

                4:
                    begin
                    i_conf_blocksize <= 59;
                    i_conf_p  <= 23;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 11;
                    i_conf_q2 <= 23;
                    i_conf_q3 <= 219;
                    end

                5:
                    begin
                    i_conf_blocksize <= 62;
                    i_conf_p  <= 23;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 35;
                    i_conf_q2 <= 63;
                    i_conf_q3 <= 63;
                    end

                6:
                    begin
                    i_conf_blocksize <= 69;
                    i_conf_p  <= 25;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 7;
                    i_conf_q2 <= 111;
                    i_conf_q3 <= 103;
                    end

                7:
                    begin
                    i_conf_blocksize <= 84;
                    i_conf_p  <= 23;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 7;
                    i_conf_q2 <= 83;
                    i_conf_q3 <= 71;
                    end

                8:
                    begin
                    i_conf_blocksize <= 85;
                    i_conf_p  <= 23;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 55;
                    i_conf_q2 <= 255;
                    i_conf_q3 <= 215;
                    end

                9:
                    begin
                    i_conf_blocksize <= 93;
                    i_conf_p  <= 25;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 31;
                    i_conf_q2 <= 111;
                    i_conf_q3 <= 107;
                    end

                10:
                    begin
                    i_conf_blocksize <= 96;
                    i_conf_p  <= 25;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 11;
                    i_conf_q2 <= 103;
                    i_conf_q3 <= 107;
                    end

                11:
                    begin
                    i_conf_blocksize <= 100;
                    i_conf_p  <= 23;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 35;
                    i_conf_q2 <= 131;
                    i_conf_q3 <= 127;
                    end

                12:
                    begin
                    i_conf_blocksize <= 108;
                    i_conf_p  <= 29;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 19;
                    i_conf_q2 <= 123;
                    i_conf_q3 <= 123;
                    end

                13:
                    begin
                    i_conf_blocksize <= 115;
                    i_conf_p  <= 29;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 23;
                    i_conf_q2 <= 239;
                    i_conf_q3 <= 239;
                    end

                14:
                    begin
                    i_conf_blocksize <= 123;
                    i_conf_p  <= 31;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 15;
                    i_conf_q2 <= 7;
                    i_conf_q3 <= 3;
                    end

                15:
                    begin
                    i_conf_blocksize <= 128;
                    i_conf_p  <= 31;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 7;
                    i_conf_q2 <= 135;
                    i_conf_q3 <= 131;
                    end

                16:
                    begin
                    i_conf_blocksize <= 130;
                    i_conf_p  <= 31;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 7;
                    i_conf_q2 <= 11;
                    i_conf_q3 <= 3;
                    end

                17:
                    begin
                    i_conf_blocksize <= 144;
                    i_conf_p  <= 31;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 3;
                    i_conf_q2 <= 3;
                    i_conf_q3 <= 3;
                    end

                18:
                    begin
                    i_conf_blocksize <= 170;
                    i_conf_p  <= 33;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 63;
                    i_conf_q2 <= 523;
                    i_conf_q3 <= 515;
                    end

                19:
                    begin
                    i_conf_blocksize <= 175;
                    i_conf_p  <= 37;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 11;
                    i_conf_q2 <= 3;
                    i_conf_q3 <= 11;
                    end

                20:
                    begin
                    i_conf_blocksize <= 188;
                    i_conf_p  <= 37;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 15;
                    i_conf_q2 <= 167;
                    i_conf_q3 <= 159;
                    end

                21:
                    begin
                    i_conf_blocksize <= 192;
                    i_conf_p  <= 37;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 7;
                    i_conf_q2 <= 183;
                    i_conf_q3 <= 123;
                    end

                22:
                    begin
                    i_conf_blocksize <= 194;
                    i_conf_p  <= 39;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 3;
                    i_conf_q2 <= 319;
                    i_conf_q3 <= 319;
                    end

                23:
                    begin
                    i_conf_blocksize <= 256;
                    i_conf_p  <= 45;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 7;
                    i_conf_q2 <= 199;
                    i_conf_q3 <= 183;
                    end

                24:
                    begin
                    i_conf_blocksize <= 264;
                    i_conf_p  <= 43;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 3;
                    i_conf_q2 <= 27;
                    i_conf_q3 <= 11;
                    end

                25:
                    begin
                    i_conf_blocksize <= 298;
                    i_conf_p  <= 49;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 15;
                    i_conf_q2 <= 23;
                    i_conf_q3 <= 3;
                    end

                26:
                    begin
                    i_conf_blocksize <= 307;
                    i_conf_p  <= 49;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 27;
                    i_conf_q2 <= 3;
                    i_conf_q3 <= 7;
                    end

                27:
                    begin
                    i_conf_blocksize <= 333;
                    i_conf_p  <= 49;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 23;
                    i_conf_q2 <= 3;
                    i_conf_q3 <= 23;
                    end

                28:
                    begin
                    i_conf_blocksize <= 355;
                    i_conf_p  <= 53;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 19;
                    i_conf_q2 <= 239;
                    i_conf_q3 <= 223;
                    end

                29:
                    begin
                    i_conf_blocksize <= 400;
                    i_conf_p  <= 53;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 43;
                    i_conf_q2 <= 243;
                    i_conf_q3 <= 219;
                    end

                30:
                    begin
                    i_conf_blocksize <= 438;
                    i_conf_p  <= 59;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 7;
                    i_conf_q2 <= 247;
                    i_conf_q3 <= 243;
                    end

                31:
                    begin
                    i_conf_blocksize <= 444;
                    i_conf_p  <= 59;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 35;
                    i_conf_q2 <= 731;
                    i_conf_q3 <= 715;
                    end

                32:
                    begin
                    i_conf_blocksize <= 539;
                    i_conf_p  <= 65;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 15;
                    i_conf_q2 <= 31;
                    i_conf_q3 <= 3;
                    end

                33:
                    begin
                    i_conf_blocksize <= 59;
                    i_conf_p  <= 23;
                    i_conf_q0 <= 3;
                    i_conf_q1 <= 11;
                    i_conf_q2 <= 23;
                    i_conf_q3 <= 219;
                    end

                default:
                    begin
                    i_conf_blocksize <= 0;
                    i_conf_p  <= 0;
                    i_conf_q0 <= 0;
                    i_conf_q1 <= 0;
                    i_conf_q2 <= 0;
                    i_conf_q3 <= 0;
                    end
            endcase
        end
    end
endmodule

`default_nettype wire

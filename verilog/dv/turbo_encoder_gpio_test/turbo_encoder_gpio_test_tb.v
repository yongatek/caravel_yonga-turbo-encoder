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

`timescale 1 ns / 1 ps

`include "uprj_netlists.v"
`include "caravel_netlists.v"
`include "spiflash.v"

module turbo_encoder_gpio_test_tb;
	
	reg RSTB;
	reg CSB;
	reg clock = 0;
	reg power1, power2;
	reg power3, power4;

	wire gpio;
	wire [37:0] mprj_io;

	reg  [1:0] encoder_input [55:0];
	reg  [5:0] ref_encoder_out [55:0];

	integer i, j, mismatch_count = 0, dump_file;

	reg  test_start = 0;

	reg  rstn 		= 1;
	reg  i_bof		= 0;
	reg  i_eof		= 0;
	reg  i_valid 	= 0;
	reg  i_ready 	= 1;
	reg  [1:0] i_data;
	reg  [5:0] param_sel = 0;

	wire clk;
	wire o_bof;
	wire o_eof;
	wire o_valid;
	wire o_ready;
	wire [5:0] o_data;

	assign mprj_io[3] = (CSB == 1'b1) ? 1'b1 : 1'bz;

	assign mprj_io[8]		= rstn;
	assign mprj_io[9]		= i_bof;
	assign mprj_io[10]		= i_eof;
	assign mprj_io[11]		= i_valid;
	assign mprj_io[18]		= i_ready;
	assign mprj_io[14:13]	= i_data;
	assign mprj_io[30:25]	= param_sel;
	assign clk 				= mprj_io[31];
	assign o_bof	 		= mprj_io[15];
	assign o_eof	 		= mprj_io[16];
	assign o_valid	 		= mprj_io[17];
	assign o_ready	 		= mprj_io[12];
	assign o_data	 		= mprj_io[24:19];


	// External clock is used by default.  Make this artificially fast for the
	// simulation.  Normally this would be a slow clock and the digital PLL
	// would be the fast clock.

	always #12.5 clock = ~clock;

	initial begin
		$dumpfile("turbo_encoder_gpio_test.vcd");
		$dumpvars(0, turbo_encoder_gpio_test_tb);
		$readmemb("encoder_input.txt", encoder_input);
		$readmemb("ref_encoder_out.txt", ref_encoder_out);

		// Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (30) begin
			repeat (1000) @(posedge clock);
			// $display("+1000 cycles");
		end
		$display("%c[1;31m",27);
		`ifdef GL
			$display ("Monitor: Timeout, Turbo Encoder Test (GL) Failed");
		`else
			$display ("Monitor: Timeout, Turbo Encoder Test (RTL) Failed");
		`endif
		$display("%c[0m",27);
		$finish;
	end

	initial begin
		wait (mprj_io [37:32] == 6'b111111);
		test_start = 1;
		$display("Monitor: Turbo Encoder Test Started");
		rstn = 0;
		#100;
		rstn = 1;
		
		wait (~clk);
		wait (clk);

		i_valid = 1;

		for (i = 0; i < 56; i = i + 1) begin
			if (i == 0) i_bof = 1;
			else i_bof = 0;

			if (i == 55) i_eof = 1;
			else i_eof = 0;

			i_data = encoder_input[i];
			$display("Input Data = %b", encoder_input[i]);

			wait(~clk);
			wait(clk);
		end  

		i_valid = 0;
		i_eof = 0;

		wait(o_bof);
		wait(clk);

		for (i = 0; i < 56; i = i + 1) begin
			if (o_data != ref_encoder_out[i]) mismatch_count = mismatch_count + 1;
			$display("Output Data = %b, Reference Data = %b", o_data, ref_encoder_out[i]);

			wait(~clk);
			wait(clk);
		end  

		if(mismatch_count == 0) begin
			`ifdef GL
		    	$display("Monitor: Turbo Encoder Test (GL) Passed");
			`else
			    $display("Monitor: Turbo Encoder Test (RTL) Passed");
			`endif
		end
		else begin
			`ifdef GL
				$display ("Monitor: Mismatch, Turbo Encoder Test (GL) Failed");
			`else
				$display ("Monitor: Mismatch, Turbo Encoder Test (RTL) Failed");
			`endif
		end
	    $finish;
	end

	initial begin
		RSTB <= 1'b0;
		CSB  <= 1'b1;		// Force CSB high
		#2000;
		RSTB <= 1'b1;	    	// Release reset
		#170000;
		CSB = 1'b0;		// CSB can be released
	end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		power3 <= 1'b0;
		power4 <= 1'b0;
		#100;
		power1 <= 1'b1;
		#100;
		power2 <= 1'b1;
		#100;
		power3 <= 1'b1;
		#100;
		power4 <= 1'b1;
	end

	always @(mprj_io) begin
		#1 $display("MPRJ-IO state = %b ", mprj_io);
	end

	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	wire VDD3V3 = power1;
	wire VDD1V8 = power2;
	wire USER_VDD3V3 = power3;
	wire USER_VDD1V8 = power4;
	wire VSS = 1'b0;

	caravel uut (
		.vddio	  (VDD3V3),
		.vssio	  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (USER_VDD3V3),
		.vdda2    (USER_VDD3V3),
		.vssa1	  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (USER_VDD1V8),
		.vccd2	  (USER_VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock	  (clock),
		.gpio     (gpio),
        .mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("turbo_encoder_gpio_test.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);

endmodule
`default_nettype wire
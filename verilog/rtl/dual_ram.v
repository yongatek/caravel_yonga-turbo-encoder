`timescale 1ns / 1ps
module dual_ram
(
	input [1:0] dia, dib,
	input [11:0] addra, addrb,
	input wea, web, clk,
	output reg [1:0] doa, dob
);
	// Declare the RAM variable
	reg [1:0] ram[2395:0];
	
	// Port A
	always @ (posedge clk)
	begin
		if (wea) 
		begin
			ram[addra] <= dia;
			doa <= dia;
		end
		else 
		begin
			doa <= ram[addra];
		end
	end
	
	// Port B
	always @ (posedge clk)
	begin
		if (web)
		begin
			ram[addrb] <= dib;
			dob <= dib;
		end
		else
		begin
			dob <= ram[addrb];
		end
	end
	
endmodule

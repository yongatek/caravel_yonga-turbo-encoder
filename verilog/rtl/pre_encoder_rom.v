`timescale 1ns / 1ps
module pre_encoder_rom (
    i_S,
    i_nmod15_minus1,
    o_S_out
);
    input [3:0] i_S;
    input [3:0] i_nmod15_minus1;
    output reg [3:0] o_S_out;
    
	wire [7:0] addr;
	
	assign addr = {i_nmod15_minus1,i_S};  // multiply by 16 and add current state  //changed non-blocking assignment to blocking assignment
	
	always @(*)
	begin
		
		case (addr)
			0: o_S_out = 0;
			1: o_S_out = 14;
			2: o_S_out = 3;
			3: o_S_out = 13;
			4: o_S_out = 7;
			5: o_S_out = 9;
			6: o_S_out = 4;
			7: o_S_out = 10;
			8: o_S_out = 15;
			9: o_S_out = 1;
			10: o_S_out = 12;
			11: o_S_out = 2;
			12: o_S_out = 8;
			13: o_S_out = 6;
			14: o_S_out = 11;
			15: o_S_out = 5;

			16: o_S_out = 0;
			17: o_S_out = 11;
			18: o_S_out = 13;
			19: o_S_out = 6;
			20: o_S_out = 10;
			21: o_S_out = 1;
			22: o_S_out = 7;
			23: o_S_out = 12;
			24: o_S_out = 5;
			25: o_S_out = 14;
			26: o_S_out = 8;
			27: o_S_out = 3;
			28: o_S_out = 15;
			29: o_S_out = 4;
			30: o_S_out = 2;
			31: o_S_out = 9;

			32: o_S_out = 0;
			33: o_S_out = 8;
			34: o_S_out = 9;
			35: o_S_out = 1;
			36: o_S_out = 2;
			37: o_S_out = 10;
			38: o_S_out = 11;
			39: o_S_out = 3;
			40: o_S_out = 4;
			41: o_S_out = 12;
			42: o_S_out = 13;
			43: o_S_out = 5;
			44: o_S_out = 6;
			45: o_S_out = 14;
			46: o_S_out = 15;
			47: o_S_out = 7;

			48: o_S_out = 0;
			49: o_S_out = 3;
			50: o_S_out = 4;
			51: o_S_out = 7;
			52: o_S_out = 8;
			53: o_S_out =11;
			54: o_S_out = 12;
			55: o_S_out = 15;
			56: o_S_out = 1;
			57: o_S_out = 2;
			58: o_S_out = 5;
			59: o_S_out = 6;
			60: o_S_out = 9;
			61: o_S_out = 10;
			62: o_S_out = 13;
			63: o_S_out = 14;

			64: o_S_out = 0;
			65: o_S_out = 12;
			66: o_S_out = 5;
			67: o_S_out = 9;
			68: o_S_out = 11;
			69: o_S_out = 7;
			70: o_S_out = 14;
			71: o_S_out = 2;
			72: o_S_out = 6;
			73: o_S_out = 10;
			74: o_S_out = 3;
			75: o_S_out = 15;
			76: o_S_out = 13;
			77: o_S_out = 1;
			78: o_S_out = 8;
			79: o_S_out = 4;

			80: o_S_out = 0;
			81: o_S_out = 4; 
			82: o_S_out = 12;
			83: o_S_out = 8;
			84: o_S_out = 9;
			85: o_S_out = 13;
			86: o_S_out = 5;
			87: o_S_out = 1;
			88: o_S_out = 2;
			89: o_S_out = 6;
			90: o_S_out = 14;
			91: o_S_out = 10;
			92: o_S_out = 11;
			93: o_S_out = 15;
			94: o_S_out = 7;
			95: o_S_out = 3;

			96: o_S_out = 0;
			97: o_S_out = 6;
			98: o_S_out = 10;
			99: o_S_out = 12;
			100: o_S_out = 5;
			101: o_S_out = 3;
			102: o_S_out = 15;
			103: o_S_out = 9;
			104: o_S_out = 11;
			105: o_S_out = 13;
			106: o_S_out = 1;
			107: o_S_out = 7;
			108: o_S_out = 14;
			109: o_S_out = 8;
			110: o_S_out = 4;
			111: o_S_out = 2;

			112: o_S_out = 0;
			113: o_S_out = 7;
			114: o_S_out = 8;
			115: o_S_out = 15;
			116: o_S_out = 1;
			117: o_S_out = 6;
			118: o_S_out = 9;
			119: o_S_out = 14;
			120: o_S_out = 3;
			121: o_S_out = 4;
			122: o_S_out = 11;
			123: o_S_out = 12;
			124: o_S_out = 2;
			125: o_S_out = 5;
			126: o_S_out = 10;
			127: o_S_out = 13;

			128: o_S_out = 0;
			129: o_S_out = 5;
			130: o_S_out = 14;
			131: o_S_out = 11;
			132: o_S_out = 13;
			133: o_S_out = 8;
			134: o_S_out = 3;
			135: o_S_out = 6;
			136: o_S_out = 10;
			137: o_S_out = 15;
			138: o_S_out = 4;
			139: o_S_out = 1;
			140: o_S_out = 7;
			141: o_S_out = 2;
			142: o_S_out = 9;
			143: o_S_out = 12;

			144: o_S_out = 0;
			145: o_S_out = 13;
			146: o_S_out = 7;
			147: o_S_out = 10;
			148: o_S_out = 15;
			149: o_S_out = 2;
			150: o_S_out = 8;
			151: o_S_out = 5;
			152: o_S_out = 14;
			153: o_S_out = 3;
			154: o_S_out = 9;
			155: o_S_out = 4;
			156: o_S_out = 1;
			157: o_S_out = 12;
			158: o_S_out = 6;
			159: o_S_out = 11;

			160: o_S_out = 0;
			161: o_S_out = 2;
			162: o_S_out = 6;
			163: o_S_out = 4;
			164: o_S_out = 12;
			165: o_S_out = 14;
			166: o_S_out = 10;
			167: o_S_out = 8;
			168: o_S_out = 9;
			169: o_S_out = 11;
			170: o_S_out = 15;
			171: o_S_out = 13;
			172: o_S_out = 5;
			173: o_S_out = 7;
			174: o_S_out = 3;
			175: o_S_out = 1;

			176: o_S_out = 0;
			177: o_S_out = 9;
			178: o_S_out = 11;
			179: o_S_out = 2;
			180: o_S_out = 6;
			181: o_S_out = 15;
			182: o_S_out = 13;
			183: o_S_out = 4;
			184: o_S_out = 12;
			185: o_S_out = 5;
			186: o_S_out = 7;
			187: o_S_out = 14;
			188: o_S_out = 10;
			189: o_S_out = 3;
			190: o_S_out = 1;
			191: o_S_out = 8;

			192: o_S_out = 0;
			193: o_S_out = 10;
			194: o_S_out = 15;
			195: o_S_out = 5;
			196: o_S_out = 14;
			197: o_S_out = 4;
			198: o_S_out = 1;
			199: o_S_out = 11;
			200: o_S_out = 13;
			201: o_S_out = 7;
			202: o_S_out = 2;
			203: o_S_out = 8;
			204: o_S_out = 3;
			205: o_S_out = 9;
			206: o_S_out = 12;
			207: o_S_out = 6;

			208: o_S_out = 0;
			209: o_S_out = 15;
			210: o_S_out = 1;
			211: o_S_out = 14;
			212: o_S_out = 3;
			213: o_S_out = 12;
			214: o_S_out = 2;
			215: o_S_out = 13;
			216: o_S_out = 7;
			217: o_S_out = 8;
			218: o_S_out = 6;
			219: o_S_out = 9;
			220: o_S_out = 4;
			221: o_S_out = 11;
			222: o_S_out = 5;
			223: o_S_out = 10;
			default: o_S_out = 0;
			endcase
	end
endmodule
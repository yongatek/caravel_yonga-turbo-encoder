`timescale 1ns / 1ps
module turbo_encoder_top (
	//inputs
	i_clk,
	i_rstn,
	i_bof,
	i_eof,
	i_valid,
	i_data,
	i_ready,
	//outputs
	o_ready,
	o_valid,
	o_bof,
	o_eof,
	o_data,
	//
	
	i_conf_blocksize,
	i_conf_p,
	i_conf_q0,
	i_conf_q1,
	i_conf_q2,
	i_conf_q3
);

parameter  MAX_BLOCK_WIDTH	  = 10,
					 P_WIDTH                           = 10,
					 MAX_DATA_WIDTH       =  MAX_BLOCK_WIDTH+2;

input i_clk;
input i_rstn;
input i_bof;
input i_eof;
input i_valid;
input[1:0] i_data;
input i_ready;

output reg o_ready;
output o_valid;
output o_bof;
output reg o_eof;
output[5:0]o_data;

input[MAX_BLOCK_WIDTH-1:0]	i_conf_blocksize;
input[P_WIDTH-1:0] 						i_conf_p;
input[MAX_DATA_WIDTH-1:0]	i_conf_q0;
input[MAX_DATA_WIDTH-1:0]	i_conf_q1;
input[MAX_DATA_WIDTH-1:0]	i_conf_q2;
input[MAX_DATA_WIDTH-1:0]	i_conf_q3;

// AGU_0 Signals
wire[MAX_DATA_WIDTH-1:0] agu_ib_adx_ab;
wire[1:0] 										agu_data_ab;
wire 											agu_buf_wr;
reg 												start;
wire[MAX_DATA_WIDTH-1:0] agu_ea;
wire[MAX_DATA_WIDTH-1:0] agu_ea_gen;
wire 											read_done;
reg[1:0] 										agu_data_ab_d;
reg 												start_d1;
reg 												start_d2;
reg 												start_d3;
reg 												start_d4;
reg 												start_d5;
reg 												valid_select;

// AGU_1 Signals
wire[MAX_DATA_WIDTH-1:0] agu_int_ib_adx_ab;
wire[1:0] 										agu_int_data_ab;
reg[1:0]  										agu_int_data_ab_d;
wire 											agu_int_buf_wr;
reg[1:0] 										ib_data;

// RAM_0 Signals
reg 												wea_AB;
reg[MAX_DATA_WIDTH-1:0]   addra;
wire[1:0] 										dob_ram0_AB_0;

// RAM_1 Signals
wire[1:0] dob_ram1_AB_0;

// pre encoder signals
reg pre_enc_valid;
reg pre_enc_ena;
reg pre_enc_load_si;
wire[3:0] o_s;
wire[3:0] o_s_int;

// encoder signals
reg enc_ena;
reg enc_load_si;
wire o_a;
wire o_b;
wire o_y1;
wire o_w1;
wire o_y2;
wire o_w2;

//delay registers
reg read_done_d;
reg read_done_dd;


reg [2:0]state;  // state machine 
        parameter 
                         idle = 3'b000, 
						 write_input_buffer_state = 3'b001, 
						 pre_encode_state = 3'b010, 
						 ready_wait_state = 3'b011, 
						 si_load_state = 3'b100, 
						 encode_state = 3'b101,
						 encode_state_end = 3'b110;
						 


assign agu_ea_gen = {i_conf_blocksize,2'b00};
assign agu_ea = agu_ea_gen - 1;

dual_ram  inst_input_ram_0(
	//port a (read/write)
	.clk(i_clk),
	.wea(wea_AB),
	.addra(addra),
	.dia(ib_data),
	.doa(),
	//port b (read/write)
	.web(0),
	.addrb(agu_ib_adx_ab),
	.dib(0),
	.dob(dob_ram0_AB_0)
);


dual_ram  inst_input_ram_1(
	//port a (read/write)
	.clk(i_clk),
	.wea(wea_AB),
	.addra(addra),
	.dia(ib_data),
	.doa(),
	//port b (read/write)
	.web(0),
	.addrb(agu_int_ib_adx_ab),
	.dib(0),
	.dob(dob_ram1_AB_0)
);

turbo_enc_agu  inst_agu_0(
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	.i_block_size(i_conf_blocksize),
	.i_mode(0),
	.i_ea(agu_ea),
	.i_p0(i_conf_p),
	.i_q0(i_conf_q0),
	.i_q1(i_conf_q1),
	.i_q2(i_conf_q2),
	.i_q3(i_conf_q3),
	.i_start(start),
	.i_ib_data_ab(dob_ram0_AB_0),
	.o_ib_adx_ab(agu_ib_adx_ab),
	.o_siso_data_ab(agu_data_ab),
	.o_siso_buf_wr(agu_buf_wr),
	.o_read_done(read_done)
);

turbo_enc_agu  inst_agu_1(
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	.i_block_size(i_conf_blocksize),
	.i_mode(1),
	.i_ea(agu_ea),
	.i_p0(i_conf_p),
	.i_q0(i_conf_q0),
	.i_q1(i_conf_q1),
	.i_q2(i_conf_q2),
	.i_q3(i_conf_q3),
	.i_start(start),
	.i_ib_data_ab(dob_ram1_AB_0),
	.o_ib_adx_ab(agu_int_ib_adx_ab),
	.o_siso_data_ab(agu_int_data_ab),
	.o_siso_buf_wr(agu_int_buf_wr),
	.o_read_done()
);

pre_encoder  inst_pre_encoder_0(
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	.i_valid(agu_buf_wr),
	.i_ena(pre_enc_ena),
	.i_load_si(pre_enc_load_si),
	.i_a(agu_data_ab_d[1]),
	.i_b(agu_data_ab_d[0]),
	.i_conf_blocksize(i_conf_blocksize),

	.o_s(o_s)
);

pre_encoder  inst_pre_encoder_1(
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	.i_valid(agu_int_buf_wr),
	.i_ena(pre_enc_ena),
	.i_load_si(pre_enc_load_si),
	.i_a(agu_int_data_ab_d[1]),
	.i_b(agu_int_data_ab_d[0]),
	.i_conf_blocksize(i_conf_blocksize),

	.o_s(o_s_int)
);

encoder_core  inst_encoder_core_0(
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	.i_valid(agu_buf_wr),
	.i_ena(enc_ena),
	.i_load_si(enc_load_si),
	.i_a(agu_data_ab_d[1]),
	.i_b(agu_data_ab_d[0]),
	.i_si(o_s),
	
	.o_a(o_a),
	.o_b(o_b),
	.o_y(o_y1),
	.o_w(o_w1),
	.o_so()
);

encoder_core  inst_encoder_core_1(
	.i_clk(i_clk),
	.i_rstn(i_rstn),
	.i_valid(agu_buf_wr),
	.i_ena(enc_ena),
	.i_load_si(enc_load_si),
	.i_a(agu_int_data_ab_d[1]),
	.i_b(agu_int_data_ab_d[0]),
	.i_si(o_s_int),
	
	.o_a(),
	.o_b(),
	.o_y(o_y2),
	.o_w(o_w2),
	.o_so()
);

always @(posedge i_clk)   //state machine
begin
	if (i_rstn == 0) 
	begin
		state <= idle;
		pre_enc_load_si <= 0;
		enc_load_si <= 0;
		start <= 0;
		o_eof <= 0;
		o_ready <= 1;
		read_done_d   <= 0;
		read_done_dd  <= 0;
	    addra <= 0;
		ib_data <= 0;
		pre_enc_ena <= 0;
		enc_ena <= 0;
		agu_data_ab_d <= 0;
		start_d1 <= 0;
		start_d2 <= 0;
		start_d3 <= 0;
		start_d4 <= 0;
		start_d5 <= 0;
		valid_select <= 0;
	end
	
	else
	 begin
		read_done_d <= read_done;
		read_done_dd <= read_done_d;
	  //read_done_ddd <= read_done_dd;
		agu_data_ab_d <= agu_data_ab;
		agu_int_data_ab_d <= agu_int_data_ab;
		start_d1 <= start;
		start_d2 <= start_d1;
		start_d3 <= start_d2;
		start_d4 <= start_d3;
		start_d5 <= start_d4;
	
	
		case (state)
			idle:  ////
			begin
				addra <= 0;
				wea_AB <= 0;
				pre_enc_load_si <= 0;
				pre_enc_valid <= 0;
				enc_load_si <= 0;
				start <= 0;
				o_eof <= 0;
				o_ready <= 1;
				ib_data <= 0;
				pre_enc_ena <= 0;
				enc_ena <= 0;
				valid_select <= 0;
				
				if (i_bof == 1 && i_valid == 1) begin
					wea_AB <= 1;
					ib_data <= i_data;
					state     <= write_input_buffer_state;
				end
				end
			write_input_buffer_state: ////
			begin
				valid_select <= 0;
				
				if (i_valid == 1) begin
					wea_AB <= 1;
					addra <= addra + 1;
					ib_data <= i_data;
					
					if (i_eof == 1) begin
						state        <= pre_encode_state;
						o_ready <= 0;
						pre_enc_load_si <= 1;
						pre_enc_ena <= 1;
						start <= 1;		
					end
				end
				
				else 
					wea_AB <= 0;
				end	
			pre_encode_state: ////
			begin
				wea_AB <= 0;
				pre_enc_load_si <= 1'b0;
				start <= 0;
					
				if (read_done_dd == 1) begin
					if(i_ready == 1)
						state <= si_load_state;
					else
						state <= ready_wait_state;
				end
				end
			ready_wait_state: ////
			begin
				if (i_ready == 1)
					state <= si_load_state;
				end
			si_load_state: ////
			begin
				valid_select <= 1;
				state <= encode_state;
				pre_enc_ena <= 0;
				enc_load_si <= 1;
				enc_ena <= 1;
				start <= 1;
				end
			encode_state: ////
			begin
				enc_load_si <= 0;
				start <= 0;
				if (read_done == 1) begin
					o_eof <= 1;
					state <= encode_state_end;
				end
				end
			encode_state_end: ////
			begin
				o_eof <= 0;
				state <= idle;
				end
				
			default:
				begin
				state <= idle;
				end 
				
		endcase
	end
end

assign o_bof = start_d4 & valid_select;
assign o_valid = agu_buf_wr & valid_select;
assign o_data = {o_a , o_b , o_y1 , o_w1 , o_y2 , o_w2};

endmodule	
			
		
		
		
	
						 
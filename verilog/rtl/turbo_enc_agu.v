`timescale 1ns / 1ps
module turbo_enc_agu (
    //inputs
    i_clk,         
    i_rstn,        
    i_block_size,  
    i_mode,        
    i_ea,          
    i_p0,         
    i_q0,          
    i_q1,          
    i_q2,          
    i_q3,          
    i_start,       
    i_ib_data_ab,  
    //outputs
    o_ib_adx_ab,   
    o_siso_data_ab,
    o_siso_buf_wr, 
    o_read_done   
);
	parameter  MAX_BLOCK_WIDTH	  = 10,
					 P_WIDTH                           = 10,
					 MAX_DATA_WIDTH       =  MAX_BLOCK_WIDTH + 2;
					 
					 
    input                       						  i_clk;
    input                      						  i_rstn;
    input[MAX_BLOCK_WIDTH-1:0]  i_block_size;
    input                                              i_mode;
    input[MAX_DATA_WIDTH-1:0]   i_ea;
    input[P_WIDTH-1:0]                      i_p0;
    input[MAX_DATA_WIDTH-1:0]   i_q0;
    input[MAX_DATA_WIDTH-1:0]   i_q1;
    input[MAX_DATA_WIDTH-1:0]   i_q2;
    input[MAX_DATA_WIDTH-1:0]   i_q3;
    input                                              i_start;
    input[1:0]                  					  i_ib_data_ab;
    

    output[MAX_DATA_WIDTH-1:0]   o_ib_adx_ab;
    output[1:0]                 					    o_siso_data_ab;
    output reg                      					o_siso_buf_wr;
    output                      						o_read_done;

    reg addr_state;  // state machine for addr_states
        parameter wait_start = 0, addr_generate = 1;
	reg mode;
	reg[MAX_DATA_WIDTH-1:0] lin_adx;
	reg[MAX_DATA_WIDTH-1:0] lin_adx_d;
	
	reg[MAX_DATA_WIDTH-1:0] pi_d;
	reg[MAX_DATA_WIDTH-1:0] lambda_d;
	reg toggle_d;
	reg valid;
	reg valid_d;
	reg read_done;
	reg read_done_d;
	
	
	wire[MAX_DATA_WIDTH-1:0] n;
	wire[MAX_DATA_WIDTH-1:0] q0_d;
	wire[MAX_DATA_WIDTH-1:0] q1_d;
	wire[MAX_DATA_WIDTH-1:0] q2_d;
	wire[MAX_DATA_WIDTH-1:0] q3_d;
	reg[MAX_DATA_WIDTH-1:0] q_mux;
	wire[MAX_DATA_WIDTH-1:0] lambda;
	wire[MAX_DATA_WIDTH-1:0] pi;
	wire[(MAX_DATA_WIDTH+1)-1:0] lambda_mod_1;
	wire signed[(MAX_DATA_WIDTH+1)-1:0] lambda_mod_2;
	wire[(MAX_DATA_WIDTH+1)-1:0] pi_mod_1;
	wire signed[(MAX_DATA_WIDTH+1)-1:0] pi_mod_2;
	wire siso_buf_wr;
    
	assign q0_d = i_q0;
	assign q1_d = i_q1;
	assign q2_d = i_q2;
	assign q3_d = i_q3;
	
	always @(posedge i_clk) //address_generation_process
	begin
		if(i_rstn == 0) begin
			addr_state  <= wait_start;
            mode        <= 0;
            lin_adx     <= 0;
            lin_adx_d   <= 0;
            lambda_d    <= 0;
            pi_d        <= 0;
            valid       <= 0;
            read_done   <= 0;
		end
		
		else begin
        case(addr_state)
            wait_start:
            begin
                valid <= 0;
                read_done <= 0;
                if (i_start == 1) begin
                    mode <= i_mode;
                    lin_adx <= 0;
                    lambda_d <= 0;
                    addr_state <= addr_generate;	
                end	
            end
            addr_generate:
            begin
                valid <= 1;
                lin_adx <= lin_adx + 1;
                lin_adx_d <= lin_adx;
                lambda_d <= lambda;
                pi_d <= pi;
                if (lin_adx == i_ea) begin
                    read_done <= 1;
                    addr_state <= wait_start;
                end
            end
        endcase
		
		end
	end
	
	assign siso_buf_wr = valid_d;
	
	always @(posedge i_clk) // siso_buffer_write_process
	begin
		if (i_rstn == 0) begin
			valid_d <= 0;
			toggle_d <= 0;
			read_done_d <= 0;
		end
		
		else begin
            valid_d <= valid;
            if (mode == 1)begin
               toggle_d <= ~pi_d[0];
            end
            else begin
               toggle_d <= 0;
            end    
            
            read_done_d <= read_done;
        end
    end
	
	assign n = {i_block_size,2'b00};
	
	// ACC Unit 1
	assign lambda_mod_1 = {1'b0,lambda_d} + i_p0;
	assign lambda_mod_2 = lambda_mod_1 - {1'b0,n};
	assign lambda = (lambda_mod_2[MAX_DATA_WIDTH]) ? lambda_mod_1[MAX_DATA_WIDTH-1:0] : lambda_mod_2[MAX_DATA_WIDTH-1:0];
    
    // ACC Unit 2
	always@(*)
	begin
	case (lin_adx[1:0])
		  1:      		 q_mux = q1_d;
		  2: 			 q_mux = q2_d;
		  3: 			 q_mux = q3_d;
		  default:       q_mux = q0_d;
	endcase
	end
	
	assign pi_mod_1 = {1'b0,lambda_d} + {1'b0,q_mux};
	assign pi_mod_2 = pi_mod_1 - {1'b0,n};
	assign pi = (pi_mod_2[MAX_DATA_WIDTH]) ? pi_mod_1[MAX_DATA_WIDTH-1:0] : pi_mod_2[MAX_DATA_WIDTH-1:0];
	
	// read data from input buffer
	assign o_ib_adx_ab = (mode) ? pi_d : lin_adx_d;  
	
	
	// send data to encoder
	assign o_siso_data_ab = (toggle_d) ? {i_ib_data_ab[0],i_ib_data_ab[1]} : i_ib_data_ab;
	
	
	always @(posedge i_clk)
	begin
		if (i_rstn == 0)
			o_siso_buf_wr <= 0;
		else
			o_siso_buf_wr <= siso_buf_wr;
				
	end
	
	// Send feedback to controller
	
	assign o_read_done = read_done_d;

endmodule	
	
	
	
		  
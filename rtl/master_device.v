module master_device (
	input i_clk,
	input i_rst, // Active HIGH reset.
	input i_enable,
	input [6:0] i_address,
	input 		i_rw,
	input [7:0] i_data,
	
	output reg o_busy,
	
	inout io_scl,
	inout io_sda
	
	
	);
	
	localparam CLK_DIV = 4;
	
	localparam IDLE = 0;
	localparam START = 1;
	localparam SEND_ADDRESS = 2;
	localparam READ_ACK1 = 3;
	localparam WRITE_DATA = 4;
	localparam READ_DATA = 5;
	localparam READ_ACK2 = 6;
	localparam SEND_ACK2 = 7;
	localparam STOP = 8;
	
	reg [7:0] r_counter;
	reg [7:0] r_clk_div_counter = 0;
	reg r_sda_write_enable;
	reg r_scl_enable;
	reg r_scl = 0;
	reg r_sda_out = 1;
	reg [7:0] r_state;
	reg [7:0] r_address_frame;
	
	assign io_scl = (r_scl_enable) ? r_scl : 1;
	assign io_sda = (r_sda_write_enable) ? r_sda_out : 1'bz;
	
	always @(posedge i_clk) begin
		if (r_clk_div_counter == (CLK_DIV/2) - 1) begin
			r_scl <= ~r_scl;
			r_clk_div_counter <= 0;
		end
		else r_clk_div_counter <= r_clk_div_counter + 1;
	end
	
	always @(posedge r_scl or posedge i_rst) begin
		if (i_rst) begin
			r_state <= IDLE;
			r_sda_write_enable <= 0; 
			r_scl_enable <= 0;
			o_busy <= 0;
		end
		else begin
			case (r_state)
				IDLE: begin
					if (i_enable) begin
						r_sda_write_enable <= 1;
						r_state <= START;
						o_busy <= 1;
					end
					else r_state <= IDLE;
				end
			
				START: begin
					r_scl_enable <= 1;
					r_address_frame <= {i_address, i_rw};
					r_counter <= 7;
					r_state <= SEND_ADDRESS;
				end
				
				SEND_ADDRESS: begin
					r_counter <= r_counter - 1;
					if (r_counter == 0) begin
						r_state <= READ_ACK1;
					end
				end
				
				READ_ACK1: begin
					// ACK success.
					if (io_sda == 0) begin
						if (r_address_frame[0] == 0) begin
							r_counter <= 7;
							r_state <= WRITE_DATA;
						end
						else if (r_address_frame[0] == 1) begin
						
							r_state <= READ_DATA;
						
						end
					end
					// ACK failure.
					else begin
						r_state <= STOP;
					end
				end
				
				WRITE_DATA: begin
					r_counter <= r_counter - 1;
					if (r_counter == 0) begin
						r_state <= READ_ACK2;
					end
				end
				
				READ_ACK2: begin
					// ACK success.
					if (io_sda == 0) begin
						r_state <= STOP;
					end
					// ACK failure.
					else begin
						r_state <= STOP;
					end
				end
				
				STOP: begin
					r_state <= IDLE;
				end
				
			endcase
		end
	end
	
	always @(negedge r_scl or posedge i_rst) begin
		if (i_rst) begin
			r_state <= IDLE;
			r_sda_write_enable <= 0;
			r_scl_enable <= 0;
		end
		else begin
			case (r_state)
				START: begin
					r_sda_out <= 0;
				end
				
				SEND_ADDRESS: begin
					r_sda_out <= r_address_frame[r_counter];
				end
				
				READ_ACK1: begin
					r_sda_write_enable <= 0;
				end
				
				WRITE_DATA: begin
					r_sda_write_enable <= 1;
					r_sda_out <= i_data[r_counter];
				end
				
				READ_ACK2: begin
					r_sda_write_enable <= 0;
				end
				
				STOP: begin
					r_sda_write_enable <= 0;
					r_scl_enable <= 0;
					o_busy <= 0;
				end
				
			endcase
		end
	end
	
	
	
	
endmodule
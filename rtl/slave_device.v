module slave_device (
	input i_scl,
	inout io_sda
	
	);
	
	localparam LOCAL_ADDRESS = 7'b1100110;
	
	localparam READ_ADDRESS = 0;
	localparam SEND_ADDRESS_ACK = 1;
	localparam READ_DATA = 2;
	localparam WRITE_DATA = 3;
	localparam SEND_DATA_ACK = 4;
	localparam READ_DATA_ACK = 5;
	
	
	reg [7:0] r_address_frame;
	reg [7:0] r_data_buffer;
	reg [7:0] r_counter;
	reg [7:0] r_state;
	reg r_busy = 0;
	reg r_sda_write_enable = 0;
	reg r_address_hit = 0;
	reg r_sda_out;
	
	assign io_sda = (r_sda_write_enable) ? r_sda_out : 1'bz;
	
	// START condition
	always @(negedge io_sda) begin
		if (r_busy == 0 && i_scl == 1) begin
			r_busy <= 1;
			r_counter <= 8;
			r_state <= READ_ADDRESS;
			r_address_hit <= 0;
		end
	end
	
	// STOP condition
	always @(posedge io_sda) begin
		if (r_busy == 1 && i_scl == 1) begin
			r_busy <= 0;
			r_state <= READ_ADDRESS;
		end
	end
	
	always @(posedge i_scl) begin
		case (r_state)
			READ_ADDRESS: begin
				r_sda_write_enable <= 0;
				if (r_busy) begin
					r_address_frame[r_counter] <= io_sda;
					if (r_counter == 0) begin
						r_state <= SEND_ADDRESS_ACK;
					end
				end
			end
			
			SEND_ADDRESS_ACK: begin
				if (r_address_hit) begin
					if (r_address_frame[0] == 0) begin
						r_counter <= 8;
						r_state <= READ_DATA;
					end
					// MRSR
					else if (r_address_frame[0] == 1) begin
						r_state <= WRITE_DATA;
					end
				end
				else r_state <= READ_ADDRESS;
			end
			
			READ_DATA: begin
				r_data_buffer[r_counter] <= io_sda;
				if (r_counter == 0) begin
					r_state <= SEND_DATA_ACK;
				end
			end
			
			SEND_DATA_ACK: begin
				r_state <= READ_ADDRESS;
			end
			
		endcase
	end
	
	always @(negedge i_scl) begin
		case (r_state)
			READ_ADDRESS: begin
				if (r_busy) begin
					r_counter <= r_counter - 1;
				end
			end
			
			SEND_ADDRESS_ACK: begin
				if (r_address_frame[7:1] == LOCAL_ADDRESS) begin
					r_sda_write_enable <= 1;
					r_sda_out <= 0;
					r_address_hit <= 1;
				end
			end
				
			READ_DATA: begin
				r_sda_write_enable <= 0;
				r_counter <= r_counter - 1;
			end
			
			SEND_DATA_ACK: begin
				r_sda_write_enable <= 1;
				// If it contains Z or X, send NACK
				if (^r_data_buffer === 1'bx) begin
					r_sda_out <= 1;
				end
				// Else, send ACK
				else begin
					r_sda_out <= 0;
				end
			end
	
		endcase
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
endmodule
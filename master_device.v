module master_device (
	input clk,
	input enable,
	input rst,
	input [6:0] address_in,
	input rw,
	input [7:0] data_in,
	
	inout scl,
	inout sda
	);
	
	localparam IDLE = 0;
	localparam START = 1;
	localparam SEND_ADDRESS = 2;
	localparam READ_ACK1 = 3;
	localparam WRITE_DATA = 4;
	localparam READ_DATA = 5;
	localparam STOP = 8;
	
	reg [7:0] counter;
	reg [7:0] state;
	reg [7:0] address_frame;
	reg [7:0] data_buffer; // data from peripheral.
	reg scl_enable;
	reg sda_write_enable;
	reg scl_reg;
	reg sda_out;
	
	assign scl = (scl_enable) ? scl_reg : 1;
	assign sda = (sda_write_enable) ? sda_out : 'bz;
	
	
	always @(posedge clk) begin
		scl_reg <= ~scl_reg;
	end
	
	always @(posedge rst) begin
		sda_write_enable <= 1;
		sda_out <= 1;
		scl_reg <= 0;
		scl_enable <= 0;
		state <= IDLE;
	end
	
	always @(posedge scl_reg) begin
		
		case (state)
			IDLE: begin
				if (enable) begin
					state <= START;
				end
			end
		
			START: begin
				address_frame <= {address_in, rw};
				counter <= 7;
				sda_write_enable <= 1;
				state <= SEND_ADDRESS;
			end
			
			SEND_ADDRESS: begin
				//$monitor("counter: %d", counter);
				counter <= counter - 1;
				if (counter == 0) begin
					
					state <= READ_ACK1;
				end
			end
			
			READ_ACK1: begin
				if (sda == 0) begin // ACK
					if (rw == 0) begin
						
						counter <= 7;
						state <= WRITE_DATA;
					end else if (rw == 1) begin
						
						counter <= 8;
						state <= READ_DATA;
					end
						
				
				end else // NACK
					state <= STOP;
				
			end
			
			READ_DATA: begin
				data_buffer[counter] <= sda; 
				if (counter == 0) begin
					state <= STOP;
				end
			end
		
		endcase 
	
	
	end
	
	always @(negedge scl_reg) begin
	
		case (state)
			IDLE: begin
				
			end
			
			START: begin
				sda_out <= 0;
				
			end
			
			SEND_ADDRESS: begin
				scl_enable <= 1;
				sda_out <= address_frame[counter];
				
			end
			
			READ_ACK1: begin
				sda_write_enable <= 0;
			end
			
			READ_DATA: begin
				counter <= counter - 1;
			end
			
			WRITE_DATA: begin
				
			end
			
			
			
			STOP: begin
				sda_out <= 1;
				scl_enable <= 0;
			end
		
		endcase
	
	end
	
	
	
endmodule
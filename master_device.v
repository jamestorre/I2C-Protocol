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
	localparam READ_ACK2 = 6;
	
	localparam CLK_DIV = 4;
	
	reg [7:0] state = IDLE;
	reg [7:0] counter;
	reg [7:0] counter_clk_div = 0;
	reg [7:0] address_frame;
	reg sda_out;
	reg scl_reg = 0;
	reg scl_enable = 0;
	reg sda_write_enable = 0;
	
	assign sda = (sda_write_enable) ? sda_out : 'bz;
	assign scl = (scl_enable) ? scl_reg : 1;
	
	always @(posedge clk) begin
		counter_clk_div <= counter_clk_div + 1;
		if (counter_clk_div == CLK_DIV/2 - 1) begin
			counter_clk_div <= 0;
			scl_reg <= ~scl_reg;
		end
		
	end
	
	always @(posedge rst) begin
		sda_write_enable <= 1;
		sda_out <= 1;
		scl_enable <= 0;
		state <= IDLE;
	end
	
	
	always @(posedge scl_reg) begin
		case (state)
			IDLE: begin
				if (enable) 
					state <= START;
			end
			
			START: begin
				
				
				
				state <= SEND_ADDRESS;
			end
			
			SEND_ADDRESS: begin
				counter <= counter - 1;
				if(counter == 0) begin
					state <= READ_ACK1;
				end
			end
			
			READ_ACK1: begin
				
				if (sda == 0) begin
					if (rw == 0) begin
						counter <= 7;
						state <= WRITE_DATA;
					end
				end
			
			end
			
			WRITE_DATA: begin
				counter = counter - 1;
				if (counter == 0) begin
					state <= READ_ACK2;
				end
			end
			
			
		endcase
	end
	
	always @(negedge scl_reg) begin
		
		case (state)
			
			
			START: begin
				sda_out <= 0;
				counter <= 7;
				address_frame <= {address_in,rw};
				
			end
			
			SEND_ADDRESS: begin
				scl_enable <= 1;
				sda_out <= address_frame[counter];
				
				
			end
			
			READ_ACK1: begin
				sda_write_enable <= 0;
				
			
			end
			
			WRITE_DATA: begin
				sda_write_enable <= 1;
				sda_out <= data_in[counter];
				
				
			end
			
		endcase
			
		
		
		
		
		
		
	end
	
	
endmodule
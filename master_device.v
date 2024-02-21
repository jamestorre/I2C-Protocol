module master_device(
	input wire clk,
	input wire enable,
	
	input wire [6:0] dest_address,
	input wire rw,
	
	
	inout scl,
	inout sda
	);
	
	localparam IDLE = 0;
	localparam START = 1;
	localparam SEND_ADRESS = 2;
	localparam READ_ACK1 = 3;
	localparam WRITE_DATA = 4;
	localparam READ_DATA = 5;
	localparam READ_ACK2 = 6;
	localparam WRITE_ACK2 = 7;
	localparam STOP = 8;
	
	reg [7:0] state = IDLE;
	reg scl_out;
	reg sda_out;
	reg [7:0] counter;
	reg [7:0] addr_and_rw;
	
	reg scl_enable = 0;
	reg sda_write_enable = 0;
	
	assign scl = (scl_enable) ? scl_out : 1;
	assign sda = (sda_write_enable) ? sda_out : 'bz;

	always @(posedge clk, negedge clk) begin
		scl_out <= clk;
	end
	
	
	
	always @(negedge scl_out) begin
		case (state)
			
			IDLE: begin
				sda_out <= 1;
				scl_enable <= 0;
				if (enable)
					state <= START;
				else
					state <= IDLE;
			end
			
			START: begin
				counter <= 7;
				sda_out <= 0;
				scl_enable <= 0;
				sda_write_enable <= 1;
				addr_and_rw <= {dest_address, rw};
				state <= SEND_ADRESS;
			end
			
			SEND_ADRESS: begin
				scl_enable <= 1;
				
				sda_out <= addr_and_rw[counter];
				counter <=  counter - 1;
				if (counter == 0) begin
					
					state <= READ_ACK1;
				end
			end
			
			READ_ACK1: begin
				sda_write_enable <= 0;
				if(sda == 0) begin // ACK sucessfull.
					if(rw == 0)
						state <= WRITE_DATA;
					else
						state <= READ_DATA;
				end
				else
					state <= STOP;
			end
			
			STOP: begin
				sda_out <= 1;
				scl_enable <= 0;
				state <= IDLE;
			end
			
			
		endcase
	end

endmodule
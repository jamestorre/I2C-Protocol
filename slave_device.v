module slave_device (
	inout scl,
	inout sda
	);
	
	localparam LOCAL_ADDRESS = 7'b1100110;
	
	localparam READ_ADDRESS = 0;
	localparam SEND_ACK1 = 1;
	localparam SEND_DATA = 2;
	
	
	
	reg [7:0] state;
	reg [7:0] counter;
	reg [7:0] address_frame;
	reg enable = 0;
	reg sda_write_enable = 0;
	reg sda_out = 0;
	reg address_hit = 0;
	reg [7:0] local_data = 8'b10111101;
	
	assign sda = (sda_write_enable) ? sda_out : 'bz;
	
	// Start condition
	always @(negedge sda) begin
		if (scl == 1 && enable == 0) begin
			enable <= 1;
			counter <= 8;
			sda_write_enable <= 0;
			address_hit <= 0;
			state <= READ_ADDRESS;
		end
	end
	
	// Stop condition
	always @(posedge sda) begin
		if (scl == 1 && enable == 1) begin
			enable <= 0;
			state <= READ_ADDRESS;
		end
	end

	
	always @(posedge scl) begin
		case (state) 
			READ_ADDRESS: begin
				if (enable) begin
					address_frame[counter] <= sda;
					if (counter == 0) begin
						
						$display("im here 2");
						state <= SEND_ACK1;
					end
				end
			end
			
			SEND_ACK1: begin
				if (address_hit) begin
					if (address_frame[0] == 1) begin
						counter <= 7;
						state <= SEND_DATA;
					end
				end
			end
			
			SEND_DATA: begin
				counter <= counter - 1;
				if (counter == 0) begin
					state <= READ_ADDRESS;
				end
			end
			
			
		endcase
	end
	
	
	always @(negedge scl) begin
		case (state)
			READ_ADDRESS: begin
				if (enable) begin
					counter <= counter - 1;
				end
			end
			
			SEND_ACK1: begin
				$display("im here 1");
				sda_write_enable <= 1;
				if (LOCAL_ADDRESS == address_frame[7:1]) begin
					$display("yes");
					sda_out <= 0;
					address_hit <= 1;
				end
			end
			
			SEND_DATA: begin
				sda_out <= local_data[counter];
			end
			
		endcase
	end
	
	
endmodule
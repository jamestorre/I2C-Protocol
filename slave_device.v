module slave_device (
	inout scl,
	inout sda
	);
	
	localparam READ_ADDRESS = 0;
	localparam SEND_ACK1 = 1;
	
	reg [6:0] LOCAL_ADRESS = 7'b1100110;
	reg [7:0] state = READ_ADDRESS; 
	reg [7:0] address_frame;
	reg [7:0] counter;
	reg enable = 0;
	
	always @(negedge sda) begin
		if (scl == 1 && enable == 0) begin
			counter <= 7;
			enable <= 1;
		end
	end
	
	always @(posedge sda) begin
		if (scl == 1 && enable == 1) begin
			enable <= 0;
			state <= READ_ADDRESS;
			
		end
	end
	
	always @(posedge scl) begin
		if (enable) begin
			case (state)
				READ_ADDRESS: begin
					address_frame[counter] <= sda;
					counter <= counter - 1;
					if (counter == 0) begin
						$display("MIAU");
						state <= SEND_ACK1;
					end
				end
				
				SEND_ACK1: begin
					
				end
		
			endcase
		end
		
	end
	
	always @(negedge scl) begin
		if (enable) begin
			case (state)
				READ_ADDRESS: begin
						
					
					
				end
				
				SEND_ACK1: begin
					if (LOCAL_ADRESS == address_frame[7:1]) begin
						$display("address matches");
					
					end
				end
		
			endcase
		end
		
		
	end
	
endmodule
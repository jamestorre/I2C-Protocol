module slave_device(
	inout scl,
	inout sda
	);
	
	localparam DEVICE_ADDRESS = 7'b0001110;
	
	localparam READ_ADRESS = 0;
	localparam SEND_ACK = 1;
	
	reg [6:0] received_address;
	reg rw;
	reg [7:0] counter;
	reg [7:0] state = READ_ADRESS;
	reg sda_out;
	reg sda_write_enable = 0;
	reg working = 0;
	
	assign sda = (sda_write_enable) ? sda_out : 'bz;
	
	always @(negedge sda) begin
		if (scl == 1 && working == 0) begin
			counter <= 7;
			working <= 1;
		end
	end
	
	always @(posedge sda) begin
		if (scl == 1 && working == 1) begin
			working <= 0;
		end
	end
	
	always @(posedge scl) begin
		if (working) begin
			case (state) 
				
				READ_ADRESS: begin
					if (counter != 0) begin
						received_address[counter - 1] <= sda;
					end
					counter <= counter - 1;
					if(counter == 0) begin
						rw <= sda;
						state <= SEND_ACK;
					end
					
				end
				
				
				
			endcase
		end
	end
	
	always @(negedge scl) begin
		if(working)
		case (state) 
			
			SEND_ACK: begin
				if(DEVICE_ADDRESS == received_address) begin
					$display("Address matches");
					sda_write_enable <= 1;
					sda_out <= 0;
				end
				$display("Address dont matches");
			end
			
			
			
		endcase
	end
	
	
endmodule
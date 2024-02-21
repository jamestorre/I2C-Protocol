`timescale 1ns / 1ns

`include "master_device.v"
`include "slave_device.v"

module master_device_tb;

	reg clk;
	reg enable;
	
	reg [6:0] dest_address;
	reg rw;
	
	
	wire scl;
	wire sda;
	
	
	master_device master (
			.clk(clk),
			.enable(enable),
			.dest_address(dest_address),
			.rw(rw),
			.scl(scl),
			.sda(sda)
		);
		
	slave_device slave(
		.scl(scl),
		.sda(sda)
		);
		
	
	initial begin
		$dumpfile("master_device_tb.vcd");
		$dumpvars(0, master_device_tb);
	end
	
	initial begin
		clk = 0;
		forever begin
			clk = #2 ~clk;
		end		
	end
	
	initial begin
		sda = 1;
		dest_address = 7'b0001110;
		rw = 1'b0;
		enable = 0;
		#20;
		
        enable = 1;
		#10;
		enable = 0;
		
		#100;
		
		enable = 1;
		#10;
		enable = 0;
		
		#100;
		
		$finish;
		
	end   
	
endmodule
	
	
	
	
	
	
	
`timescale 1ns / 100ps

`include "master_device.v"
`include "slave_device.v"

module master_device_tb;
	reg clk;
	reg enable;
	reg rst;
	reg [6:0] address_in;
	reg rw;
	reg [7:0] data_in;
	
	wire scl;
	wire sda;
	
	master_device DUT_master_device (
		.clk(clk),
		.enable(enable),
		.rst(rst),
		.address_in(address_in),
		.rw(rw),
		.data_in(data_in),
		.scl(scl),
		.sda(sda)
		);

	slave_device DUT_slave_device (
		.scl(scl),
		.sda(sda)
		);

	initial begin
		$dumpfile("master_device_tb.vcd");
		$dumpvars(0);
	end
	
	initial clk = 0;
	always #1 clk <= ~clk;
	
	initial begin
		address_in = 7'b1100110;
		rw = 1;
		data_in = 8'b11100011;
		rst = 1;
		enable = 0;
		#10;
		rst = 0;
		#10;
		enable <= 1;
		#5;
		enable <= 0;
		#500;
		
		$finish;
	end

endmodule
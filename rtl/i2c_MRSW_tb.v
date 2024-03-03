`timescale 1ns / 1ps

`include "master_device.v"
`include "slave_device.v"

// I2C Master Reads, Slave Writes
module i2c_MRSW_tb;
	
	reg r_clk;
	reg r_rst; // Active HIGH reset.
	reg r_enable;
	reg [6:0] r_address;
	reg 		r_rw;
	reg [7:0] r_data;
	
	wire w_busy;
	
	wire w_scl;
	wire w_sda;
	
	
	
	master_device DUT_master_device (
		.i_clk(r_clk),
		.i_rst(r_rst),
		.i_enable(r_enable),
		.i_address(r_address),
		.i_rw(r_rw),
		.i_data(r_data),
		.o_busy(w_busy),
		.io_scl(w_scl),
		.io_sda(w_sda)
		);
		
	slave_device DUT_slave_device (
	.i_scl(w_scl),
	.io_sda(w_sda)
	);
	
	initial begin
		$dumpfile("i2c_MRSW_tb.vcd");
		$dumpvars(0);
	end
	
	initial r_clk = 0;
	always #1 r_clk <= ~r_clk;
	
	// Simulates pull-up resistor behaviour.
	assign w_sda = (w_busy) ? 'bz : 1;	
	
	initial begin
		r_address = 7'b1100110;
		r_rw = 1;  // READ bit
		r_data = 8'b11100011;
		r_rst = 1;
		r_enable = 0;
		#10;
		r_rst = 0;
		#10;
		r_enable <= 1;
		#15;
		r_enable <= 0;
		#200;
		
		$finish;
	end
	
	
endmodule
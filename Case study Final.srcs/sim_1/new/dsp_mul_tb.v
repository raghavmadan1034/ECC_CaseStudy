`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2025 04:46:44 AM
// Design Name: 
// Module Name: dsp_mul_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dsp_mul_tb();
  reg clk,rst,start;
  reg [263:0] a;
  reg [255:0] b;

  // Outputs
  wire valid;
  wire [519:0] product;

  // Instantiate the Unit Under Test (UUT)
  dsp_mul uut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .a(a),
    .b(b),
    .valid(valid),
    .product(product)
  );

  // Clock generation: 10ns period (100 MHz)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Stimulus
  initial begin
    // Initialize Inputs
    rst = 1;
    start = 0;
    a = 0;
    b = 0;

    // Hold reset
    #20;
    rst = 0;

    // Wait and apply inputs
    #10;
    a = 264'd11; // 11 segments of 24-bit numbers
    b = 256'd12; // 16 segments of 16-bit numbers

    start = 1;

    #10;
    start = 0;

    // Wait for result
    wait (valid == 1);

    // Display result
    $display("Multiplication complete.");
    $display("Product = %h", product);

    // End simulation
    #20;
    $finish;
  end

endmodule

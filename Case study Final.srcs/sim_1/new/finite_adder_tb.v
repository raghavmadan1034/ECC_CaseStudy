`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2025 03:36:52 AM
// Design Name: 
// Module Name: finite_adder_tb
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


module finite_adder_tb();

  reg clk, rst, start;
  reg [255:0] a, b;
  wire [255:0] out;
  wire        done;
  integer count;  

  finite_adder uut (
    .clk   (clk),
    .rst   (rst),
    .start (start),
    .a     (a),
    .b     (b),
    .out   (out),
    .done  (done)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst   = 1;
    start = 0;
    a     = 256'h0;
    b     = 256'h0;
    count = 0; 
    
    #15;
    rst = 0;
    #10;
    
    a = 1;
    b = {1'b1, 255'b0} - 20;
    
    start = 1;
    #10;
    start = 0;

    count = 0;
    while (done == 0) begin
      @(posedge clk);
      count = count + 1;
    end
    
    $display("Test completed at time %0t", $time);
    $display("Clock cycles taken: %d", count);
    $display("Input a : %h", a);
    $display("Input b : %h", b);
    $display("Output  : %h", out);
    
    #50;
    $finish;
  end

endmodule


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2025 03:29:03 AM
// Design Name: 
// Module Name: simple_subtractor
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


module simple_subtractor(
    input [63:0] a,b,
    input cin,
    output [63:0] sum,
    output cout
    );
    assign {cout, sum} = a - b - cin;
endmodule

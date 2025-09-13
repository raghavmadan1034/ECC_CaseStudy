`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2025 03:23:44 AM
// Design Name: 
// Module Name: mux_2to1
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


module mux_2to1(
    input [254:0] a,b,
    input sel,
    output [254:0] out
    );
    assign out=sel?b:a;
endmodule

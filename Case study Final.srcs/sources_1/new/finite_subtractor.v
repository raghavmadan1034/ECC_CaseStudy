`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2025 03:49:27 AM
// Design Name: 
// Module Name: finite_subtractor
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


module finite_subtractor(
    input clk, rst, start,
    input [254:0] a,b,  
    output reg  [254:0] result, 
    output reg  valid          
);

    parameter [254:0] P = {1'b1, 255'b0} - 19;

    reg [255:0] diff;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= 0;
            valid  <= 0;
            diff   <= 0;
        end else if (start) begin
            if (a >= b)
                diff = a - b;
            else
                diff = a + P - b;

            result <= diff[254:0];
            valid  <= 1;
        end else begin
            valid <= 0; 
        end
    end

endmodule

 

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2025 03:19:55 AM
// Design Name: 
// Module Name: finite_adder
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


module finite_adder(
    input clk, rst, start,
    input [255:0] a,b,
    output [255:0] out,
    output reg done
    );
    //calculates (A+B)modp
    parameter [255:0] p = {1'b1, 255'b0} - 19;

    parameter CYCLE_1 = 0, CYCLE_2 = 1, CYCLE_3 = 2, CYCLE_4 = 3, CYCLE_5 = 4, CYCLE_6 = 5;

    reg c_in, bo_in;
    wire c_out, bo_out;

    reg [63:0] a_in, b_in,  p_in, sum_in;

    reg [255:0] s, d;

    wire [63:0] add_out, sub_out;

    reg [2:0] state;

    simple_adder uut(a_in, b_in, c_in, add_out, c_out);
    simple_subtractor uuts(sum_in, p_in, bo_in, sub_out, bo_out);

    always@(posedge clk or posedge rst) begin
        if(rst) begin
             state <= CYCLE_1;
             done <= 0;
             s <= 256'b0; 
             d <= 256'b0; 
             a_in <= 64'b0; b_in <= 64'b0; p_in <= 64'b0; sum_in <= 64'b0;
        end
        else begin

            case(state) 
                CYCLE_1: begin
                    done <= 0;
                    a_in <= a[63:0];
                    b_in <= b[63:0];
                    c_in <= 0;
                    if(start) state <= CYCLE_2;
                end

                CYCLE_2: begin
                    s[63:0] <= add_out;
                    sum_in <= add_out;
                    p_in <= p[63:0];
                    a_in <= a[127:64];
                    b_in <= b[127:64];
                    c_in <= c_out;
                    bo_in <= 0;
                    state <= CYCLE_3;
                end

                CYCLE_3: begin
                    s[127:64] <= add_out;
                    d[63:0] <= sub_out;
                    sum_in <= add_out;
                    p_in <= p[127:64];
                    a_in <= a[191:128];
                    b_in <= b[191:128];
                    c_in <= c_out;
                    bo_in <= bo_out;
                    state <= CYCLE_4;
                end

                CYCLE_4: begin
                    s[191:128] <= add_out;
                    d[127:64] <= sub_out;
                    sum_in <= add_out;
                    p_in <= p[191:128];
                    a_in <= a[255:192];
                    b_in <= b[255:192];
                    c_in <= c_out;
                    bo_in <= bo_out;
                    state <= CYCLE_5;
                end

                CYCLE_5: begin
                    s[255:192] <= add_out;
                    d[191:128] <= sub_out;
                    sum_in <= add_out;
                    p_in <= p[255:192];
                    c_in <= c_out;
                    bo_in <= bo_out;
                    state <= CYCLE_6;
                end

                CYCLE_6: begin
                    d[255:192] <= sub_out;
                    state <= CYCLE_1;
                    done <= 1;
                end

            endcase

        end

    end

assign out = (bo_out)? s : d;
    
endmodule

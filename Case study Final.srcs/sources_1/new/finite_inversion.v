`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2025 03:21:50 AM
// Design Name: 
// Module Name: finite_inversion
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


module finite_inversion(
    input clk, rst, start,
    input [254:0] a,
    output reg [254:0] inv,
    output reg valid
);

    localparam [254:0] P = {1'b1, 255'b0} - 19;
    localparam [256:0] P_ext = {2'b00, P};

    localparam IDLE = 2'b00, INIT = 2'b01, RUN = 2'b10, DONE = 2'b11;
    reg [1:0] state;



    reg [256:0] u, v, x1, x2;
    reg [254:0] a_reg;

    wire finish = (u == 257'd1) || (v == 257'd1);

    function [256:0] mod_add;
        input [256:0] A, B;
        reg [257:0] tmp;
        begin
            tmp = A + B;
            if (tmp >= P_ext)
                mod_add = tmp - P_ext;
            else
                mod_add = tmp;
        end
    endfunction

    function [256:0] mod_sub;
        input [256:0] A, B;
        begin
            if (A >= B)
                mod_sub = A - B;
            else
                mod_sub = A + P_ext - B;
        end
    endfunction

    function [256:0] mod_div2;
        input [256:0] A;
        begin
            if (~A[0])
                mod_div2 = A >> 1;
            else
                mod_div2 = (A + P_ext) >> 1;
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            valid <= 0;
            inv <= 0;
            a_reg <= 0;
        end else begin
            case (state)
                IDLE: begin
                    valid <= 0;
                    if (start) begin
                        a_reg <= a;
                        state <= INIT;
                    end
                end

                INIT: begin
                    u <= {2'b00, a_reg};
                    v <= P_ext;
                    x1 <= 257'd1;
                    x2 <= 257'd0;
                    state <= RUN;
                end

                RUN: begin
                    if (finish) begin
                        inv <= (u == 257'd1) ? x1[254:0] : x2[254:0];
                        valid <= 1;
                        state <= DONE;
                    end else if (~u[0]) begin
                        u <= u >> 1;
                        x1 <= mod_div2(x1);
                    end else if (~v[0]) begin
                        v <= v >> 1;
                        x2 <= mod_div2(x2);
                    end else if (u >= v) begin
                        u <= u - v;
                        x1 <= mod_sub(x1, x2);
                    end else begin
                        v <= v - u;
                        x2 <= mod_sub(x2, x1);
                    end
                end

                DONE: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
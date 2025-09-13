`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/10/2025 10:13:18 PM
// Design Name: 
// Module Name: finite_inv
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



module finite_inv(
    input  clk,rst,
    input  wire [254:0] a,
    output reg  [254:0] inv,
    output reg  valid
);

    parameter [254:0] P_255 = ({1'b1, 255'b0} - 19);
    parameter [255:0] P     = {1'b0, P_255};

    localparam IDLE    = 2'd0,
               PROCESS = 2'd1,
               DONE    = 2'd2,
               WAIT_NEW= 2'd3;

    reg [1:0] state;

    reg [255:0] u, v, x_1, x2;

    reg [254:0] a_last;

    wire finish = (u == 256'd1) || (v == 256'd1);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state  <= IDLE;
            valid  <= 1'b0;
            inv    <= {255{1'b0}};
            u      <= 256'd0;
            v      <= 256'd0;
            x_1    <= 256'd0;
            x2     <= 256'd0;
            a_last <= {255{1'b0}};
        end else begin
            case (state)
                IDLE: begin
                    if (a != a_last) begin
                        valid <= 1'b0;
                        a_last <= a;  // Latch the new input.
                        u   <= {1'b0, a};
                        v   <= P;
                        x_1 <= 256'd1;
                        x2  <= 256'd0;
                        state <= PROCESS;
                    end
                end

                PROCESS: begin
                    if (finish) begin
                        state <= DONE;
                    end else begin
                        if (u[0] == 1'b0) begin
                            u <= u >> 1;
                            if (x_1[0] == 1'b0)
                                x_1 <= x_1 >> 1;
                            else
                                x_1 <= (x_1 + P) >> 1;
                        end
                        else if (v[0] == 1'b0) begin
                            v <= v >> 1;
                            if (x2[0] == 1'b0)
                                x2 <= x2 >> 1;
                            else
                                x2 <= (x2 + P) >> 1;
                        end
                        else if (u >= v) begin
                            u <= u - v;
                            if (x_1 >= x2)
                                x_1 <= x_1 - x2;
                            else
                                x_1 <= x_1 + P - x2;
                        end else begin // v > u
                            v <= v - u;
                            if (x2 >= x_1)
                                x2 <= x2 - x_1;
                            else
                                x2 <= x2 + P - x_1;
                        end
                    end
                end

                DONE: begin
                    if (u == 256'd1)
                        inv <= x_1[254:0];
                    else
                        inv <= x2[254:0];
                    valid <= 1'b1;
                    state <= WAIT_NEW;
                end

                WAIT_NEW: begin
                    if (a != a_last) begin
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
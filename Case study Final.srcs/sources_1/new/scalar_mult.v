`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2025 03:05:36 PM
// Design Name: 
// Module Name: scalar_mult
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


module scalar_mult(
    input [254:0] k, x_p,
    input clk, rst,
    output reg [254:0] x_q,
    output reg done
    );
   wire [255:0] k_ext = {1'b0, k};

    reg start_mul;
    reg start_add;
    reg start_sub;
    reg start_inv;

    reg [254:0] X1, X2, X3, Z2, Z3;
    reg [254:0] t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14;

    reg [254:0] a_add, b_add;
    reg [254:0] a_sub, b_sub;
    reg [254:0] a_mul, b_mul;
    reg [254:0] a_inv;
   

    wire [255:0] add_res;
    wire [254:0]  sub_res, mul_res, inv_res;
    wire add_valid, sub_valid, mul_valid, inv_valid;
//    reg valid_Z2;

    finite_multiplier mul(clk, rst, start_mul, a_mul, b_mul, mul_res, mul_valid);
    finite_adder add(clk, rst, start_add, {1'b0,a_add}, {1'b0,b_add}, add_res, add_valid);
    finite_subtractor sub(clk, rst, start_sub, a_sub, b_sub, sub_res, sub_valid);
    finite_inversion inv(clk, rst,start_inv, a_inv, inv_res, inv_valid);

    parameter STEP_3 = 0;
    parameter STEP_7A = 1;
    parameter WAIT_STEP_7A = 2;
    parameter STEP_7B = 3;
    parameter WAIT_STEP_7B = 4;
    parameter SUB_T6_T7 = 5;
    parameter STEP_9A = 6;
    parameter WAIT_STEP_9A = 7;
    parameter STEP_9B = 8;
    parameter WAIT_STEP_9B = 9;
    parameter STEP_10 = 10;
    parameter WAIT_STEP_10 = 11;
    parameter STEP_11A = 12;
    parameter WAIT_STEP_11A = 13;
    parameter STEP_11B = 14;
    parameter WAIT_STEP_11B  = 15;
    parameter STEP_12 = 16;
    parameter WAIT_STEP_12  = 17;
    parameter STEP_13A = 18;
    parameter WAIT_STEP_13A  = 19;
    parameter STEP_13B= 20;
    parameter WAIT_STEP_13B = 21;
    parameter STEP_14 = 22;
    parameter OUT = 23;
    parameter STEP_5 = 24;
    parameter WAIT_STEP_5 = 25;
    parameter STEP_6 = 26;
    parameter WAIT_STEP_6 = 27;
    parameter STEP_8 = 28;
    parameter WAIT_STEP_8 = 29;
    parameter STEP_4 = 30;
    parameter STEP_15A = 31;
    parameter WAIT_STEP_15A = 32;
    parameter STEP_15B = 33;
    parameter WAIT_STEP_15B = 34;

    reg [5:0] state;
    reg [7:0] i;
    reg c;

    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            state <= STEP_3;
            X1 <= x_p;
            X2 <= 1;
            Z2 <= 0;
            X3 <= x_p;
            Z3 <= 1;
            done <= 0;
            x_q <= 0;
            t1 <= 0; t2 <= 0; t3 <= 0; t4 <= 0; t5 <= 0; t6 <= 0; t7 <= 0; t8 <= 0; t9 <= 0; t10 <= 0; t11 <= 0; t12 <= 0; t13 <= 0; t14 <= 0;
            i <= 8'd254;
//            valid_Z2 <= 0;
        end

        else begin
            case (state)
                STEP_3: begin
                    $display("%d", i);
                    done <= 0;
                    c <= k_ext[i+1]^k_ext[i];
                    state <= STEP_4;
                end

                STEP_4: begin
                    if(c) begin
                        X2 <= X3;
                        X3 <= X2;
                        Z2 <= Z3;
                        Z3 <= Z2;
                    end
                    state <= STEP_5;
                end

                STEP_5: begin
                    a_add <= X2;
                    b_add <= Z2;
                    start_add<= 1;
                    a_sub <= X2;
                    b_sub <= Z2;
                    start_sub<= 1;
                    state <= WAIT_STEP_5;
                end

                WAIT_STEP_5: begin
                    start_add <= 0;
                    start_sub <= 0;
                    if (add_valid) begin
                        t1 <= add_res[254:0];
                        t2 <= sub_res;
                        state <= STEP_6;
                    end
                end

                STEP_6: begin
                    a_add <= X3;
                    b_add <= Z3;
                    start_add<= 1;
                    a_sub <= X3;
                    b_sub <= Z3;
                    start_sub<= 1;
                    state <= WAIT_STEP_6;
                end

                WAIT_STEP_6: begin
                    start_add<= 0;
                    start_sub <= 0;
                    if (add_valid) begin
                        t3 <= add_res[254:0];
                        t4 <= sub_res;
                        state <= STEP_7A;
                    end
                end

                STEP_7A: begin
                    a_mul    <= t1;
                    b_mul    <= t1;
                    start_mul<= 1;
                    state    <= WAIT_STEP_7A;
                end

                WAIT_STEP_7A: begin
                    start_mul<= 0;
                    if (mul_valid) begin
                        t6    <= mul_res;
                        state <= STEP_7B;
                    end
                end

                STEP_7B: begin
                    a_mul    <= t2;
                    b_mul    <= t2;
                    start_mul<= 1;
                    state    <= WAIT_STEP_7B;
                end

                WAIT_STEP_7B: begin
                    start_mul<= 0;
                    if (mul_valid) begin
                        t7 <= mul_res;
                        state <= STEP_8;
                    end
                end

                STEP_8: begin
                    a_sub <= t6;
                    b_sub <= t7;
                    start_sub<= 1;
                    a_mul <= t4;
                    b_mul <= t1;
                    start_mul<= 1;
                    state <= WAIT_STEP_8;
                end

                WAIT_STEP_8: begin
                    start_sub<= 0;
                    start_mul<= 0;
                    if (mul_valid) begin        
                        t5 <= sub_res;
                        t8 <= mul_res;
                        state <= STEP_9A;
                    end
                end

                STEP_9A: begin
                    a_mul <= t3;
                    b_mul <= t2;
                    start_mul<= 1;

                    state <= WAIT_STEP_9A;
                end

                WAIT_STEP_9A: begin
                    start_mul<= 0;
                    if (mul_valid) begin
                        t9 <= mul_res;
                        state <= STEP_9B;
                    end
                end

                STEP_9B: begin
                    a_add <= t8;
                    b_add <= t9;
                    start_add<= 1;
                    state <= WAIT_STEP_9B;
                end

                WAIT_STEP_9B: begin
                    start_add<= 0;
                    if (add_valid) begin
                        t10 <= add_res[254:0];
                        state <= STEP_10;
                    end
                end

                STEP_10: begin
                    a_sub <= t8;
                    b_sub <= t9;
                    start_sub<= 1;
                    a_mul <= t10;
                    b_mul <= t10;
                    start_mul<= 1;
                    state <= WAIT_STEP_10;
                end

                WAIT_STEP_10: begin
                    start_sub<= 0;
                    start_mul<= 0;
                    if (mul_valid) begin
                        t11 <= sub_res;
                        X3 <= mul_res;
                        state <= STEP_11A;
                    end
                end

                STEP_11A: begin
                    a_mul <= t11;
                    b_mul <= t11;
                    start_mul<= 1;
                    state <= WAIT_STEP_11A;
                end

                WAIT_STEP_11A: begin
                    start_mul<= 0;
                    if (mul_valid) begin
                        t12 <= mul_res;
                        state <= STEP_11B;
                    end
                end

                STEP_11B: begin
                    a_mul <= t5;
                    b_mul <= 255'd121666;
                    start_mul<= 1;
                    state <= WAIT_STEP_11B;
                end

                WAIT_STEP_11B: begin
                    start_mul<= 0;
                    if (mul_valid) begin
                        t13 <= mul_res;
                        state <= STEP_12;
                    end
                end

                STEP_12: begin
                    a_mul <= t6;
                    b_mul <= t7;
                    start_mul<= 1;
                    a_add <= t7;
                    b_add <= t13;
                    start_add<= 1;
                    state <= WAIT_STEP_12;
                end

                WAIT_STEP_12: begin
                    start_mul<= 0;
                    start_add<= 0;
                    if (mul_valid) begin
                        X2 <= mul_res;
                        t14 <= add_res[254:0];
                        state <= STEP_13A;
                    end
                end

                STEP_13A: begin
                    a_mul <= X1;
                    b_mul <= t12;
                    start_mul<= 1;
                    state <= WAIT_STEP_13A;
                end

                WAIT_STEP_13A: begin
                    start_mul<= 0;
                    if (mul_valid) begin
                        Z3 <= mul_res;
                        state <= STEP_13B;
                    end
                end

                STEP_13B: begin
                    a_mul <= t5;
                    b_mul <= t14;
                    start_mul<= 1;
                    state <= WAIT_STEP_13B;
                end

                WAIT_STEP_13B: begin
                    start_mul<= 0;
                    if (mul_valid) begin
                        Z2 <= mul_res;
//                        valid_Z2 <= 1;
                        state <= STEP_14;
                    end
                end

                STEP_14: begin
//                        valid_Z2 <= 0;
                          if(i == 0) begin
                            if(k[0]) begin
                                X2 <= X3;
                                X3 <= X2;
                                Z2 <= Z3;
                                Z3 <= Z2;
                            end
                            state <= STEP_15A;
                        end
                        else begin
                            i = i - 1;
                            state <= STEP_3;
                        end
                end

                STEP_15A: begin
//                if(valid_Z2)begin
                    a_inv <= Z2;
//                    $display(a_inv);
                    start_inv <= 1;
                    state <= WAIT_STEP_15A;
//                    end
                end

                WAIT_STEP_15A: begin
                    start_inv <= 0;
                    if(inv_valid) begin
                    Z2 <= inv_res;
//                    $display(inv_res);
                    state <= STEP_15B;
                    end
                end

                STEP_15B: begin
                    a_mul <= X2;
                    b_mul <= Z2;
                    start_mul<= 1;
                    state <= WAIT_STEP_15B;
                end

                WAIT_STEP_15B: begin
                    start_mul<= 0;
                    if (mul_valid) begin
                        x_q <= mul_res;
                        state <= OUT;
                    end
                end

                OUT: begin
                        done <= 1;
                        state <= OUT;
                end
            endcase
        end
    end
endmodule

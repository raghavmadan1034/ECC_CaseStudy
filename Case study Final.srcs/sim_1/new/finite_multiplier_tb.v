`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2025 04:21:24 AM
// Design Name: 
// Module Name: finite_multiplier_tb
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


module finite_multiplier_tb();
    reg clk,rst,start;
    reg [254:0] a, b;   // 255-bit test inputs
    wire [254:0] result;
    wire valid;
    finite_multiplier uut(clk, rst, start, a, b, result, valid);
    reg [31:0] cycle_count;
    // Precomputed constants
    localparam [254:0] P      = 255'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED; // 2^255-19
    localparam [254:0] Pm1    = 255'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEC; // 2^255-20
    localparam [254:0] Pm2    = 255'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEB; // 2^255-21
    localparam [254:0] TWO254 = 255'h4000000000000000000000000000000000000000000000000000000000000000; // 2^254
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    initial begin
        rst = 1;
        cycle_count = 0;
        #10;
        rst = 0;
        // Test 1: simple
        wait(!valid);
        a = 255'd33;
        b = 255'd33;
        start = 1;
        @(posedge clk);
        start = 0;
        wait(valid);
        $display("Test simple:     a = %d, b = %d, a * b mod P = %d (expected: 1089)", a, b, result);
        #10;
        wait(!valid);
        // Test 2: one*one
        a = 255'd1;
        b = 255'd1;
        start = 1;
        @(posedge clk);
        start = 0;
        wait(valid);
        $display("Test one*one:    a = %d, b = %d, a * b mod P = %d (expected: 1)", a, b, result);
        #10;
        wait(!valid);
        // Test 3: zero*any
        a = 255'd0;
        b = 255'd12345;
        start = 1;
        @(posedge clk);
        start = 0;
        wait(valid);
        $display("Test zero*any:   a = %d, b = %d, a * b mod P = %d (expected: 0)", a, b, result);
        #10;
        wait(!valid);
        // Test 4: any*zero
        a = 255'd12345;
        b = 255'd0;
        start = 1;
        @(posedge clk);
        start = 0;
        wait(valid);
        $display("Test any*zero:   a = %d, b = %d, a * b mod P = %d (expected: 0)", a, b, result);
        #10;
        wait(!valid);
        // Test 5: max-1*max-2
        a = Pm2;
        b = Pm1;
        start = 1;
        @(posedge clk);
        start = 0;
        wait(valid);
        $display("Test max-1*max-2: a = %h, b = %h, a * b mod P = %h (expected: 2)", a, b, result);
        #10;
        wait(!valid);
        // Test 6: 2*(P-1)
        a = 255'd2;
        b = Pm1;
        start = 1;
        @(posedge clk);
        start = 0;
        wait(valid);
        $display("Test 2*(P-1):    a = %d, b = %d, a * b mod P = %d (expected: P-2)", a, b, result);
        #10;
        wait(!valid);
        // Test 7: 2^254*2
        a = TWO254;
        b = 255'd2;
        start = 1;
        @(posedge clk);
        start = 0;
        wait(valid);
        $display("Test 2^254*2:    a = %d, b = %d, a * b mod P = %d (expected: 19)", a, b, result);
        #10;
        wait(!valid);
        // Test 8: P*1
        a = P;
        b = 255'd1;
        start = 1;
        @(posedge clk);
        start = 0;
        wait(valid);
        $display("Test P*1:        a = %d, b = %d, a * b mod P = %d (expected: 19)", a, b, result);
        #10;
        wait(!valid);
        // Test 9: P*P
        a = P;
        b = P;
        start = 1;
        @(posedge clk);
        start = 0;
        wait(valid);
        $display("Test P*P:        a = %d, b = %d, a * b mod P = %d (expected: 0)", a, b, result);
        #10;
        wait(!valid);
        // Test 10: 1*(P-1)
        a = 255'd1;
        b = Pm1;
        start = 1;
        @(posedge clk);
        start = 0;
        wait(valid);
        $display("Test 1*(P-1):    a = %d, b = %d, a * b mod P = %d (expected: 57896044618658097711785492504343953926634992332820282019728792003956564819948)", a, b, result);
        #10;
        wait(!valid);
        $finish;
    end



endmodule

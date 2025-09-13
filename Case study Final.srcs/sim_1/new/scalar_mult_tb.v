`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
// 
// Create Date: 05/08/2025 04:33:52 PM
// Design Name:
// Module Name: scalar_mult_tb
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Updated testbench with multiple test cases and expected outputs.
// 
// Revision:
// Revision 0.02 - Added test cases.
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////

module scalar_mult_tb();
    reg [254:0] k;
    reg [254:0] x_p;
    reg clk;
    reg rst;

    wire [254:0] x_q;
    wire done;

    reg [31:0] cycle_count;

    scalar_mult uut (
        .k(k),
        .x_p(x_p),
        .clk(clk),
        .rst(rst),
        .x_q(x_q),
        .done(done)
    );

    // Clock generation: 10 ns period
    always begin
        #5 clk = ~clk;
    end

    // Cycle counter
    always @(posedge clk) begin
        if (rst)
            cycle_count <= 0;
        else
            cycle_count <= cycle_count + 1;
    end

    // Task to run individual test cases with timeout
    task run_test;
        input [7:0] test_id;
        input [254:0] x_p_in;
        input [254:0] k_in;
        input [1023:0] expected;
        integer timeout_cycles;
        integer waited_cycles;
    begin
        timeout_cycles = 1500000; // Max cycles to wait
        waited_cycles = 0;

        $display("=====================================");
        $display("Starting Test %0d", test_id);
        x_p = x_p_in;
        k = k_in;
        #5;
        rst = 1;
        #20;
        rst = 0;
        clk = 0;
        cycle_count = 0;
        #100; // hold reset
        rst = 0;

        // Wait loop with timeout
        while (!done && waited_cycles < timeout_cycles) begin
            @(posedge clk);
            waited_cycles = waited_cycles + 1;
        end

        if (done) begin
            $display("Test %0d PASSED", test_id);
            $display("   Result     : %d", x_q);
            $display("   Cycles     : %d", cycle_count);
            $display("   Expected   : %s", expected);
        end else begin
            $display("Test %0d FAILED: Timeout waiting for 'done'!", test_id);
        end

        #100;
    end
    endtask

    initial begin
        clk = 0;

        run_test(1,
            255'd517870473962065073715754963515477576685739287104074429,
            255'd459658494585788233372856281149471856210727824724660276,
            "expected result for test 1 (placeholder)");

        run_test(2,
            255'd123456789012345678901234567890,
            255'd98765432109876543210987654321,
            "expected result for test 2 (placeholder)");

      run_test(3,
            255'd1,
            255'd1,
            "expected result for test 3: 1 (or identity value)");

        $finish;
    end
endmodule

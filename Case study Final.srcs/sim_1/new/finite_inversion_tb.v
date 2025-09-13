`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2025 02:41:40 PM
// Design Name: 
// Module Name: finite_inversion_tb
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


module finite_inversion_tb();
    reg clk,rst,start;
    reg [254:0] a;
    wire [254:0] inv;
    wire valid;
    reg [509:0] prod;
    reg [255:0] rem;

    // Derived parameters for the modulus
    parameter [254:0] P_255 = ({1'b1, 255'b0} - 19);
    parameter [255:0] P     = {1'b0, P_255};

    // Instantiate the ffi module (make sure the module receives a start pulse!)
    finite_inversion uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a(a),
        .inv(inv),
        .valid(valid)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Reset and initialization
        rst = 1;
        a   = 0;
        start = 0;
        #20;
        rst = 0;
        #10;

        //------------------------------------------------
        // Test 3: a = 1 (inverse of 1 should be 1)
        a = 255'd1;
        $display("Test 3: Applying a = %d (inverse of 1)", a);
        start = 1;        // pulse start to trigger inversion
        #10;
        start = 0;
        wait(valid == 1);
        #5;
        $display("Test 3 Results:");
        $display("  Input a          = %d", a);
        $display("  Computed inverse = %d", inv);
        prod = a * inv;
        rem = prod % P;
        $display("  a * inv mod P  = %h", rem);
        if (rem == 256'd1)
            $display("  Inversion correct: PASSED!\n");
        else
            $display("  Inversion incorrect: FAILED!\n");
        #20;

        //------------------------------------------------
        // Test 4: a = P-1 (special case)
        a = P_255 - 255'd1;
        $display("Test 4: Applying a = P-1");
        start = 1;
        #10;
        start = 0;
        wait(valid == 1);
        #5;
        $display("Test 4 Results:");
        $display("  Input a          = %d", a);
        $display("  Computed inverse = %d", inv);
        prod = a * inv;
        rem = prod % P;
        $display("  a * inv mod P  = %h", rem);
        if (rem == 256'd1)
            $display("  Inversion correct: PASSED!\n");
        else
            $display("  Inversion incorrect: FAILED!\n");
        #20;

        //------------------------------------------------
        // Test 5: Large value
        a = {1'b0, {127{1'b1}}, {127{1'b0}}};  // Example: 2^127-1 shifted left 127 places
        $display("Test 5: Applying large value a = %h", a);
        start = 1;
        #10;
        start = 0;
        wait(valid == 1);
        #5;
        $display("Test 5 Results:");
        $display("  Input a          = %h", a);
        $display("  Computed inverse = %h", inv);
        prod = a * inv;
        rem = prod % P;
        $display("  a * inv mod P  = %h", rem);
        if (rem == 256'd1)
            $display("  Inversion correct: PASSED!\n");
        else
            $display("  Inversion incorrect: FAILED!\n");
        #20;

        //------------------------------------------------
        // Test 6: a = 2 (power of 2)
        a = 255'd2;
        $display("Test 6: Applying a = %d (power of 2)", a);
        start = 1;
        #10;
        start = 0;
        wait(valid == 1);
        #5;
        $display("Test 6 Results:");
        $display("  Input a          = %d", a);
        $display("  Computed inverse = %d", inv);
        prod = a * inv;
        rem = prod % P;
        $display("  a * inv mod P  = %h", rem);
        if (rem == 256'd1)
            $display("  Inversion correct: PASSED!\n");
        else
            $display("  Inversion incorrect: FAILED!\n");
        #20;

        $finish;
    end

endmodule

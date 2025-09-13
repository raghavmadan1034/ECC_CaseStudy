`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2025 03:52:49 AM
// Design Name: 
// Module Name: dsp_mul
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


module dsp_mul(
    input clk,rst,start,  
    input      [263:0] a,      // 264-bit operand a (11 segments of 24 bits)
    input      [255:0] b,     
    output reg valid,  
    output reg [519:0] product 
    );
    localparam IDLE    = 2'd0,
             COMPUTE = 2'd1,
             DONE    = 2'd2;

  reg [1:0] state;


  reg [3:0] i;
  reg [3:0] j;

  wire [23:0] a_seg = a[24*i +: 24];
  wire [15:0] b_seg = b[16*j +: 16];

  wire [39:0] mult_result = a_seg * b_seg;      //40 bit result from 24*16


  wire [519:0] shifted_partial =
        ({ {480{1'b0}}, mult_result } << (24*i + 16*j) );


  always @(posedge clk) begin
    if (rst) begin
      state   <= IDLE;
      i       <= 0;
      j       <= 0;
      product <= 0;
      valid   <= 0;
    end else begin
      case (state)
        IDLE: begin
          valid <= 0;
          if (start) begin
            state   <= COMPUTE;
            i       <= 0;
            j       <= 0;
            product <= 0;
          end
        end

        COMPUTE: begin
          product <= product + shifted_partial; 
          if (j == 15) begin                    
            if (i == 10)                    
              state <= DONE;
            else begin
              i <= i + 1;                       // next seg of a
              j <= 0;
            end
          end else begin
            j <= j + 1;                         // next segment of 'b'.
          end
        end

        DONE: begin
          valid <= 1;

          if (!start)                      
            state <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule

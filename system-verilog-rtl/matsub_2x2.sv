`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2025 08:13:51 PM
// Design Name: 
// Module Name: matsub_2x2
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


module matsub_2x2#(
    parameter 
        BIT_PREC = 8, // 8-bit values
        N = 2 // 2 x 2 matrix
    )(
    input logic signed [BIT_PREC-1:0] A[N][N], 
    input logic signed [BIT_PREC-1:0] B[N][N],
    output logic signed [BIT_PREC-1:0] C[N][N]
    );
    always_comb begin
        C[0][0] <= A[0][0] - B[0][0];
        C[0][1] <= A[0][1] - B[0][1];
        C[1][0] <= A[1][0] - B[1][0];
        C[1][1] <= A[1][1] - B[1][1];
    end
endmodule

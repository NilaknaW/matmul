`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/19/2025 12:15:50 PM
// Design Name: 
// Module Name: matmul_4x4_tb
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


module matmul_4x4_tb;
    localparam BIT_PREC = 8, N = 4;
    logic clk = 0, rstn = 0, start = 0, valid;
    logic signed [BIT_PREC-1:0] A[N][N]; 
    logic signed [BIT_PREC-1:0] B[N][N]; 
    logic signed [2*BIT_PREC:0] C[N][N];
    
    matmul_4x4 dut(.A(B), .B(A), .C(C), .clk(clk), .rstn(rstn), .start(start), .valid(valid));
    
    always #5 clk = ~clk;
        
    initial begin
        $dumpfile ("dump.vcd"); $dumpvars;
        #10 rstn = 1;
        // Initialize matrices A and B
        A[0][0] = 1;  A[0][1] = 2;  A[0][2] = 3;  A[0][3] = 4;
        A[1][0] = 5;  A[1][1] = 6;  A[1][2] = 7;  A[1][3] = 8;
        A[2][0] = 9;  A[2][1] = 10; A[2][2] = 11; A[2][3] = 12;
        A[3][0] = 13; A[3][1] = 14; A[3][2] = 15; A[3][3] = 16;

        B[0][0] = 17; B[0][1] = 18; B[0][2] = 19; B[0][3] = 20;
        B[1][0] = 21; B[1][1] = 22; B[1][2] = 23; B[1][3] = 24;
        B[2][0] = 25; B[2][1] = 26; B[2][2] = 27; B[2][3] = 28;
        B[3][0] = 29; B[3][1] = 30; B[3][2] = 31; B[3][3] = 32;
        
        #10 start = 1; 
        #10 start = 0;
        
        wait(valid);
        // Display result
        $display("Matrix C = A * B:");
        for (int i = 0; i < N; i = i + 1) begin
            $write("[ ");
            for (int j = 0; j < N; j = j + 1) begin
                $write("%0d ", C[i][j]);
            end
            $write("]\n");
        end
    end
endmodule

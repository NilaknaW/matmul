`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/19/2025 10:06:47 AM
// Design Name: 
// Module Name: matadd_2x2_tb
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


module matadd_2x2_tb;
    localparam BIT_PREC = 8;
//    logic clk = 0, rstn = 0, start = 0, valid;
    logic signed [BIT_PREC-1:0] A[2][2]; 
    logic signed [BIT_PREC-1:0] B[2][2]; 
    logic signed [BIT_PREC-1:0] C[2][2];
    
    matadd_2x2 dut(.*);
    
//    always #5 clk = ~clk;
    
    initial begin 
        $dumpfile("dump.vcd"); $dumpvars(0,dut); #1;
//        #10 rstn = 1;
        A[0][0] = 8'd1; A[0][1] = 8'd2; A[1][0] = 8'd3; A[1][1] = 8'd4;
        B[0][0] = 8'd1; B[0][1] = 8'd2; B[1][0] = 8'd3; B[1][1] = 8'd4;
        
//        #10 start = 1; 
//        #10 start = 0;
        
//        wait(valid);
        #10 $display("C = [[%0d %0d], [%0d %0d]]", C[0][0], C[0][1], C[1][0], C[1][1]);
    end
endmodule

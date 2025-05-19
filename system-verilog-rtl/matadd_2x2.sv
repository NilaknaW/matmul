`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2025 08:14:30 PM
// Design Name: 
// Module Name: matmul_2x2
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


module matadd_2x2#(
    parameter 
        BIT_PREC = 8, // 8-bit values
        N = 2 // 2 x 2 matrix
    )(
//    input logic clk, rstn, start,
    input logic signed [BIT_PREC-1:0] A[N][N], 
    input logic signed [BIT_PREC-1:0] B[N][N],
    output logic signed [BIT_PREC-1:0] C[N][N]
//    output logic valid
    );
    always_comb begin
        C[0][0] <= A[0][0] + B[0][0];
        C[0][1] <= A[0][1] + B[0][1];
        C[1][0] <= A[1][0] + B[1][0];
        C[1][1] <= A[1][1] + B[1][1];
    end
//    typedef enum logic [1:0] {IDLE, ADD} state_t;
//    state_t state;
    
//    always_ff @ (posedge clk or negedge rstn) begin
//        if (!rstn) begin 
//            valid <= 0;
//            end
//        else case (state)
//            IDLE: begin
//                valid <= 0;
//                if (start) state <= ADD;
//                end
//            ADD: begin
//                C[0][0] <= A[0][0] + B[0][0];
//                C[0][1] <= A[0][1] + B[0][1];
//                C[1][0] <= A[1][0] + B[1][0];
//                C[1][1] <= A[1][1] + B[1][1];
                
//                valid <= 1;
//                state <= IDLE;
//                end
//            endcase
//        end
endmodule

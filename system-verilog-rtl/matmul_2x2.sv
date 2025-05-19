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


module matmul_2x2 #(
    parameter 
        BIT_PREC = 8, // 8-bit values
        N = 2 // 2 x 2 matrix
    )(
    input logic clk, rstn, start,
    input logic signed [BIT_PREC-1:0] A[N][N], 
    input logic signed [BIT_PREC-1:0] B[N][N],
    output logic signed [2*BIT_PREC:0] C[N][N],
    output logic valid
    );
        
    logic signed [BIT_PREC:0] pa [10];
    logic signed [2*BIT_PREC:0] p [7];
    logic signed [2*BIT_PREC:0] ca [4];
    
    typedef enum logic [2:0] {IDLE, P_ADD, P_MUL, C_ADD1, C_ADD2, C_FINAL} state_type;
    state_type state;
    
    always_ff @ (posedge clk or negedge rstn) begin
        if (!rstn) begin 
            state <= IDLE;
            valid <= 0;
            end
        else case (state)
            IDLE: begin
                valid <= '0;
                if (start) state <= P_ADD;
                end
            P_ADD: begin
                // 10 pre additions
                pa[0] <= A[0][0] + A[1][1];
                pa[1] <= B[0][0] + B[1][1];
                
                pa[2] <= A[1][0] + A[1][1];
                
                pa[3] <= B[0][1] - B[1][1];
                
                pa[4] <= B[1][0] - B[0][0];
                
                pa[5] <= A[0][0] + A[0][1];
                
                pa[6] <= A[1][0] - A[0][0];
                pa[7] <= B[0][0] + B[0][1];
                
                pa[8] <= A[0][1] - A[1][1];
                pa[9] <= B[1][0] + B[1][1];
                
                state <= P_MUL;
                end
            P_MUL:begin
                // 7 strassen muls
                p[0] <= pa[0] * pa[1];
                p[1] <= pa[2] * B[0][0];
                p[2] <= A[0][0] * pa[3];
                p[3] <= A[1][1] * pa[4];
                p[4] <= pa[5] * B[1][1];
                p[5] <= pa[6] * pa[7];
                p[6] <= pa[8] * pa[9];
                
                state <= C_ADD1;
                end
            C_ADD1: begin
                ca[0] <= p[0] + p[3];
                ca[2] <= p[0] + p[2];
                state <= C_ADD2;
                end
            C_ADD2: begin
                ca[1] <= ca[0] - p[4];
                ca[3] <= ca[2] - p[1];
                state <= C_FINAL;
                end
           C_FINAL : begin
                C[0][0] <= ca[1] + p[6];
                C[0][1] <= p[2] + p[4];
                C[1][0] <= p[1] + p[3];
                C[1][1] <= ca[3] + p[5];
                              
                valid <= '1;
                state <= IDLE;
                end
            endcase
    end 
endmodule

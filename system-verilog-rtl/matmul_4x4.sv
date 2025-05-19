`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/19/2025 10:31:45 AM
// Design Name: 
// Module Name: matmul_4x4
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


module matmul_4x4 #(
    parameter 
        BIT_PREC = 8, // 8-bit values
        N = 4 // 2 x 2 matrix
    )(
    input logic clk, rstn, start,
    input logic signed [BIT_PREC-1:0] A[N][N], B[N][N],
    output logic signed [2*BIT_PREC:0] C[N][N],
    output logic valid
    );
    
    logic signed [BIT_PREC-1:0] A11[2][2], A12[2][2], A21[2][2], A22[2][2];
    logic signed [BIT_PREC-1:0] B11[2][2], B12[2][2], B21[2][2], B22[2][2];
    
    // registers for A11 .. B22
    logic signed [BIT_PREC-1:0] A11_reg[2][2], A12_reg[2][2], A21_reg[2][2], A22_reg[2][2];
    logic signed [BIT_PREC-1:0] B11_reg[2][2], B12_reg[2][2], B21_reg[2][2], B22_reg[2][2];

    always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        A11_reg <= '{default:0}; A12_reg <= '{default:0};
        A21_reg <= '{default:0}; A22_reg <= '{default:0};
        B11_reg <= '{default:0}; B12_reg <= '{default:0};
        B21_reg <= '{default:0}; B22_reg <= '{default:0};
    end else if (start) begin
        A11_reg <= A11; A12_reg <= A12;
        A21_reg <= A21; A22_reg <= A22;
        B11_reg <= B11; B12_reg <= B12;
        B21_reg <= B21; B22_reg <= B22;
    end
    end

    always_comb begin
    // decompose A and B into 4 2x2 matrices
    A11[0][0] = A[0][0];  A11[0][1] = A[0][1]; A11[1][0] = A[1][0];  A11[1][1] = A[1][1];
    A12[0][0] = A[0][2];  A12[0][1] = A[0][3]; A12[1][0] = A[1][2];  A12[1][1] = A[1][3];
    A21[0][0] = A[2][0];  A21[0][1] = A[2][1]; A21[1][0] = A[3][0];  A21[1][1] = A[3][1];
    A22[0][0] = A[2][2];  A22[0][1] = A[2][3]; A22[1][0] = A[3][2];  A22[1][1] = A[3][3];

    // B matrix decomposition
    B11[0][0] = B[0][0];  B11[0][1] = B[0][1]; B11[1][0] = B[1][0];  B11[1][1] = B[1][1];
    B12[0][0] = B[0][2];  B12[0][1] = B[0][3]; B12[1][0] = B[1][2];  B12[1][1] = B[1][3];
    B21[0][0] = B[2][0];  B21[0][1] = B[2][1]; B21[1][0] = B[3][0];  B21[1][1] = B[3][1];
    B22[0][0] = B[2][2];  B22[0][1] = B[2][3]; B22[1][0] = B[3][2];  B22[1][1] = B[3][3];
    end
    
    // registers for intermediate additions and multiplications
    logic signed [BIT_PREC-1:0] add1[10][2][2], add1_reg[10][2][2];
    logic signed [2*BIT_PREC:0] mul1[7][2][2], mul1_reg[7][2][2];
    logic signed [2*BIT_PREC:0] add2[4][2][2], add2_reg[4][2][2];
    logic signed [2*BIT_PREC:0] add3[4][2][2];
    
//    logic signed [BIT_PREC-1:0] add1[10] [2][2], add10[10] [2][2];
//    logic signed [2*BIT_PREC:0] mul1[7] [2][2], mul10[7] [2][2];
//    logic signed [2*BIT_PREC:0] add2[4] [2][2], add20[4] [2][2], add3[4] [2][2], add30[4] [2][2];
    
    // initial addition set
    
    // p1
    matadd_2x2 p11 (.A(A11_reg), .B(A22_reg), .C(add1[0]));
    matadd_2x2 p12 (.A(B11_reg), .B(B22_reg), .C(add1[1]));
    // p2
    matadd_2x2 p21 (.A(A21_reg), .B(A22_reg), .C(add1[2]));
    // p3
    matsub_2x2 p32 (.A(B12_reg), .B(B22_reg), .C(add1[3]));
    // p4
    matsub_2x2 p42 (.A(B21_reg), .B(B11_reg), .C(add1[4]));
    // p5
    matadd_2x2 p51 (.A(A11_reg), .B(A12_reg), .C(add1[5]));
    // p6
    matsub_2x2 p61 (.A(A21_reg), .B(A11_reg), .C(add1[6]));
    matadd_2x2 p62 (.A(B11_reg), .B(B12_reg), .C(add1[7]));
    // p7
    matsub_2x2 p71 (.A(A12_reg), .B(A22_reg), .C(add1[8]));
    matadd_2x2 p72 (.A(B21_reg), .B(B22_reg), .C(add1[9]));
    
    logic mrstn, mstart;
    logic [6:0] mvalid;

    // mat muls - 7 strassens
    matmul_2x2 p1 (.A(add1_reg[0]), .B(add1_reg[1]), .C(mul1[0]), .clk(clk), .rstn(mrstn), .start(mstart), .valid(mvalid[0]));
    matmul_2x2 p2 (.A(add1_reg[2]), .B(B11_reg), .C(mul1[1]), .clk(clk), .rstn(mrstn), .start(mstart), .valid(mvalid[1]));    
    matmul_2x2 p3 (.A(A11_reg), .B(add1_reg[3]), .C(mul1[2]), .clk(clk), .rstn(mrstn), .start(mstart), .valid(mvalid[2]));
    matmul_2x2 p4 (.A(A22_reg), .B(add1_reg[4]), .C(mul1[3]), .clk(clk), .rstn(mrstn), .start(mstart), .valid(mvalid[3]));
    matmul_2x2 p5 (.A(add1_reg[5]), .B(B11_reg), .C(mul1[4]), .clk(clk), .rstn(mrstn), .start(mstart), .valid(mvalid[4]));
    matmul_2x2 p6 (.A(add1_reg[6]), .B(add1_reg[7]), .C(mul1[5]), .clk(clk), .rstn(mrstn), .start(mstart), .valid(mvalid[5]));
    matmul_2x2 p7 (.A(add1_reg[8]), .B(add1_reg[9]), .C(mul1[6]), .clk(clk), .rstn(mrstn), .start(mstart), .valid(mvalid[6]));    
    
    // final addition set 1
    matadd_2x2 #(.BIT_PREC(2*BIT_PREC+1)) q11 (.A(mul1_reg[0]), .B(mul1_reg[3]), .C(add2[0]));
    matsub_2x2 #(.BIT_PREC(2*BIT_PREC+1)) q12 (.A(mul1_reg[6]), .B(mul1_reg[4]), .C(add2[1]));
    matsub_2x2 #(.BIT_PREC(2*BIT_PREC+1)) q41 (.A(mul1_reg[0]), .B(mul1_reg[1]), .C(add2[2]));
    matadd_2x2 #(.BIT_PREC(2*BIT_PREC+1)) q42 (.A(mul1_reg[2]), .B(mul1_reg[5]), .C(add2[3]));
    
    // final addition set 2
    matadd_2x2 #(.BIT_PREC(2*BIT_PREC+1)) q1 (.A(add2_reg[0]), .B(add2_reg[1]), .C(add3[0]));
    matadd_2x2 #(.BIT_PREC(2*BIT_PREC+1)) q2 (.A(mul1_reg[2]), .B(mul1_reg[4]), .C(add3[1]));
    matadd_2x2 #(.BIT_PREC(2*BIT_PREC+1)) q3 (.A(mul1_reg[1]), .B(mul1_reg[3]), .C(add3[2]));
    matadd_2x2 #(.BIT_PREC(2*BIT_PREC+1)) q4 (.A(add2_reg[2]), .B(add2_reg[3]), .C(add3[3]));
    
//    always_ff @(posedge clk or negedge rstn) begin
//    if (!rstn) begin
//        add2_reg <= '{default:0};
//        mul1_reg <= '{default:0};
//    end else if (state == ADD2) begin
//        add2_reg <= add2;
//        mul1_reg <= mul1;
//    end
//    end
    assign valid = (state == ADD3);
    
    typedef enum logic [2:0] {IDLE, ADD1, MUL1, ADD2, ADD3} state_type;
    state_type state;
    
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            mrstn <= 0;
            mstart <= 0;
        end else case (state) 
            IDLE: begin
                mrstn <= 1;
                if (start) state <= ADD1;
                end
            ADD1: begin
                add1_reg <= add1;
                state <= MUL1;
                
                end
            MUL1: begin
                mstart <= 1;
                if (&mvalid) begin
                    mstart <= 0;
                    state <= ADD2;
                    mul1_reg <= mul1;
                    end
                end
            ADD2: begin
                #10
                mstart <= 0; 
                add2_reg <= add2;
                state <= ADD3;
                end
            ADD3: begin
//                add3 <= add30;
            C[0][0] <= add3[0][0][0]; C[0][1] <= add3[0][0][1];       C[0][2] <= add3[1][0][0]; C[0][3] <= add3[1][0][1];
            C[1][0] <= add3[0][1][0]; C[1][1] <= add3[0][1][1];       C[1][2] <= add3[1][1][0]; C[1][3] <= add3[1][1][1];    
            C[2][0] <= add3[2][0][0]; C[2][1] <= add3[2][0][1];       C[2][2] <= add3[3][0][0]; C[2][3] <= add3[3][0][1];
            C[3][0] <= add3[2][1][0]; C[3][1] <= add3[2][1][1];       C[3][2] <= add3[3][1][0]; C[3][3] <= add3[3][1][1];
                state <= IDLE;
                end
        endcase 
    end    
    
//    // output decoder
//    always_ff @(posedge clk or negedge rstn) begin
//    if (!rstn) begin
//        C <= '{default:'0};
//        valid <= 0;
//    end
//    else begin
        
//        if (state == ADD3) begin
//            C[0][0] <= add3[0][0][0]; C[0][1] <= add3[0][0][1];       C[0][2] <= add3[1][0][0]; C[0][3] <= add3[1][0][1];
//            C[1][0] <= add3[0][1][0]; C[1][1] <= add3[0][1][1];       C[1][2] <= add3[1][1][0]; C[1][3] <= add3[1][1][1];    
//            C[2][0] <= add3[2][0][0]; C[2][1] <= add3[2][0][1];       C[2][2] <= add3[3][0][0]; C[2][3] <= add3[3][0][1];
//            C[3][0] <= add3[2][1][0]; C[3][1] <= add3[2][1][1];       C[3][2] <= add3[3][1][0]; C[3][3] <= add3[3][1][1];
//            end
//        end
//    end
endmodule

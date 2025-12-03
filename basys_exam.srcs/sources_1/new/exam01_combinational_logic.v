`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2025 11:37:33 AM
// Design Name: 
// Module Name: exam01_combinational_logic
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

// 구조적 모델링
module half_adder_structural(
    input A, B,
    output sum, carry);

    // XOR 내장 함수임 항상 출력이 첫 번째 인자로
    xor(sum, A, B);
    and(carry, A, B);

endmodule

// 동작점 모델링
module half_adder_behavioral(
    input A, B,
    output reg sum, carry);
    
    // 특정 구간에서 실행 A, B가 지정된 신호
    always @(A, B)begin
        case({A, B})
            2'b00: begin
                sum = 0;
                carry = 0;
            end
            2'b01: begin
                sum = 1;
                carry = 0;
            end
            2'b10: begin
                sum = 1;
                carry = 0;
            end
            2'b11: begin
                sum = 0;
                carry = 1;
            end
        endcase
    end

endmodule

// 데이터 플로우 모델링
module half_adder_dataflow(
    input A, B,
    output sum, carry);
    
    wire [1:0] sum_value;
    
    assign sum_value = A + B;
    assign sum = sum_value[0];
    assign carry = sum_value[1];
    
endmodule

module full_adder_behavioral(
    input A, B, carry_in,
    output reg sum, carry);
    
        always @(A, B, carry_in)begin
        case({A, B, carry_in})
            3'b000: begin sum = 0; carry = 0; end
            3'b001: begin sum = 1; carry = 0; end
            3'b010: begin sum = 1; carry = 0; end
            3'b011: begin sum = 0; carry = 1; end
            3'b100: begin sum = 1; carry = 0; end
            3'b101: begin sum = 0; carry = 1; end
            3'b110: begin sum = 0; carry = 1; end
            3'b111: begin sum = 1; carry = 1; end

        endcase
    end
    
endmodule

module full_adder_structural(
    input A, B, carry_in,
    output wire sum, carry);
    
    // 입력 연결 .A << module의 A값 / (A) 현재 input 값
    wire sum_0, carry_0, carry_1;
    half_adder_structural ha1(.A(A), .B(B), .sum(sum_0), .carry(carry_0));
    half_adder_structural ha2(.A(sum_0), .B(carry_in), .sum(sum), .carry(carry_1));
    
    or(carry, carry_0, carry_1);
    
endmodule

module full_adder_dataflow(
    input A, B, carry_in,
    output sum, carry);
    
    wire [1:0] sum_value;
    
    assign sum_value = A + B + carry_in;
    assign sum = sum_value[0];
    assign carry = sum_value[1];
    
endmodule

// wire는 생략 가능
// 비트 사이즈는 변수 앞에 선언
module fadder_4bit_structural(
    input wire [3:0] A, B,
    output [3:0] sum,
    output carry);
    
    wire carry_1, carry_2, carry_3;
    
    // 다음 자릿수의 carry_in은 이전 carry 값으로
    full_adder_behavioral fa0(.A(A[0]), .B(B[0]), .carry_in(0), .sum(sum[0]), .carry(carry_1));
    full_adder_behavioral fa1(.A(A[1]), .B(B[1]), .carry_in(carry_1), .sum(sum[1]), .carry(carry_2));
    full_adder_behavioral fa2(.A(A[2]), .B(B[2]), .carry_in(carry_2), .sum(sum[2]), .carry(carry_3));
    full_adder_behavioral fa3(.A(A[3]), .B(B[3]), .carry_in(carry_3), .sum(sum[3]), .carry(carry));
    
//    이런 식으로도 작성 가능 
//    wire [2:0] carry_w;
    
//    full_adder_behavioral fa0(.A(A[0]), .B(B[0]), .carry_in(0), .sum(sum[0]), .carry(carry_w[0]));
//    full_adder_behavioral fa1(.A(A[1]), .B(B[1]), .carry_in(carry_w[0]), .sum(sum[1]), .carry(carry_w[1]));
//    full_adder_behavioral fa2(.A(A[2]), .B(B[2]), .carry_in(carry_w[1]), .sum(sum[2]), .carry(carry_w[2]));
//    full_adder_behavioral fa3(.A(A[3]), .B(B[3]), .carry_in(carry_w[2]), .sum(sum[3]), .carry(carry));

endmodule

module fadder_4bit_dataflow(
    input [3:0] A, B,
    input carry_in,
    output [3:0] sum,
    output carry);
    
    wire [4:0] sum_value;
    
    assign sum_value = A + B + carry_in;
    assign sum = sum_value[3:0];
    assign carry = sum_value[4];
    
endmodule

module comparator(
    input A, B,
    output equal, not_equal, less, more);

    assign equal = (A == B);
    assign not_equal = (A != B);
    assign less = (A < B);
    assign more = (A > B);

endmodule

module encoder_4_2(
    input [3:0] signal,
    output reg [1:0] code);
    
//    assign code = (signal == 4'b0001) ? 2'b00 :
//                  (signal == 4'b0010) ? 2'b01 :
//                  (signal == 4'b0100) ? 2'b10 : 2'b11;

    always @(signal)begin
        if(signal == 4'b0001) code = 2'b00;
        else if(signal == 4'b0010) code = 2'b01;
        else if(signal == 4'b0100) code = 2'b10;
        else if(signal == 4'b1000) code = 2'b11;
    end
                  
endmodule









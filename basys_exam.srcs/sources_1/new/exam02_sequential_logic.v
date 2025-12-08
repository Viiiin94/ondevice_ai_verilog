`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2025 02:06:29 PM
// Design Name: 
// Module Name: exam02_sequential_logic
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

module D_flip_flop_n(
    input d,
    input clk, reset_p, en,
    output reg q
    );
    
    // edge 트리거로 들어오면 flipflop이 생성됨
    always @(negedge clk, posedge reset_p)begin
        if(reset_p) q = 0;
        else if(en)q <= d;
    end

endmodule

module D_flip_flop_p(
    input d,
    input clk, reset_p, en,
    output reg q
    );
    
//    always문에 엣지쓰면 플립플롭이 만들어짐
//    always @(posedge clk, posedge reset_p)begin
//        //clk와 상관없이 q값이 0이 됨 reset우선
//        if(reset_p) q = 0;
//        else if(en)q <= d;
//    end

    always @(posedge clk)begin
        //clk에 맞춰 리셋됨
        if(reset_p) q = 0;
        else if(en)q <= d;
    end

endmodule

module T_flip_flop_n(
    input clk, reset_p,
    input en,
    input t,
    output reg q
    );
    
    always @(negedge clk, posedge reset_p)begin
        if(reset_p) q=0;
        else if(en)begin
            if(t) q = ~q;
        end
    end

endmodule

module T_flip_flop_p(
    input clk, reset_p,
    input en,
    input t,
    output reg q
    );
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) q=0;
        else if(en)begin
            if(t) q = ~q;
        end
    end

endmodule















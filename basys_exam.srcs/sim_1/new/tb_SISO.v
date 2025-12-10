`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2025 02:18:48 PM
// Design Name: 
// Module Name: tb_SISO
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


module tb_SISO();
    // input은 reg output은 wire
    reg clk, reset_p;
    reg d;
    reg en;
    wire f;
    
    localparam [7:0] data = 8'b1011_1100;
    
    SISO DUT(.clk(clk), .reset_p(reset_p), .d(d), .en(en), .f(f));
    
    // 초기값 설정
    initial begin
        clk = 0;
        reset_p = 1;
        en = 0;
    end
    
    // 5ns 
    always #5 clk = ~clk;
    
    integer i;
    initial begin
        #10;
        reset_p = 0; en = 1;
        for(i = 0; i < 8; i = i + 1) begin
            d = data[i];
            #10;
        end
        en = 0;
        #50;
        en = 1;
        #80;
        $stop;
    end
    
endmodule














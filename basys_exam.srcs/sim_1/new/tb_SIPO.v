`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2025 03:34:54 PM
// Design Name: 
// Module Name: tb_SIPO
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


module tb_SIPO();
    reg clk, reset_p;
    reg d;
    reg rd_en;
    wire [7:0] q;
    
    localparam [7:0] data = 8'b0101_1010;
    
    SIPO DUT(.clk(clk), .reset_p(reset_p), .d(d), .rd_en(rd_en), .q(q));
    
    initial begin
        clk = 0;
        reset_p = 1;
        rd_en = 0;
    end
    
    always #5 clk = ~clk;
    
    integer i;
    initial begin
        #10;
        reset_p = 0;
        for(i = 0; i < 8; i = i + 1) begin
            d = data[i];
            #10;
        end
        rd_en = 1;
        #20;
        rd_en = 0;
        #10;
        $stop;
    end 
    
endmodule

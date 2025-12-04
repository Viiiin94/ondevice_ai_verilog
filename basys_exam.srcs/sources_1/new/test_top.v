`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2025 09:15:45 AM
// Design Name: 
// Module Name: test_top
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

module test_top(
    input [15:0] slide,
    output [15:0] led);
    
    assign led = slide;
    
endmodule

module FND_top(
    input [3:0] hex_value,
    output [7:0] seg,
    output [3:0] com
    );
    
    seg_decoder seg_dc(.hex_value(hex_value), .seg(seg));
    assign com = 4'b0000;

endmodule



















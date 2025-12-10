`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2025 09:27:48 AM
// Design Name: 
// Module Name: tb_PISO
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


module tb_PISO();
    
    reg clk, reset_p;
    reg [7:0] d;
    reg shift_load;
    wire q;
    
    localparam data = 8'b1101_0011;
    
    PISO DUT(.clk(clk), .reset_p(reset_p), .d(d), .shift_load(shift_load), .q(q));
    
    initial begin
        clk = 0;
        reset_p = 1;
        shift_load = 0;
        d = 0;
    end
    
    always #5 clk = ~clk;
    
    integer i;
    initial begin
        #10;
        reset_p = 0; shift_load = 0;
        d = data;
        #10;
        shift_load = 1;
        #80;
        $stop;
    end
    
endmodule

























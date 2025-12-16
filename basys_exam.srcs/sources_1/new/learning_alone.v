`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2025 07:30:49 PM
// Design Name: 
// Module Name: learning_alone
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


module learning_alone(
    input [15:0] sw,
    output [15:0] led
    );
    
    wire [3:0] data_in;
    wire [1:0] sel;
    reg mux_out;
    
    assign data_in = sw[3:0];
    assign sel = sw[5:4];
    
    always @(*) begin
        case (sel)
            2'b00 : mux_out = data_in[0];
            2'b01 : mux_out = data_in[1];
            2'b10 : mux_out = data_in[2];
            2'b11 : mux_out = data_in[3];
            default : mux_out = 1'b0;
        endcase
    end
    
    assign led[0] = mux_out;
    
endmodule














`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2025 09:38:53 AM
// Design Name: 
// Module Name: exam03_var_module
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


module watch(
    input clk, reset_p,
    input [2:0] btn,
    output reg [7:0] sec, min
    );
    
    wire btn0_pedge, btn1_pedge, btn2_pedge;
    
    edge_detector_n n0(.clk(clk), .reset(reset_p), .cp(btn[0]), .p_edge(btn0_pedge));
    edge_detector_n n1(.clk(clk), .reset(reset_p), .cp(btn[1]), .p_edge(btn1_pedge));
    edge_detector_n n2(.clk(clk), .reset(reset_p), .cp(btn[2]), .p_edge(btn2_pedge));

    
    reg set_watch;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) set_watch <= 0;
        else if(btn0_pedge) set_watch <= ~set_watch;
    end 

    integer cnt_sysclk;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            cnt_sysclk = 0;
            sec = 0;
            min = 0;
        end
        else begin
            if(set_watch) begin
                if(btn1_pedge) begin
                    if(sec >= 59) sec = 0;
                    sec = sec + 1;
                end
                if(btn2_pedge) begin
                    if(min >= 59) min = 0;
                    min = min + 1;
                end
            end
            else begin
                // 1초
                if(cnt_sysclk == 27'd99_999_999) begin
                    cnt_sysclk = 0;
                    if(sec >= 59) begin
                        sec = 0;
                        if(min >= 59) min = 0;
                        else min = min + 1;
                    end
                    else sec = sec + 1;
                end
                else cnt_sysclk <= cnt_sysclk + 1;
            end
        end
    end
endmodule

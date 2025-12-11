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

module cook_timer(
    input clk, reset_p,
    input btn_start, inc_sec, inc_min, alarm_off,
    output reg [7:0] sec, min, 
    output reg alarm
);

    reg prev;
    wire btn_rise;
    // 핵심 포인트 새로운 펄스 검출기를 넣어 reg가 서로다른 always(flipflop)에서 값을 넣지 않게
    always @(posedge clk) prev <= btn_start;
    assign btn_rise = btn_start && ~prev;
    
    reg dcnt_set;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            dcnt_set <= 0;
            alarm <= 0;
        end
        else begin
            if(btn_start) begin
                dcnt_set <= ~dcnt_set;
            end

            if(sec == 0 && min == 0 && dcnt_set)begin
                dcnt_set <= 0;
                alarm <= 1;
            end

            if(alarm_off || inc_sec || inc_min || btn_rise) alarm <= 0;
        end
    end

    integer cnt_sysclk;
    reg [7:0] set_sec, set_min;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            cnt_sysclk <= 0;
            sec <= 0; min <= 0;
            set_sec <= 0;
            set_min <= 0;
        end
        else begin
            if(alarm_off && sec == 0 && min == 0) begin
                set_sec <= sec;
                set_min <= min;
            end
        
            if(dcnt_set) begin
                if(cnt_sysclk >= 99_999_999)begin
                     cnt_sysclk <= 0;
                     if(sec == 0 && min)begin
                        sec <= 59;
                        min <= min - 1;
                     end
                     else sec <= sec - 1;
                end
                else cnt_sysclk <= cnt_sysclk + 1;
            end
            else begin
                if(inc_sec) begin
                    if(sec >= 59) sec <= 0;
                    sec <= sec + 1;
                end
                if(inc_min) begin
                    if(min >= 59) min <= 0;
                    min <= min + 1;
                end
            end
        end
    end

endmodule
















`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2025 11:24:37 AM
// Design Name: 
// Module Name: mulit_func_top
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

module multifunction_watch_top(
    input clk, reset_p,
    input [3:0] button,
    input [15:0] sw,
    output [7:0] seg,
    output [3:0] com,
    output [15:0] led,
    output buz
    );
    
    localparam WATCH = 3'b001;
    localparam COOK_TIMER = 3'b010;
    localparam STOPWATCH = 3'b100;
    
    wire [3:0] btn_pedge, btn_nedge;
    button_ctr btnctr0(
    .clk(clk), .reset_p(reset_p),
    .btn(button[0]), .btn_pedge(btn_pedge[0]), .btn_nedge(btn_nedge[0]));
    button_ctr btnctr1(
    .clk(clk), .reset_p(reset_p),
    .btn(button[1]), .btn_pedge(btn_pedge[1]), .btn_nedge(btn_nedge[1]));
    button_ctr btnctr2(
    .clk(clk), .reset_p(reset_p),
    .btn(button[2]), .btn_pedge(btn_pedge[2]), .btn_nedge(btn_nedge[2]));
    button_ctr btnctr3(
    .clk(clk), .reset_p(reset_p),
    .btn(button[3]), .btn_pedge(btn_pedge[3]), .btn_nedge(btn_nedge[3]));
    
    reg [2:0] mode, next_mode;
    assign led[7:5] = mode;
    always @(negedge clk, posedge reset_p) begin
        if(reset_p) mode <= WATCH;
        else if(btn_pedge[3]) begin
            if(mode == WATCH) next_mode <= COOK_TIMER;
            else if(mode == COOK_TIMER) next_mode <= STOPWATCH;
            else if(mode == STOPWATCH) next_mode <= WATCH;
            else if(mode == COOK_TIMER && (btn_pedge[0] || btn_pedge[1] || btn_pedge[2])) next_mode <= WATCH;
        end
    end
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) mode <= WATCH;
        else if(btn_pedge[3])begin
            mode <= next_mode;
        end
    end
    
    reg [2:0] watch_btn, cook_btn, stopwatch_btn;
    always @(*) begin
        case(mode)
            WATCH: begin
                watch_btn = btn_pedge[2:0];
                cook_btn = 0;
                stopwatch_btn = 0;
            end
            COOK_TIMER: begin
                watch_btn = 0;
                cook_btn = btn_pedge[2:0];
                stopwatch_btn = 0;
            end
            STOPWATCH: begin
                watch_btn = 0;
                cook_btn = 0;
                stopwatch_btn = btn_pedge[2:0];
            end
        endcase
    end
    
    wire [7:0] watch_sec, watch_min;
    watch watch0(
    .clk(clk), .reset_p(reset_p),
    .btn(watch_btn), .sec(watch_sec), .min(watch_min));
    
    wire [7:0] cook_sec, cook_min;
    wire alarm;
    cook_timer ctimer(
    .clk(clk), .reset_p(reset_p),
    .btn_start(cook_btn[0]), .inc_sec(cook_btn[1]),
    .inc_min(cook_btn[2]), .alarm_off(sw[0]),
    .sec(cook_sec), .min(cook_min), 
    .alarm(alarm));
    
    wire [7:0] stopwatch_sec, stopwatch_msec;
    
    stop_watch swatch(
    .clk(clk), .reset_p(reset_p),
    .btn_start_stop(stopwatch_btn[0]), .btn_lap(stopwatch_btn[1]), .btn_clear(stopwatch_btn[2]),
    .sec(stopwatch_sec), .msec(stopwatch_msec));
    
    wire [7:0] bcd_low, bcd_high, bin_low, bin_high;
    
    assign bin_low = mode == COOK_TIMER ? cook_sec : 
                     mode == STOPWATCH ? stopwatch_msec : watch_sec;
                     
    assign bin_high = mode == COOK_TIMER ? cook_min : 
                      mode == STOPWATCH ? stopwatch_sec : watch_min;
                     
    bin_to_dec btd_sec(.bin(bin_low), .bcd(bcd_low));
    bin_to_dec btd_min(.bin(bin_high), .bcd(bcd_high));
    
    FND_ctr fnd(
    .clk(clk), .reset_p(reset_p),
    .fnd_value({bcd_high, bcd_low}),
    .seg(seg), .com(com));
    
    assign buz = alarm;
    assign led[0] = alarm;

endmodule














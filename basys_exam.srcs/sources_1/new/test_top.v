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
    input clk, reset_p,
    input [15:0] hex_value,
    output [7:0] seg,
    output [3:0] com
    );
    
    FND_ctr(
    .clk(clk),
    .reset_p(reset_p),
    .fnd_value(hex_value),
    .seg(seg),
    .com(com)
    );

endmodule


module watch_top(
    input clk, reset_p,
    input [3:0] button,
    output [7:0] seg,
    output [3:0] com
);

    
    wire [2:0] btn_pedge, btn_nedge;
    button_ctr btnctr0(
    .clk(clk),
    .reset_p(reset_p),
    .btn(button[0]),
    .btn_pedge(btn_pedge[0]),
    .btn_nedge(btn_nedge[0])
    );
    button_ctr btnctr1(
    .clk(clk),
    .reset_p(reset_p),
    .btn(button[1]),
    .btn_pedge(btn_pedge[1]),
    .btn_nedge(btn_nedge[1])
    );
    button_ctr btnctr2(
    .clk(clk),
    .reset_p(reset_p),
    .btn(button[2]),
    .btn_pedge(btn_pedge[2]),
    .btn_nedge(btn_nedge[2])
    );

    wire [7:0] sec, min;
    watch watch0(
    .clk(clk),
    .reset_p(reset_p),
    .btn(btn_pedge),
    .sec(sec),
    .min(min));
    
    wire [7:0] sec_bcd, min_bcd;
    bin_to_dec btd_sec(
    .bin(sec),
    .bcd(sec_bcd));
    
    bin_to_dec btd_min(
    .bin(min),
    .bcd(min_bcd));
                 
    FND_ctr fnd(
    .clk(clk),
    .reset_p(reset_p),
    .fnd_value({min_bcd, sec_bcd}),
    .seg(seg),
    .com(com));

endmodule

module cook_timer_top(
    input clk, reset_p,
    input [3:0] button,
    output [7:0] seg,
    output [3:0] com,
    output [15:0] led
);

    wire [3:0] btn_pedge, btn_nedge;
    button_ctr btnctr0(
    .clk(clk),
    .reset_p(reset_p),
    .btn(button[0]),
    .btn_pedge(btn_pedge[0]),
    .btn_nedge(btn_nedge[0])
    );
    button_ctr btnctr1(
    .clk(clk),
    .reset_p(reset_p),
    .btn(button[1]),
    .btn_pedge(btn_pedge[1]),
    .btn_nedge(btn_nedge[1])
    );
    button_ctr btnctr2(
    .clk(clk),
    .reset_p(reset_p),
    .btn(button[2]),
    .btn_pedge(btn_pedge[2]),
    .btn_nedge(btn_nedge[2])
    );
    button_ctr btnctr3(
    .clk(clk),
    .reset_p(reset_p),
    .btn(button[3]),
    .btn_pedge(btn_pedge[3]),
    .btn_nedge(btn_nedge[3])
    );

    wire [7:0] sec, min;
    wire alarm; // 1비트라도 wire 선언해서 연결하기
    cook_timer ctimer(
    .clk(clk), .reset_p(reset_p),
    .btn_start(btn_pedge[0]),
    .inc_sec(btn_pedge[1]),
    .inc_min(btn_pedge[2]),
    .alarm_off(btn_pedge[3]),
    .sec(sec), .min(min), 
    .alarm(alarm)
    );

    wire [7:0] sec_bcd, min_bcd;
    bin_to_dec btd_sec(
    .bin(sec),
    .bcd(sec_bcd));
    
    bin_to_dec btd_min(
    .bin(min),
    .bcd(min_bcd));

    FND_ctr fnd(
    .clk(clk),
    .reset_p(reset_p),
    .fnd_value({min_bcd, sec_bcd}),
    .seg(seg),
    .com(com));

    assign led[0] = alarm;


endmodule













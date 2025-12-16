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

module play_buzz_top(
    input clk, reset_p,
    output trans_cp
);

    freq_generator #(.FREQ(15_000)) fg(.clk(clk), .reset_p(reset_p), .trans_cp(trans_cp));

endmodule


module led_pwm_top(
    input clk, reset_p,
    output led_r, led_g, led_b,
    output [15:0] led,
    output [7:0] seg,
    output [3:0] com
);

    integer cnt;
    always @(posedge clk) cnt = cnt + 1;
    
    reg [7:0] cnt_200;
    reg flag;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            cnt_200 = 0;
            flag = 0;
        end
        else if(cnt[23] && flag == 0) begin
            flag = 1;
            if(cnt_200 >= 199) cnt_200 = 0;
            else cnt_200 = cnt_200 + 1;
        end
        else if(cnt[23] == 0) flag = 0;
    end
    
    pwm_Nfreq_Nstep led_pwm(.clk(clk), .reset_p(reset_p), .duty(cnt_200), .pwm(led[0]));
    
    pwm_Nfreq_Nstep led_pwm_red(.clk(clk), .reset_p(reset_p), .duty(cnt[27:20]), .pwm(led_r));
    pwm_Nfreq_Nstep led_pwm_green(.clk(clk), .reset_p(reset_p), .duty(cnt[28:21]), .pwm(led_g));
    pwm_Nfreq_Nstep led_pwm_blue(.clk(clk), .reset_p(reset_p), .duty(cnt[29:22]), .pwm(led_b));
    
    wire [15:0] bcd_duty;
     bin_to_dec btd_min(.bin(cnt_200), .bcd(bcd_duty));

    FND_ctr fnd(.clk(clk), .reset_p(reset_p),
                .fnd_value(bcd_duty),.seg(seg),.com(com));

endmodule

    module sg_90_top(
        input clk, reset_p,
        input [3:0] button,
        output sg90_pwm,
        output [7:0] seg,
        output [3:0] com
    );
    
        wire [3:0] btn_pedge, btn_nedge;
        button_ctr btnctr0(.clk(clk), .reset_p(reset_p),
        .btn(button[0]), .btn_pedge(btn_pedge[0]), .btn_nedge(btn_nedge[0]));
        button_ctr btnctr1(.clk(clk), .reset_p(reset_p),
        .btn(button[1]), .btn_pedge(btn_pedge[1]), .btn_nedge(btn_nedge[1]));
        button_ctr btnctr2(.clk(clk), .reset_p(reset_p),
        .btn(button[2]), .btn_pedge(btn_pedge[2]), .btn_nedge(btn_nedge[2]));
        button_ctr btnctr3(.clk(clk), .reset_p(reset_p),
        .btn(button[3]), .btn_pedge(btn_pedge[3]), .btn_nedge(btn_nedge[3]));
    
        reg [7:0] duty;
        always @(posedge clk, posedge reset_p) begin
            if(reset_p) duty <= 12;
            else begin
                if(btn_pedge[1] && duty > 3) duty <= duty - 1;
                if(btn_pedge[2] && duty < 24) duty <= duty + 1;
            end
        end
    
        pwm_Nfreq_Nstep #(.PWM_FREQ(50), .DUTY_STEP(180)) sg_pwm(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm(sg90_pwm));
        
        wire [15:0] bcd_duty;
        bin_to_dec btd_min(.bin(duty), .bcd(bcd_duty));
    
        FND_ctr fnd(.clk(clk), .reset_p(reset_p),
                    .fnd_value(bcd_duty), .seg(seg), .com(com));
    
    endmodule

































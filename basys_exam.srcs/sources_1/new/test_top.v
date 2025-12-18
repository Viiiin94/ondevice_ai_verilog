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


module adc_ch6_top(
    input clk, reset_p,
    input vauxp6, vauxn6,
    output [7:0] seg,
    output [3:0] com,
    output [15:0] led
);

    wire [4:0] channel_out;
    wire eoc_out;
    wire [15:0] do_out;
    xadc_wiz_0 adc_ch6
          (
          .daddr_in({2'b00, channel_out}),   // Address bus for the dynamic reconfiguration port
          .dclk_in(clk),                     // Clock input for the dynamic reconfiguration port
          .den_in(eoc_out),                  // Enable Signal for the dynamic reconfiguration port
          .reset_in(reset_p),                // Reset signal for the System Monitor control logic
          .vauxp6(vauxp6),                   // Auxiliary channel 6
          .vauxn6(vauxn6),
          .channel_out(channel_out),         // Channel Selection Outputs
          .do_out(do_out),                   // Output data bus for dynamic reconfiguration port
          .eoc_out(eoc_out)                  // End of Conversion Signal
          );
    
    wire eoc_out_pedge;
    edge_detector_n edn(.clk(clk), .reset(reset_p),
                        .cp(eoc_out),.p_edge(eoc_out_pedge));
                    
    reg [11:0] adc_value;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) adc_value = 0;
        else if(eoc_out_pedge) adc_value = do_out[15:4];
    end
    
    wire [15:0] bcd_adc_value;
    bin_to_dec btd(.bin(adc_value), .bcd(bcd_adc_value));
    
    FND_ctr fnd(.clk(clk), .reset_p(reset_p),
                .fnd_value(bcd_adc_value), .seg(seg), .com(com));
    
    assign led[0] = adc_value[11:8] >= 4'b0001;
    assign led[1] = adc_value[11:8] >= 4'b0010;
    assign led[2] = adc_value[11:8] >= 4'b0011;
    assign led[3] = adc_value[11:8] >= 4'b0100;
    assign led[4] = adc_value[11:8] >= 4'b0101;
    assign led[5] = adc_value[11:8] >= 4'b0110;
    assign led[6] = adc_value[11:8] >= 4'b0111;
    assign led[7] = adc_value[11:8] >= 4'b1000;
    assign led[8] = adc_value[11:8] >= 4'b1001;
    assign led[9] = adc_value[11:8] >= 4'b1010;
    assign led[10] = adc_value[11:8] >= 4'b1011;
    assign led[11] = adc_value[11:8] >= 4'b1100;
    assign led[12] = adc_value[11:8] >= 4'b1101;
    assign led[13] = adc_value[11:8] >= 4'b1110;
    assign led[14] = adc_value[11:8] >= 4'b1111;
endmodule


module adc_sequence_top(
    input clk, reset_p,
    input vauxp6, vauxn6, vauxp15, vauxn15,
    output [7:0] seg,
    output [3:0] com,
    output [15:0] led
    );
    
    wire [4:0] channel_out;
    wire eoc_out;
    wire [15:0] do_out;
    
    adc_2ch_sequence joystick
    (
    .daddr_in({2'b00, channel_out}),    // Address bus for the dynamic reconfiguration port
    .dclk_in(clk),                      // Clock input for the dynamic reconfiguration port
    .den_in(eoc_out),                   // Enable Signal for the dynamic reconfiguration port
    .reset_in(reset_p),                 // Reset signal for the System Monitor control logic
    .vauxp6(vauxp6),                    // Auxiliary channel 6
    .vauxn6(vauxn6),
    .vauxp15(vauxp15),                  // Auxiliary channel 15
    .vauxn15(vauxn15),
    .channel_out(channel_out),          // Channel Selection Outputs
    .do_out(do_out),                    // Output data bus for dynamic reconfiguration port
    .eoc_out(eoc_out)                   // End of Conversion Signal
    );
    
    reg [11:0] adc_valueX, adc_valueY;
    
    wire eoc_out_pedge;
    edge_detector_n edn(.clk(clk), .reset(reset_p),
                        .cp(eoc_out),.p_edge(eoc_out_pedge));
                    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            adc_valueX = 0; adc_valueY = 0;
        end
        else if(eoc_out_pedge) begin
            case (channel_out[3:0])
                6: adc_valueX <= do_out[15:4];
                15: adc_valueY <= do_out[15:4];
            endcase
        end   
    end
    
    wire [7:0] x_bcd, y_bcd;
    // 상위 6비트만 보내서 0~63 값을 출력하기 위해서
    bin_to_dec btd_x(.bin(adc_valueX[11:6]), .bcd(x_bcd));
    bin_to_dec btd_y(.bin(adc_valueY[11:6]), .bcd(y_bcd));
    
    FND_ctr fnd(.clk(clk), .reset_p(reset_p),
                .fnd_value({x_bcd, y_bcd}), .seg(seg), .com(com));        

    assign led[0] = adc_valueX[11:9] >= 8;
    assign led[1] = adc_valueX[11:9] >= 7;
    assign led[2] = adc_valueX[11:9] >= 6;
    assign led[3] = adc_valueX[11:9] >= 5;
    assign led[4] = adc_valueX[11:9] >= 4;
    assign led[5] = adc_valueX[11:9] >= 3;
    assign led[6] = adc_valueX[11:9] >= 2;
    assign led[7] = adc_valueX[11:9] >= 1;
    
    assign led[8]  = adc_valueY[11:9] >= 1;
    assign led[9]  = adc_valueY[11:9] >= 2;
    assign led[10] = adc_valueY[11:9] >= 3;
    assign led[11] = adc_valueY[11:9] >= 4;
    assign led[12] = adc_valueY[11:9] >= 5;
    assign led[13] = adc_valueY[11:9] >= 6;
    assign led[14] = adc_valueY[11:9] >= 7;
    assign led[15] = adc_valueY[11:9] >= 8;

endmodule

module ultra_sonic_top(
    input clk, reset_p,
    input echo, // 오타.....
    output trig,
    output [7:0] seg,
    output [3:0] com,
    output [15:0] led
);

    wire [8:0] distance_cm;
    hc_sr04 ultra(.clk(clk), .reset_p(reset_p), .echo(echo),
                  .trig(trig), .distance_cm(distance_cm));
                  
    wire [15:0] distance_bcd;
    bin_to_dec btd_ultra(.bin(distance_cm), .bcd(distance_bcd));
    
    FND_ctr fnd(.clk(clk), .reset_p(reset_p),
                .fnd_value(distance_bcd), .seg(seg), .com(com)); 

endmodule

module dht11_top(
    input clk, reset_p,
    inout dht11_data,
    output [7:0] seg,
    output [3:0] com,
    output [15:0] led
);

    wire [7:0] humidity, temperature;
    dht11_ctr dht(clk, reset_p, dht11_data, humidity, temperature, led);

    wire [7:0] humidity_bcd, temperature_bcd;
    bin_to_dec btd_humi(.bin(humidity), .bcd(humidity_bcd));
    bin_to_dec btd_tmpr(.bin(temperature), .bcd(temperature_bcd));
    
    FND_ctr fnd(.clk(clk), .reset_p(reset_p),
                .fnd_value({humidity_bcd, temperature_bcd}),
                .seg(seg), .com(com)); 

endmodule























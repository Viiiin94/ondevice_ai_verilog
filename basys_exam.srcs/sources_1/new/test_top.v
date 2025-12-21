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

module i2c_master_top(
    input clk, reset_p, 
    input sw, 
    input comm_start,
    output scl, sda,
    output [15:0] led
);
    localparam light_on  = 8'b0000_1000;
    localparam light_off = 8'b0000_0000;
    
    wire [7:0] data;
    wire busy;
    assign data = sw ? light_on : light_off;
    
    I2C_master i2c(clk, reset_p, 7'h27, data, 1'b0, comm_start, scl, sda, busy ,led);
    
endmodule


module i2c_txtlcd_top(
    input clk, reset_p,
    input [3:0] button,
    output scl, sda,
    output [15:0] led     
);

    wire [3:0] btn_pedge;
    button_ctr btnctr0(clk, reset_p, button[0], btn_pedge[0]);
    button_ctr btnctr1(clk, reset_p, button[1], btn_pedge[1]);
    button_ctr btnctr2(clk, reset_p, button[2], btn_pedge[2]);
    button_ctr btnctr3(clk, reset_p, button[3], btn_pedge[3]);
    
    integer cnt_sysclk;
    reg count_clk_e;
    always @(negedge clk, posedge reset_p) begin
        if(reset_p) begin
            cnt_sysclk = 0;
        end
        else if(count_clk_e) begin
            cnt_sysclk = cnt_sysclk + 1;
        end
        else begin
            cnt_sysclk = 0;
        end
    end
    
    reg [7:0] send_buffer;
    reg send, rs;
    wire busy;
    i2c_lcd_send_byte send_byte(clk, reset_p, 7'h27, send_buffer, send, rs,
                                scl, sda, busy, led);
                                
    localparam IDLE                 = 6'b00_0001;
    localparam INIT                 = 6'b00_0010;
    localparam SEND_CHARACTER       = 6'b00_0100;
    localparam SHIFT_RIGHT_DISPLAY  = 6'b00_1000;
    localparam SHIFT_LEFT_DISPLAY   = 6'b01_0000;
    
    reg [5:0] state, next_state;
    always @(negedge clk, posedge reset_p) begin
        if(reset_p) begin
            state = IDLE;
        end
        else begin
            state = next_state;
        end
    end
    
    reg init_flag;
    reg [10:0] cnt_data;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            next_state = IDLE;
            init_flag = 0;
            cnt_data = 0;
            count_clk_e = 0;
            send = 0;
            send_buffer = 0;
            rs = 0;
        end
        else begin
            case(state)
                IDLE                : begin
                    // before start, wait 40ms but, wait leisurely 80ms
                    if(init_flag) begin
                        if(btn_pedge[0]) begin
                            next_state = SEND_CHARACTER;
                        end
                        if(btn_pedge[1]) begin
                            next_state = SHIFT_LEFT_DISPLAY;
                        end
                        if(btn_pedge[2]) begin
                            next_state = SHIFT_RIGHT_DISPLAY;
                        end
                    end
                    else begin
                        if(cnt_sysclk <= 8_000_000) begin
                            count_clk_e = 1;    
                        end
                        else begin
                            count_clk_e = 0;
                            next_state = INIT;
                        end
                    end
                end    
                INIT                : begin
                    if(busy) begin
                        send = 0;
                        if(cnt_data >= 6) begin
                            cnt_data = 0;
                            next_state = IDLE;
                            init_flag = 1;
                        end
                    end
                    else if(!send) begin
                        case(cnt_data)
                            0: send_buffer = 8'h33;
                            1: send_buffer = 8'h32;
                            2: send_buffer = 8'h28;
                            3: send_buffer = 8'h0f;
                            4: send_buffer = 8'h01;
                            5: send_buffer = 8'h06;
                        endcase
                        send = 1;
                        cnt_data = cnt_data + 1;
                    end
                end
                SEND_CHARACTER      : begin
                    if(busy) begin
                        if(cnt_data >= 9) begin
                            cnt_data = 0;
                        end
                        send = 0;
                        next_state = IDLE;
                    end
                    else if(!send) begin
                        rs = 1;
                        send_buffer = "0" + cnt_data;
                        send = 1;
                        cnt_data = cnt_data + 1;
                    end
                
                end
                SHIFT_RIGHT_DISPLAY : begin
                    if(busy) begin 
                        send = 0;
                        next_state = IDLE;
                    end
                    else if(!send) begin
                        rs = 0;
                        send_buffer = 8'h1C;
                        send = 1;
                    end
                end
                SHIFT_LEFT_DISPLAY  : begin
                    if(busy) begin 
                        send = 0;
                        next_state = IDLE;
                    end
                    else if(!send) begin
                        rs = 0;
                        send_buffer = 8'h18;
                        send = 1;
                    end
                end
            endcase
        end
    end

endmodule

module three_led_top(
    input clk, reset_p,
    input [2:0] button,
    output led_r, led_g, led_b,
    output [15:0] led,
    output [7:0] seg,
    output [3:0] com
);

// 1. 모드 정의
    localparam MODE_COLOR_CYCLE = 3'b001; // 버튼 0: 색상 자동 순환
    localparam MODE_DIMMING     = 3'b010; // 버튼 1: 숨쉬기
    localparam MODE_FAST_BLINK  = 3'b100; // 버튼 2: 빠르게 깜빡임
    
    reg [2:0] current_mode;
    reg [1:0] color_sel;

    wire [2:0] btn_pedge;
    button_ctr btn_cycle(clk, reset_p, button[0], btn_pedge[0]);
    button_ctr btn_dimming(clk, reset_p, button[1], btn_pedge[1]);
    button_ctr btn_blink(clk, reset_p, button[2], btn_pedge[2]);
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            current_mode <= MODE_COLOR_CYCLE;
            color_sel <= 0; 
        end
        else begin
            // [버튼 0] 색상 변경 (R->G->B->R...)
            if (btn_pedge[0]) begin
                if(color_sel >= 2) color_sel <= 0;
                else color_sel <= color_sel + 1;
            end
            // [버튼 1] 서서히 켜졌다 꺼짐
            else if (btn_pedge[1]) begin 
                if (current_mode == MODE_DIMMING) begin
                    current_mode <= MODE_COLOR_CYCLE; // 이미 켜져있으면 -> 끔 (기본모드 복귀)
                end
                else begin
                    current_mode <= MODE_DIMMING;
                end
            end
            // [버튼 2] 빠르게 깜빡
            else if (btn_pedge[2]) begin 
                // 이미 깜빡임 모드라면? -> 기본 모드(그냥 켜짐)로 복귀
                if (current_mode == MODE_FAST_BLINK) begin
                    current_mode <= MODE_COLOR_CYCLE;
                end
                // 아니라면? -> 깜빡임 모드 진입
                else begin
                    current_mode <= MODE_FAST_BLINK;
                end
            end
        end
    end
    
    reg [7:0] duty_count;
    reg dimming_state;
    reg [23:0] dimming_duty_count;
    
    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            duty_count <= 0;
            dimming_state <= 0;
            dimming_duty_count <= 0;
        end
        else begin
            if (dimming_duty_count >= 24'd250_000) begin 
                dimming_duty_count <= 0;
                if (dimming_state == 0) begin // 밝아지는 중
                    if (duty_count == 8'd255) dimming_state <= 1;
                    else duty_count <= duty_count + 1;
                end
                else begin // 어두워지는 중
                    if (duty_count == 8'd0) dimming_state <= 0;
                    else duty_count <= duty_count - 1;
                end
            end
            else begin
                dimming_duty_count <= dimming_duty_count + 1;
            end
        end
    end
    
    reg blink_on_off;
    reg [23:0] blink_timer;
    
    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            blink_on_off <= 0;
            blink_timer <= 0;
        end
        else begin
            if (blink_timer >= 24'd5_000_000) begin 
                blink_timer <= 0;
                blink_on_off <= ~blink_on_off;
            end
            else begin
                blink_timer <= blink_timer + 1;
            end
        end
    end
    
    reg [7:0] r_duty, g_duty, b_duty;
    always @(*) begin
        r_duty = 0; g_duty = 0; b_duty = 0;

        case(current_mode)
            // 모드 1: 수동 색상 변경 (버튼 0)
            MODE_COLOR_CYCLE: begin
                case(color_sel)
                    0: r_duty = 255; // Red
                    1: g_duty = 255; // Green
                    2: b_duty = 255; // Blue
                    default: begin r_duty=0; g_duty=0; b_duty=0; end
                endcase
            end

            // 모드 2: 숨쉬기 (버튼 1)
            MODE_DIMMING: begin
                case(color_sel)
                    0: r_duty = duty_count; // Red
                    1: g_duty = duty_count; // Green
                    2: b_duty = duty_count; // Blue
                    default: begin r_duty=0; g_duty=0; b_duty=0; end
                endcase
            end

            // 모드 3: 빠른 깜빡임 (버튼 2)
            MODE_FAST_BLINK: begin
                // blink_on_off가 1이면 최대 밝기, 0이면 꺼짐
                if(blink_on_off) begin
                    case(color_sel)
                        0: r_duty = 255; // Red
                        1: g_duty = 255; // Green
                        2: b_duty = 255; // Blue
                        default: begin r_duty=0; g_duty=0; b_duty=0; end
                    endcase
                end
                else begin
                    r_duty = 0; g_duty = 0; b_duty = 0;
                end
            end
        endcase
    end
    
    pwm_Nfreq_Nstep led_pwm_red(.clk(clk), .reset_p(reset_p), .duty(r_duty), .pwm(led_r));
    pwm_Nfreq_Nstep led_pwm_green(.clk(clk), .reset_p(reset_p), .duty(g_duty), .pwm(led_g));
    pwm_Nfreq_Nstep led_pwm_blue(.clk(clk), .reset_p(reset_p), .duty(b_duty), .pwm(led_b));    
endmodule

module prototype_sensor_test(
    input clk, reset_p,
    inout dht11_data,
    input echo,
    output trig,
    output [7:0] humidity, temperature,
    output [8:0] distance_cm
);

    dht11_ctr dht(clk, reset_p, dht11_data, humidity, temperature);
    
    hc_sr04 ultra(.clk(clk), .reset_p(reset_p), .echo(echo),
                  .trig(trig), .distance_cm(distance_cm));
                  
endmodule












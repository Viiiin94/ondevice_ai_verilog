`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2025 03:32:05 PM
// Design Name: 
// Module Name: controller
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


module FND_ctr(
    input clk, reset_p,
    input [15:0] fnd_value,
    output [7:0] seg,
    output reg [3:0] com
    );
    
    reg [16:0] clk_div;
    always @(posedge clk) clk_div <= clk_div + 1;
    
    wire clk_div_ed;
    edge_detector_n(
    .clk(clk),
    .reset(reset_p),
    .cp(clk_div[16]),
    .p_edge(clk_div_ed)
    );
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) com <= 4'b1110;
        else begin
            if(com[0] + com[1] + com[2] + com[3] != 3) com <= 4'b1110;
            else if (clk_div_ed) begin 
                com <= {com[2:0], com[3]};
            end
        end
    end
    
    reg [3:0] digit_value;
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) digit_value = 0;
        else begin
            case(com)
                4'b1110: digit_value = fnd_value[3:0];
                4'b1101: digit_value = fnd_value[7:4];
                4'b1011: digit_value = fnd_value[11:8];
                4'b0111: digit_value = fnd_value[15:12];
            endcase
        end
    end

    
    seg_decoder(
    .hex_value(digit_value),
    .seg(seg)
    );
endmodule


module freq_generator(
    input clk, reset_p,
    output reg trans_cp
);
    
    parameter FREQ = 1_000_000;
    parameter SYS_FREQ = 100_000_000;
    parameter HALF_PERIOD = SYS_FREQ / FREQ / 2 - 1;
    
    integer cnt;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) begin
            cnt = 0;
            trans_cp = 0;
        end
        else begin
            // 100ns 주기를 갖게 하는 카운터(0 5번, 1 5번) // 1000ns는 49 
            if(cnt >= HALF_PERIOD) begin
                cnt = 0;
                trans_cp = ~trans_cp;
            end
            else cnt = cnt + 1;
        end
    end
endmodule

module pwm_Nfreq_Nstep(
    input clk, reset_p,
    input [31:0] duty,
    output reg pwm
);

    parameter SYS_CLK_FREQ = 100_000_000;
    parameter PWM_FREQ = 10_000;
    parameter DUTY_STEP = 200;
    parameter TEMP = SYS_CLK_FREQ / (PWM_FREQ * DUTY_STEP) / 2 - 1;
    
    integer cnt;
    reg pwm_freqXstep;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            cnt <= 0;
            pwm_freqXstep <= 0;
        end
        else begin
            if(cnt >= TEMP) begin
                cnt <= 0;
                pwm_freqXstep <= ~pwm_freqXstep;
            end
            else cnt <= cnt + 1;
        end
    end
    
    wire pwm_freqXstep_pedge;
    
    edge_detector_n edn(.clk(clk), .reset(reset_p), .cp(pwm_freqXstep), .p_edge(pwm_freqXstep_pedge));
    integer cnt_duty;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            cnt_duty <= 0;
            pwm <= 0;
        end
        else if(pwm_freqXstep_pedge) begin
            if(cnt_duty >= DUTY_STEP - 1) cnt_duty <= 0;
            else cnt_duty <= cnt_duty + 1;
            
            if(cnt_duty < duty) pwm <= 1;
            else pwm <= 0;
        end
    end

endmodule

module hc_sr04(
    input clk, reset_p,
    input echo,
    output reg trig,
    output reg [8:0] distance_cm
);

    integer cnt_sysclk, cnt_sysclk0, cnt_usec;
    reg count_usec_e;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            cnt_sysclk0 = 0;
            cnt_usec = 0;
        end
        else if(count_usec_e) begin
            if(cnt_sysclk0 >= 99) begin
                cnt_sysclk0 = 0;
                cnt_usec = cnt_usec + 1;
            end
            else cnt_sysclk0 = cnt_sysclk0 + 1;        
        end
        else begin
            cnt_sysclk0 = 0;
            cnt_usec = 0;
        end
    end
    
    always @(posedge clk) cnt_sysclk = cnt_sysclk + 1;
    
    wire cnt9_pedge, cnt26_pedge;
    edge_detector_n ed26(.clk(clk), .reset(reset_p), .cp(cnt_sysclk[24]), .p_edge(cnt26_pedge)); // 26번째 비트 약 1sec
    edge_detector_n ed9(.clk(clk), .reset(reset_p), .cp(cnt_sysclk[9]), .p_edge(cnt9_pedge));    // 9번째 비트 약 10us

    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) trig = 0;
        else if(cnt26_pedge) trig = 1;
        else if(cnt9_pedge) trig = 0;
    end
    
    wire echo_pedge, echo_nedge;
    edge_detector_n ed_echo(.clk(clk), .reset(reset_p), .cp(echo), .p_edge(echo_pedge), .n_edge(echo_nedge));
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            count_usec_e = 0;
            distance_cm = 0;
        end
        else if(echo_pedge) begin
            count_usec_e = 1;
        end
        else if(echo_nedge) begin
            distance_cm = cnt_usec / 58;
            count_usec_e = 0;
        end
    end
endmodule





















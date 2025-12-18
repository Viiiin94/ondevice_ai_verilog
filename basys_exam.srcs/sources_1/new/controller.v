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

    localparam TIME_1CM = 58;

    integer cnt_sysclk, cnt_sysclk0, cnt_usec;
    reg count_usec_e;
    reg [8:0] cnt_cm;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            cnt_sysclk0 = 0;
            cnt_usec = 0;
        end
        else if(count_usec_e) begin
            if(cnt_sysclk0 >= 99) begin
                cnt_sysclk0 = 0;
                if(cnt_usec >= TIME_1CM - 1) begin
                    cnt_usec = 0;
                    cnt_cm = cnt_cm + 1; // 나눗셈을 이용한게 아니라 분주를 생성해서 나눗셈 처럼 처리
                end
                cnt_usec = cnt_usec + 1;
            end
            else cnt_sysclk0 = cnt_sysclk0 + 1;        
        end
        else begin
            cnt_sysclk0 = 0;
            cnt_usec = 0;
            cnt_cm = 0;
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
            distance_cm = 0;
            count_usec_e = 0;
            // distance_cm = 0;
        end
        else if(echo_pedge) begin
            count_usec_e = 1;
        end
        else if(echo_nedge) begin
            // distance_cm = cnt_usec / 58; // 나눗셈을 하면 여유분이 모자람 (negative slack)
            distance_cm = cnt_cm;
            count_usec_e = 0;
        end
    end
endmodule

module dht11_ctr(
    input clk, reset_p,
    inout dht11_data,
    output reg [7:0] humidity, temperature,
    output [15:0] led    
);
    // 데이터를 주고 받기까지의 시작 전 단계
    localparam S_IDLE       = 6'b00_0001;
    localparam S_LOW_18MS   = 6'b00_0010;
    localparam S_HIGH_20US  = 6'b00_0100;
    localparam S_LOW_80US   = 6'b00_1000;
    localparam S_HIGH_80US  = 6'b01_0000;
    localparam S_READ_DATA  = 6'b10_0000;

    // 데이터를 주고 받을 때의 상승 하강 엣지 상태
    localparam S_WAIT_PEDGE = 2'b01;
    localparam S_WAIT_NEDGE = 2'b10;

    // nedge us 단위
    wire clk_usec_nedge;
    clock_usec usec_clk(.clk(clk), .reset_p(reset_p),
                        .clk_usec_nedge(clk_usec_nedge));

    reg [21:0] count_usec;
    reg count_usec_e;

    // us 카운터 레지스터
    always @(negedge clk, posedge reset_p) begin
        if(reset_p) count_usec = 0;
        else if(clk_usec_nedge && count_usec_e) count_usec = count_usec + 1;
        else if(!count_usec_e) count_usec = 0;
    end

    // dht11의 상승 하강 엣지
    wire dht_nedge, dht_pedge;
    edge_detector_p ed(.clk(clk), .reset(reset_p),
                       .cp(dht11_data), .p_edge(dht_pedge),
                       .n_edge(dht_nedge));

    reg dht11_data_buffer, dht11_data_out_e;
    // 출력을 내보내고 싶다면 buffer 아니면 임피던스
    assign dht11_data = dht11_data_out_e ? dht11_data_buffer : 'bz;
    
    reg [5:0] state, next_state;
    always @(negedge clk, posedge reset_p) begin
        if(reset_p) state = S_IDLE;
        else state = next_state;
    end
    reg [39:0] temp_data;
    reg [5:0] cnt_data;
    assign led[15:10] = state;
    reg [1:0] read_state;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            next_state = S_IDLE;
            temp_data = 0;
            cnt_data = 0;
            count_usec_e = 0;
            dht11_data_out_e = 0;
            dht11_data_buffer = 0;
            read_state = S_WAIT_PEDGE;
        end
        else begin
            case(state)
                S_IDLE: begin
                    // 3초간 
                    if(count_usec < 22'd3_000_000) begin
                        count_usec_e = 1;
                        dht11_data_out_e = 0;
                    end
                    else begin
                        count_usec_e = 0;
                        next_state = S_LOW_18MS;
                    end
                end
                S_LOW_18MS: begin
                    // 여유있게 20ms
                    if(count_usec < 22'd20_000)begin
                        count_usec_e = 1;
                        dht11_data_out_e = 1;
                        dht11_data_buffer = 0;
                    end
                    else begin
                        count_usec_e = 0;
                        dht11_data_out_e = 0;
                        next_state = S_HIGH_20US;
                    end
                end
                S_HIGH_20US: begin
                    // 여기까지 MCU가 dht11에게 보내는 신호 분주를 줘서 상태를 바꿈
                    if(count_usec < 22'd20)begin
                        count_usec_e = 1;
                    end
                    else begin
                        if(dht_nedge) begin
                            count_usec_e = 0;
                            next_state = S_LOW_80US;
                        end
                    end
                end
                S_LOW_80US: begin
                    // 여기서는 dht11로 신호를 받기 때문에 시간을 넣기보단 엣지될 때까지 기다렸다 상태 변환
                    if(dht_pedge) begin
                        next_state = S_HIGH_80US;
                    end
                end 
                S_HIGH_80US: begin
                    // 여기도 마찬가지
                    if(dht_nedge) begin
                        next_state = S_READ_DATA;
                    end
                end
                S_READ_DATA: begin
                    case(read_state)
                        S_WAIT_PEDGE: begin
                            if(dht_pedge) read_state = S_WAIT_NEDGE;
                            count_usec_e = 0;
                        end
                        S_WAIT_NEDGE: begin
                            count_usec_e = 1;
                            if(dht_nedge) begin
                                if(count_usec < 50) temp_data = {temp_data[38:0] , 1'b0};
                                else temp_data = {temp_data[38:0] , 1'b1};
                                cnt_data = cnt_data + 1;
                                read_state = S_WAIT_PEDGE;
                            end
                        end
                        default: read_state = S_WAIT_PEDGE;
                    endcase
                    if(cnt_data >= 39) begin
                        next_state = S_IDLE;
                        cnt_data = 0;
                        humidity = temp_data[39:32];
                        temperature = temp_data[23:16];
                    end
                end
                default: next_state = S_IDLE;
            endcase
        end
    end
endmodule



















`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2025 02:13:42 PM
// Design Name: 
// Module Name: stop_watch
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

module stop_watch_top(
    input clk, reset_p,
    input [3:0] button,
    output [7:0] seg,
    output [3:0] com
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
    
    wire [7:0] sec, msec;
    stop_watch swatch(
    .clk(clk), .reset_p(reset_p),
    .btn_start_stop(btn_pedge[0]), .btn_lap(btn_pedge[1]), .btn_clear(btn_pedge[2]),
    .sec(sec), .msec(msec)
    );
    
    wire [7:0] sec_bcd, msec_bcd;
    bin_to_dec btd_sec(
    .bin(sec),
    .bcd(sec_bcd));
    
    bin_to_dec btd_min(
    .bin(msec),
    .bcd(msec_bcd));

    FND_ctr fnd(
    .clk(clk),
    .reset_p(reset_p),
    .fnd_value({sec_bcd, msec_bcd}),
    .seg(seg),
    .com(com));

endmodule

module stop_watch(
    input clk, reset_p,
    input btn_start_stop, btn_lap ,btn_clear, // 시작정지, 랩 타임 저장, 랩 타임 클리어 버튼
    output [7:0] sec, msec
    );
        
    integer cnt_sysclk;
    reg cnt_start, view_time; // 랩타임 시작, 정지 유무 레지스터
    reg [7:0] set_sec, set_msec, save_sec, save_msec; // 실제 작동중인 시간, 랩타임 저장 시간 레지스터
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            cnt_start <= 0;
            view_time <= 0;
        end
        else begin
            if(btn_clear && !cnt_start) begin // 랩 타임 초기화
                cnt_start <= 0;
                view_time <= 0;
            end
            else if(btn_start_stop) begin // 시작 정지 버튼 토글 
                cnt_start <= ~cnt_start;
                view_time <= ~view_time;
            end
            else if(set_sec >= 59 && set_msec >= 99) begin // 59.99가 되면 스탑워치 정지
                cnt_start <= 0; 
            end
        end
    end
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            set_sec <= 0; set_msec <= 0;
            save_sec <= 0; save_msec <= 0;
            cnt_sysclk <= 0;
        end
        else begin
            if(btn_clear && !cnt_start) begin // 랩 타임 초기화
                save_sec <= 0; save_msec <= 0;
                cnt_sysclk <= 0;
            end
        
            else if(cnt_start) begin // 시작
                if(btn_lap) begin // 동작 중일 때만 랩타임 저장
                    save_sec <= set_sec;
                    save_msec <= set_msec;
                end
            
                if(cnt_sysclk >= 999_999) begin
                    cnt_sysclk <= 0;
                    if(set_msec == 99) begin
                        set_msec <= 0;
                        set_sec <= set_sec + 1;
                    end
                    else set_msec <= set_msec + 1; 
                end
                else cnt_sysclk <= cnt_sysclk + 1;
            end
        end
    end
    
    // sec, msec를 MUX로 처리...
    assign sec = (view_time || save_sec == 0) ? set_sec : save_sec;
    assign msec = (view_time || save_msec == 0) ? set_msec : save_msec;
    
endmodule


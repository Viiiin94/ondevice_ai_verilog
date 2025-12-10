`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2025 02:06:29 PM
// Design Name: 
// Module Name: exam02_sequential_logic
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

module D_flip_flop_n(
    input d,
    input clk, reset_p, en,
    output reg q
    );
    
    // edge 트리거로 들어오면 flipflop이 생성됨
    always @(negedge clk, posedge reset_p)begin
        if(reset_p) q = 0;
        else if(en)q <= d;
    end

endmodule

module D_flip_flop_p(
    input d,
    input clk, reset_p, en,
    output reg q
    );
    
//    always문에 엣지쓰면 플립플롭이 만들어짐
//    always @(posedge clk, posedge reset_p)begin
//        //clk와 상관없이 q값이 0이 됨 reset우선
//        if(reset_p) q = 0;
//        else if(en)q <= d;
//    end

    always @(posedge clk)begin
        //clk에 맞춰 리셋됨
        if(reset_p) q = 0;
        else if(en)q <= d;
    end

endmodule

module T_flip_flop_n(
    input clk, reset_p,
    input en,
    input t,
    output reg q
    );
    
    always @(negedge clk, posedge reset_p)begin
        if(reset_p) q=0;
        else if(en)begin
            if(t) q = ~q;
        end
    end

endmodule

module T_flip_flop_p(
    input clk, reset_p,
    input en,
    input t,
    output reg q
    );
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) q=0;
        else if(en)begin
            if(t) q = ~q;
        end
    end

endmodule

module up_counter_asyc(
    input clk, reset_p,
    output [3:0] count
    );
    
   T_flip_flop_n cnt0(.clk(clk), .reset_p(reset_p), .en(1), .t(1), .q(count[0]));
   T_flip_flop_n cnt1(.clk(count[0]), .reset_p(reset_p), .en(1), .t(1), .q(count[1]));
   T_flip_flop_n cnt2(.clk(count[1]), .reset_p(reset_p), .en(1), .t(1), .q(count[2]));
   T_flip_flop_n cnt3(.clk(count[2]), .reset_p(reset_p), .en(1), .t(1), .q(count[3]));


endmodule

module down_counter_asyc(
    input clk, reset_p,
    output [3:0] count
    );
    
   T_flip_flop_p cnt0(.clk(clk), .reset_p(reset_p), .en(1), .t(1), .q(count[0]));
   T_flip_flop_p cnt1(.clk(count[0]), .reset_p(reset_p), .en(1), .t(1), .q(count[1]));
   T_flip_flop_p cnt2(.clk(count[1]), .reset_p(reset_p), .en(1), .t(1), .q(count[2]));
   T_flip_flop_p cnt3(.clk(count[2]), .reset_p(reset_p), .en(1), .t(1), .q(count[3]));


endmodule

module up_counter_p(
    input clk, reset_p,
    output reg [3:0] count
);
    // always가 D플립플롭이라 생각
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) count = 0;
        else count = count + 1;
        // overflow가 되면 0000으로 바뀜
    end
endmodule

module down_counter_p(
    input clk, reset_p,
    output reg [3:0] count
);
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) count = 0;
        // underflow가 되어 1111로 바뀜
        else count = count - 1;
    end
endmodule

module down_counter_n(
    input clk, reset_p,
    output reg [3:0] count
);
    always @(negedge clk, posedge reset_p)begin
        if(reset_p) count = 0;
        else count = count - 1;
    end
endmodule

module ring_counter(
    input clk, reset,
    output reg [3:0] q
);
    always @(posedge clk, posedge reset)begin
        if(reset) q = 0;
        else begin
            case(q)
                4'b0001 : q <= 4'b0010;
                4'b0010 : q <= 4'b0100;
                4'b0100 : q <= 4'b1000;
                4'b1000 : q <= 4'b0001;
                default : q <= 4'b0001;
            endcase
        end
    end
endmodule

module ring_counter_shift(
    input clk, reset,
    output reg [3:0] q
);
    always @(posedge clk, posedge reset)begin
        if(reset) q = 0;
        else begin
            // 베릴로그에선 굳이 shift 연산자를 사용하지 않는다.
            // q <= q << 1;
            // q = {q[2:0], 1'b0}; 이러면 0000일 때 작동x
            if(q != 4'b0001 && q != 4'b0010 && q != 4'b0100 && q != 4'b1000) q <= 4'b0001;
            else q <= {q[2:0], q[3]};
        end
    end
endmodule

module ring_counter_led(
    input clk, reset,
    output reg [15:0] led
);

    reg [31:0] clk_div;
    always @(posedge clk) clk_div = clk_div + 1;

    wire clk_div22_ed_p;

    edge_detector_n edn(.clk(clk), .reset(reset), .cp(clk_div[22]), .p_edge(clk_div22_ed_p));
    
    always @(posedge clk or posedge reset) begin
        if(reset) led <= 16'b0000_0000_0000_0001;
        else if(clk_div22_ed_p) led <= {led[14:0], led[15]};
    end
    
    // always @(posedge clk, posedge reset)begin
    //     if(reset)clk_div = 0;
    //     else begin
    //         if(clk_div == 100000000) clk_div = 0;
    //         else clk_div = clk_div + 1;
    //     end
    // end

    // always @(posedge clk, posedge reset)begin
    //     if(reset) led = 16'b0000_0000_0000_0001;
    //     else begin
    //         if(clk_div == 10_000_000)begin
    //             led <= {led[14:0], led[15]};
    //         end
    //     end
    // end

endmodule

module edge_detector_n(
    input clk, reset,
    input cp,
    output p_edge, n_edge
);

    reg ff_cur, ff_old;

    always @(posedge clk, posedge reset)begin
        if(reset)begin
            ff_cur <= 0;
            ff_old <= 0;
        end
        else begin
        // '=' 블록킹 '<=' 논블록킹
            ff_old <= ff_cur;
            ff_cur <= cp;
        end
    end

    assign p_edge = ({ff_cur, ff_old} == 2'b10) ? 1 : 0;
    assign n_edge = ({ff_cur, ff_old} == 2'b01) ? 1 : 0;

endmodule

module SISO(
    input clk, reset_p,
    input d,
    input en,
    output f
);

    reg [7:0] register_siso;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) register_siso <= 0;
        else if(en) begin  
            register_siso <= {d, register_siso[7:1]};
        end
    end

    assign f = register_siso[0];

endmodule

module SIPO(
    input clk, reset_p,
    input d,
    input rd_en,
    output [7:0] q
);

    reg [7:0] register_sipo;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p)register_sipo = 0;
        else register_sipo <= {d, register_sipo[7:1]};
    end
    
    assign q = rd_en ? register_sipo : 8'bz; // 임피던스 

endmodule
















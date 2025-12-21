`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/19/2025 03:24:22 PM
// Design Name: 
// Module Name: tb_sensor_test01
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


module tb_sensor_test01();
    // 다음 상태로 넘어가기 위한 거리와 온도
    localparam [8:0] LIMIT_DISTANCE_VALUE    = 9'd120;
    localparam [7:0] LIMIT_TEMPERATURE_VALUE = 8'd30;
    
    reg clk, reset_p;
    tri1 dht11_data;
    reg dout, wr_e;
    assign dht11_data = wr_e ? dout : 'bz;
    wire [7:0] humidity, temperature;
    
    reg echo;
    wire [8:0] distance_cm;
    wire trig;
    
    // 온습도 센서, 초음파 센서가 존재하는 탑 모듈
    prototype_sensor_test DUT(clk, reset_p, dht11_data, echo, trig, humidity, temperature, distance_cm);
    
    always #5 clk = ~clk;
    
    initial begin
        // 초기화
        clk = 0; reset_p = 1;
        dout = 0; wr_e = 0; echo = 0;
        #50
        reset_p = 0;
        
        $display("\n=== [Simulation Start] ===\n");
        
        // 병렬 처리를 위한 fork
        // 2개의 begin문이 동시에 실행이 됨
        fork
            // DHT11 센서 : 온도를 순차적으로 변경 30도가 넘으면 경고
            begin
                // 1차 측정: 습도 50, 온도 20도
                task_dht11_response(8'd50, 8'd20);
                
                // 2차 측정: 온도를 35도로 변경 (경고)
                task_dht11_response(8'd50, 8'd35);

                // 3차 측정: 온도를 다시 25도로 안정화
                task_dht11_response(8'd50, 8'd25);
            end

            // 초음파 센서 : 거리를 순차적으로 변경 120cm를 넘지 않으면 경고
            begin
                #100_000;
                task_ultrasonic_response(30);   // 30cm (경고)
                
                #5_000_000;
                task_ultrasonic_response(150);  // 150cm 안정화
                
                #5_000_000;
                task_ultrasonic_response(80);   // 다시 경고
            end
        join
        
        #1000;
        $display("\n=== [Simulation All Clear] ===\n");
        $stop;
    end
    
    // =================================================================
    // Task 1 : DHT11 센서 동작 모사 => 습도(humi_val), 온도(temp_val)
    // =================================================================
    task task_dht11_response(input [7:0] humi_val, input [7:0] temp_val);
        reg [7:0] check_sum;
        reg [39:0] full_data;
        integer i;
        
        begin
            check_sum = humi_val + temp_val;
            full_data = {humi_val, 8'd0, temp_val, 8'd0, check_sum};
            
            $display("[DHT11 TASK] Start signal");
            
            wait(!dht11_data);
            wait(dht11_data);
            
            #20_000;
            dout = 0; wr_e = 1; #80_000; // Low 80us
            dout = 1; #80_000;           // High 80us
            
            for(i=0; i<40; i=i+1) begin
                dout = 0;
                #50_000;
                dout = 1;
                
                if(full_data[39-i]) #70_000;
                else #27_000;
            end
            
            dout = 0; #50_000;
            wr_e = 0; #5_000;
            
            if (DUT.temperature > LIMIT_TEMPERATURE_VALUE) begin
                $display("Result: %d C (It is a warning over the temperature!)", DUT.temperature);
            end
            else begin
                $display("Result: %d C (✅SAFE!SAFE!SAFE!SAFE!SAFE!SAFE!SAFE!)", DUT.temperature);
            end
        end
    endtask
    
    // =================================================================
    // Task 2 : HC-SR04 초음파 센서 동작 모사 => 거리 cm (dist_val)
    // =================================================================
    task task_ultrasonic_response(input [31:0] dist_val);
        begin
            $display("[ULTRASONIC TASK] Start signal");
            
            wait(trig);
            wait(!trig);
            
            #1_000;
            
            echo = 1;
            #(dist_val * 58 * 1000);
            echo = 0;
            
            #5000;
            
            if (DUT.distance_cm < LIMIT_DISTANCE_VALUE) begin
                $display("Result: %d cm (It is a warning under the celsius!)", DUT.distance_cm);
            end
            else begin
                $display("Result: %d cm (✅SAFE!SAFE!SAFE!SAFE!SAFE!SAFE!SAFE!)", DUT.distance_cm);
            end
        end
    endtask
endmodule

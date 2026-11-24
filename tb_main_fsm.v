`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2026 07:48:40 PM
// Design Name: 
// Module Name: tb_main_fsm
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
//started 11/24/26 by lupe 

module tb_main_fsm;
reg clk = 1'b0; //gives starting value of 1 
reg rst = 1'b0;
reg [4:0] btns = 5'b00000; 
reg timeout = 1'b0;
reg enough = 1'b0;
reg has_change = 1'b0;
reg [1:0] sw_photo = 2'b00; //picks which photo to retake

wire [3:0] state;
wire add, refund, clear;
wire package_sel, filter_sel, timer_start, retake_used;
wire [4:0] limit;
wire [1:0] photo_num;

always #5 clk = ~clk; //repetedly waits 5 ns and flips clk between 0 and 1, which creates a rising edge evert 10 ns which lets the FSM update

main_fsm dut( // device under test, copt of mainfsm that testbench is testing, has all the connections 
               // all the connections matter becuase they tell the testbecmnh how to interact with the FSM
    .clk(clk),
    .rst(rst),
    
    .btn_u(btns[0]),
    .btn_l(btns[1]),
    .btn_r(btns[2]),
    .btn_c(btns[3]),
    .btn_d(btns[4]),
    
    .timeout(timeout),
    .enough(enough),
    .has_change(has_change),
    .sw_photo(sw_photo),
    
    .state(state),
    .add(add),
    .refund(refund),
    .clear(clear),
    .package_sel(package_sel),
    .timer_start(timer_start),
    .limit(limit),
    .filter_sel(filter_sel),
    .retake_used(retake_used),
    .photo_num(photo_num)
);

initial begin   
    #200;
    $finish;
//clock generator started at 11:30 , needed because 
    end 
    
initial begin
    rst = 1'b1;
    @(posedge clk);
    rst = 1'b0;    
    end 
endmodule

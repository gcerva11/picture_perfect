`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2026 07:40:14 PM
// Design Name: 
// Module Name: main_fsm
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


module main_fsm(
//started 11/23//26 @ 7:50 just me and a dutch bros against the world
//inputs and outputs, agreed with the team before we started on vivado
input clk,
input rst,
input btn_u, btn_l, btn_r, btn_c,btn_d,
input timeout,
input enough, 
input has_change,
input [1:0] sw_photo, //picks which photo to retake

output reg [3:0] state,
output add,
output refund,
output clear, 
output reg package_sel, // 0=1 photo at 4 dollars and 1 = 3 photos at 8 dollars 
output reg filter_sel, // 0= black and white 1= color
output timer_start,
output reg [4:0] limit,
output reg retake_used,
output reg [1:0] photo_num
    );
    
//nicknames 
localparam [3:0] 
    SELECT_PKG = 4'b0000,
    SELECT_FILTER = 4'b0001,
    PAYMENT = 4'b0010,
    INSUFFICIENT = 4'b0011,
    REFUND = 4'b0100,
    COUNTDOWN = 4'b0101,
    CAPTURE = 4'b0110,
    REVIEW = 4'b0111,
    RECAPTURE = 4'b1000,
    PRINT = 4'b1001,
    CHANGE = 4'b1010,
    DONE = 4'b1011;

wire [1:0] last_photo = package_sel ? 2'd3 : 2'd1;
wire go_recapture = (state == REVIEW ) && btn_l && retake_used && !btn_c && !timeout;


reg [3:0] next_state;
always @(*) begin
    next_state=state;

case(state)
    SELECT_PKG:
        if (btn_c) next_state = SELECT_FILTER;
       
    SELECT_FILTER:
        if (btn_c) next_state = PAYMENT; //next step
        else if (btn_c) next_state = SELECT_PKG; // after 3 s
        
    PAYMENT:
        if (btn_d || timeout) next_state = REFUND;  //the user either canceled oter 20 s ran out
        else if (btn_c) next_state =  enough ? COUNTDOWN : INSUFFICIENT;
    
    INSUFFICIENT:
        if (btn_d || timeout) next_state = REFUND; 
        else if (btn_u) next_state = PAYMENT; //added money so try again
        
    REFUND:
        if (timeout) next_state = SELECT_PKG; // after 3 s
       
    COUNTDOWN:
        if (timeout) next_state = CAPTURE; // 3 second countdown
        
    CAPTURE:
        if (timeout) begin //1 sec flash
        if (retake_used) next_state = PRINT; //that was the retake
        else if (photo_num == last_photo) next_state = REVIEW; //that was the last photo
        else next_state = COUNTDOWN; //more photos to go
        end
    
    REVIEW:
    if (btn_c || timeout) next_state = PRINT;
    else if (go_recapture) next_state = RECAPTURE;
    
    RECAPTURE:
    if (timeout) next_state = COUNTDOWN;
    
    PRINT:
    if (timeout) next_state = has_change ? CHANGE : DONE;

    CHANGE:
    if (timeout) next_state =  DONE;
    
    DONE:
    if (timeout) next_state = SELECT_PKG;
    
    default:
    next_state = SELECT_PKG;
    endcase
end
    
always @(posedge clk) begin
    if (rst) begin
    state <= SELECT_PKG;
    package_sel <= 1'b0;
    filter_sel <= 1'b0;
    photo_num <= 2'd1;
    retake_used <=1'b0;
end else begin 

state <= next_state;

if (state == SELECT_PKG) begin
    if (btn_l) package_sel <= 1'b0;
    else if (btn_r) package_sel <= 1'b1;
end

if (state == SELECT_FILTER) begin
    if (btn_l) filter_sel <= 1'b0;
    else if (btn_r) filter_sel <= 1'b1;
end

//after each normal photo move onto the next poto number
//will not do so after the last photo and not after the retake
if (state == CAPTURE && timeout && !retake_used && photo_num != last_photo)
    photo_num <= photo_num + 2'd1;

if (clear) begin
                package_sel <= 1'b0;
                filter_sel  <= 1'b0;
                photo_num   <= 2'd1;
                retake_used <= 1'b0;
            end
        end
    end

assign add    = btn_u && (state == PAYMENT || state == INSUFFICIENT);
    assign refund = (state == REFUND);
    assign clear  = (state == REFUND || state == DONE) && timeout;

    assign timer_start = (next_state != state);


 always @(*) begin
        case (next_state)
            PAYMENT, INSUFFICIENT:                   limit = 5'd20;
            REVIEW:                                  limit = 5'd10;
            REFUND, COUNTDOWN, PRINT, CHANGE, DONE:  limit = 5'd3;
            CAPTURE, RECAPTURE:                      limit = 5'd1;
            default:                                 limit = 5'd0;
endcase
end
endmodule

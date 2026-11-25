// -----------------------------------------------------------------------------
// led_logic.sv  --  Picture Perfect photo booth
// Moore output block: LEDs depend ONLY on the current FSM state (no inputs),
// so they cannot glitch when a button is pressed.
//
// ASSUMPTIONS (the state encoding and LED map are in your design document,
// not the progress report -- edit the localparams and the case table below to
// match them):
//   12 states guessed from the project description:
//     SEL_PKG, SEL_FILTER, PAYMENT, INSUFFICIENT, COUNTDOWN, CAPTURE,
//     REVIEW, RETAKE, PRINT, CHANGE, REFUND, DONE
//   LED map (led[15:10] unused, held at 0):
//     led[0] ready        - only in the two select states
//     led[1] paying       - PAYMENT, INSUFFICIENT
//     led[2] error        - INSUFFICIENT
//     led[3] countdown    - COUNTDOWN
//     led[4] capture      - CAPTURE (the 1 s flash)
//     led[5] review       - REVIEW, RETAKE
//     led[6] printing     - PRINT
//     led[7] change       - CHANGE
//     led[8] refund       - REFUND
//     led[9] done         - DONE
// -----------------------------------------------------------------------------
module led_logic (
    input  logic [3:0]  state,      // current state from main_fsm
    output logic [15:0] led         // Basys 3 LD15..LD0
);

    // ---- state encoding: CHANGE TO MATCH YOUR ENCODING TABLE ----
    localparam logic [3:0] SEL_PKG      = 4'd0;
    localparam logic [3:0] SEL_FILTER   = 4'd1;
    localparam logic [3:0] PAYMENT      = 4'd2;
    localparam logic [3:0] INSUFFICIENT = 4'd3;
    localparam logic [3:0] COUNTDOWN    = 4'd4;
    localparam logic [3:0] CAPTURE      = 4'd5;
    localparam logic [3:0] REVIEW       = 4'd6;
    localparam logic [3:0] RETAKE       = 4'd7;
    localparam logic [3:0] PRINT        = 4'd8;
    localparam logic [3:0] CHANGE       = 4'd9;
    localparam logic [3:0] REFUND       = 4'd10;
    localparam logic [3:0] DONE         = 4'd11;

    always_comb begin
        led = 16'h0000;                         // default: everything off
        case (state)
            SEL_PKG,
            SEL_FILTER:   led[0] = 1'b1;
            PAYMENT:      led[1] = 1'b1;
            INSUFFICIENT: led[2:1] = 2'b11;
            COUNTDOWN:    led[3] = 1'b1;
            CAPTURE:      led[4] = 1'b1;
            REVIEW,
            RETAKE:       led[5] = 1'b1;
            PRINT:        led[6] = 1'b1;
            CHANGE:       led[7] = 1'b1;
            REFUND:       led[8] = 1'b1;
            DONE:         led[9] = 1'b1;
            default:      led = 16'h0000;       // unused encodings 12..15
        endcase
    end

endmodule

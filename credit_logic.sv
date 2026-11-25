// -----------------------------------------------------------------------------
// credit_logic.sv  --  Picture Perfect photo booth
// Tracks the dollars inserted and compares them to the package price.
//
// ASSUMPTIONS (the progress report does not include the Section 4 tables;
// rename/retune to match your interface table):
//   * rst        : synchronous reset (SW[15])
//   * add        : one-clock pulse from the debouncer (BTNU). The top level /
//                  FSM should only let it through while in the Payment states.
//   * sw_amt     : SW[3:0], 0..15 dollars added per BTNU press
//   * clear      : one-clock pulse, asserted when the Refund (or Change /
//                  Done) state exits, so the refund amount stays on the
//                  display until then
//   * pkg_three  : 0 = 1 photo ($4), 1 = 3-photo strip ($8)
//   * MAX_CREDIT : the "dollar cap" (value assumed to be 99 so it fits two
//                  display digits). An add that would exceed the cap is
//                  ignored, so the booth never swallows money.
// Outputs are combinational off the credit register and pkg_three.
// -----------------------------------------------------------------------------
module credit_logic #(
    parameter int MAX_CREDIT   = 99,
    parameter int PRICE_SINGLE = 4,
    parameter int PRICE_STRIP  = 8
)(
    input  logic       clk,
    input  logic       rst,         // synchronous reset (SW[15])
    input  logic       add,         // 1-clk pulse, BTNU
    input  logic       clear,       // 1-clk pulse, zero the credit
    input  logic       pkg_three,   // 0 = $4 single, 1 = $8 strip
    input  logic [3:0] sw_amt,      // SW[3:0]

    output logic [6:0] dollars,     // credit inserted so far
    output logic [6:0] needed,      // still owed (0 when paid up)
    output logic [6:0] change,      // dollars - price (0 when none)
    output logic       enough,      // dollars >= price
    output logic       has_change   // dollars >  price
);

    logic [6:0] price;
    logic [7:0] sum;                // one extra bit so the cap check can't wrap

    assign price = pkg_three ? 7'(PRICE_STRIP) : 7'(PRICE_SINGLE);
    assign sum   = {1'b0, dollars} + {4'b0, sw_amt};

    // Credit register
    always_ff @(posedge clk) begin
        if (rst || clear)
            dollars <= 7'd0;
        else if (add && (sum <= 8'(MAX_CREDIT)))
            dollars <= sum[6:0];
    end

    // Price comparison
    always_comb begin
        enough     = (dollars >= price);
        has_change = (dollars >  price);
        needed     = enough     ? 7'd0 : (price - dollars);
        change     = has_change ? (dollars - price) : 7'd0;
    end

endmodule

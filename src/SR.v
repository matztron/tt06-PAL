module SR #(
    parameter LEN=8
)(
    input CLK,
    input CFG,
    input RES_N,
    output reg [LEN-1:0] FF_CHAIN
);

// Shift left whenever a posedge occurs
always @(posedge CLK) begin
    if (~RES_N) begin
        FF_CHAIN <= {(LEN){1'b0}}; // when reset set all bits to 0
    end else begin
        FF_CHAIN    <= FF_CHAIN << 1;
        FF_CHAIN[0] <= CFG;
    end
end

endmodule
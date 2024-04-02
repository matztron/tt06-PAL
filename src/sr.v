module sr #(
    parameter LEN=8
)(
    input clk,
    input cfg,
    input res_n,
    input en,
    output [LEN-1:0] ff_chain
);

    reg [LEN-1:0] internal_ff_chain;

    // Shift left whenever a posedge occurs
    always @(posedge clk) begin
        if (~res_n) begin
            internal_ff_chain <= {(LEN){1'b0}}; // when reset set all bits to 0
        end else begin
            internal_ff_chain    <= internal_ff_chain << 1;
            internal_ff_chain[0] <= cfg;
        end
    end

    // only apply configuration to the pal fabric once the enable signal is asserted!
    assign ff_chain = en ? internal_ff_chain : {(LEN){1'b0}};

endmodule
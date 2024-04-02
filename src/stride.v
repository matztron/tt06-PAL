module stride #(
    //parameter OPERATION = "and", // either put "and" or "or"
    parameter LEN = 8,
    parameter STRIDE = 2,
    parameter START_OFFSET = 0
) (
    input [LEN-1:0] in,
    output [$signed(LEN/STRIDE)-1:0] strided_out
);

// Idea:
// 0 1 2 3 4 5 6 7
// ^   ^   ^   ^
// |   |   |   |
//
// 0. | [0] 1
// 1. | [2] 3
// 2. | [4] 5
// 3. | [6] 7

genvar i;
genvar stride_index;
generate

    for (i = START_OFFSET; i < LEN; i = i + STRIDE) begin : REDUCE_LOOP
        assign strided_out[$signed(i/STRIDE)] = in[i];
    end

endgenerate
    
endmodule
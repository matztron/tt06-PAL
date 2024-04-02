module reduce_or #(
    parameter NUM_INTERM_STAGES = 4,
    parameter ROW_INDEX = 0,
    parameter LEN = 4
) (
    input [LEN-1:0] data_in,
    output reduced_out
);

    // Reduce operation
    //assign reduced_out = |data_stride;
    assign reduced_out = |data_in[ROW_INDEX*NUM_INTERM_STAGES+(NUM_INTERM_STAGES-1):ROW_INDEX*NUM_INTERM_STAGES];

endmodule
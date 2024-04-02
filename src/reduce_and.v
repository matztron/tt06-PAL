module reduce_and #(
    parameter STRIDE = 2,
    parameter LEN = 4,
    parameter COL_INDEX = 0
) (
    input [LEN-1:0] data_in,
    output reduced_out
);

    wire [LEN/STRIDE-1:0] data_stride; 

    //Stride instance
    stride #(
        .LEN(LEN),
        .STRIDE(STRIDE),
        .START_OFFSET(COL_INDEX)
    ) stride_I (
        .in(data_in),
        .strided_out(data_stride)
    );

    
    // TODO: With current implementation this does not work...
    // We also need a mask of the bitstream to first remove all positions that are not 1!
    // SW has to make sure that there is never both the input and its inverted set to true -> then whole term will be 0!!!
    // Col.  1 0 1 1 0 0 1 0
    // Bits. 0 1 1 0 0 1 0 1
    // ---------------------
    // AND   0 0 1 0 0 0 0 0 <- then use this one for reduction!
    assign reduced_out = &data_stride; //

endmodule
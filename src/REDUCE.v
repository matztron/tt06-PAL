module REDUCE #(
    parameter OPERATION = "and", // either put "and" or "or"
    parameter LEN = 8,
    parameter STRIDE = 2
) (
    input [LEN-1:0] data_in,
    output reduced_out
);

    wire [LEN/STRIDE-1:0] data_stride; 

    //Stride instance
    STRIDE #(
        .LEN(LEN),
        .STRIDE(STRIDE)
    ) stride_I (
        .in(data_in),
        .strided_out(data_stride)
    );

    // Reduce operation
    generate
        if (OPERATION == "and") begin
            // TODO: With current implementation this does not work...
            // We also need a mask of the bitstream to first remove all positions that are not 1!
            // SW has to make sure that there is never both the input and its inverted set to true -> then whole term will be 0!!!
            // Col.  1 0 1 1 0 0 1 0
            // Bits. 0 1 1 0 0 1 0 1
            // ---------------------
            // AND   0 0 1 0 0 0 0 0 <- then use this one for reduction!
            assign reduced_out = &data_stride; //
        end else if (OPERATION == "or") begin
            assign reduced_out = |data_stride;
        end else begin
            // error! invalid operator specified!
            assign reduced_out = 1'bx;
        end
    endgenerate

endmodule
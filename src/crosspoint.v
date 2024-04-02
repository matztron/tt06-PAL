module crosspoint #(
    parameter OP = "and"
)
(
    input data_in,
    input cfg_in,
    output data_out
);
    if (OP == "and") begin
        // the neutral element of an AND is the 1 - hence generate 1s at undesired positions.
        // we want a 1 when the cfg is 0. We want the value of data_in when the cfg is 1
        assign data_out = (cfg_in == 1'b1) ? data_in : 1'b1;
    end else if (OP == "or") begin
        // the neutral element of the OR is the 0 - hence generate 0s at undesired positions.
        // we want a 0 when the cfg is 0. We want the value of data in when the cfg is 1
        assign data_out = (cfg_in == 1'b1) ? data_in : 1'b0;
    end else begin 
        //Unspecified... this should not happen
    end
    
endmodule
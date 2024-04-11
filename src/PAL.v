module PAL #(
    parameter N = 8, // Number of Inputs
    parameter P = 8, // Number of intermediate stages
    parameter M = 8  // Number of outputs
)(
    input clk,
    input res_n,
    input en,
    input cfg,
    input [N-1:0] INPUT_VARS,
    output [M-1:0] OUTPUT_VALS
);

    parameter SR_LEN = $signed((2*N * P) + P*M);

    // Configuration chain
    wire [SR_LEN-1:0] FF_CHAIN;

    // ---
    // FF_CHAIN
    //
    // <MSB> [ OR | ... | OR | OR | AND | ... | AND | AND | AND-INV | ... | AND-INV | AND-INV ] <LSB> NO THIS IS WRONG! The inverted inputs are interleaved!
    //
    // When bit at INV is 1 then it is inverted!
    // ---
    // Indices for configuration chain
    parameter FF_CHAIN_OR_BASE_INDEX = $signed(2 * (N*P)); // the fully poopulated crossbar between N and P needs to be considered; *2 because of inverted & non-inverted inputs

    wire [FF_CHAIN_OR_BASE_INDEX-1:0] FF_CHAIN_AND;
    wire [SR_LEN-FF_CHAIN_OR_BASE_INDEX-1:0] FF_CHAIN_OR;

    assign FF_CHAIN_AND = FF_CHAIN[FF_CHAIN_OR_BASE_INDEX-1:0];
    assign FF_CHAIN_OR = FF_CHAIN[SR_LEN-1:FF_CHAIN_OR_BASE_INDEX];

    // Shift register (stores the configuration)
    sr #(
        .LEN(SR_LEN)
    ) sr (
        .clk(clk),
        .res_n(res_n),
        .en(en),
        .cfg(cfg),
        .ff_chain(FF_CHAIN)
    );

    // NOT gates
    // redo this!
    wire [2*N-1:0] INPUT_VARS_N;
    wire [P-1:0] INTERM_VARS;

    // 
    //wire [P-1:0] and_cols[2*N-1:0];
    //wire [M-1:0] or_rows[P-1:0];
    wire [2*N*P-1:0] and_results;
    wire [P*M-1:0] or_results;
    wire test_lol;
    assign test_lol = clk;


    // Iterators (running variables)
    genvar i;
    genvar p;
    genvar n;
    genvar m;
    // ---

    // n=0: 0&1
    // n=1: 2&3
    // n=2: 4&5
    // n=3: 6&7
    for (n = 0; n < N; n = n + 1) begin
        assign INPUT_VARS_N[2*n] = INPUT_VARS[n]; // even: keep
        assign INPUT_VARS_N[2*n+1] = ~INPUT_VARS[n]; // odd: invert
    end
    // ---

    // AND matrix
    generate
    for (p = 0; p < P; p = p + 1) begin : AND_GEN_LOOP_OUTER
        for (n = 0; n < $signed(2*N); n = n + 1 ) begin : AND_GEN_LOOP_INNER
            //assign INTERM_VARS[p] = INTERM_VARS[p] ^ (FF_CHAIN[FF_CHAIN_AND_BASE_INDEX + p + n*P] ^ INPUT_VARS[n]);
            //assign and_cols[p][n] = INPUT_VARS[n] ^ FF_CHAIN[$signed(FF_CHAIN_AND_BASE_INDEX + p + n*P)];
            crosspoint #(.OP("and")) cp (.data_in(INPUT_VARS_N[n]), .cfg_in(FF_CHAIN_AND[$signed(p + n*P)]), .data_out(and_results[$signed(p + n*P)]));
        end

        // Assign intermediate variables
        //assign INTERM_VARS[p] = &and_cols[p]; // AND reduction
        reduce_and #(
            .LEN(2*N*P),
            .STRIDE(P),
            .COL_INDEX(p)
        ) reduce_and_I (
            .data_in(and_results), // we are only allowed to take
            .reduced_out(INTERM_VARS[p])
        );
    end
    endgenerate
    
    // ---

    // OR matrix
    generate
    for (m = 0; m < M; m = m + 1) begin : OR_GEN_LOOP_OUTER
        for (p = 0; p < P; p = p + 1) begin : OR_GEN_LOOP_INNER
            //assign OUTPUT_VALS[m] = OUTPUT_VALS[m] | (FF_CHAIN[FF_CHAIN_OR_BASE_INDEX + p + m*P] ^ INTERM_VARS[p]);
            //assign or_rows[m][p] = INTERM_VARS[p] ^ FF_CHAIN[$signed(FF_CHAIN_OR_BASE_INDEX + p + m*P)];
            crosspoint #(.OP("or")) cp (.data_in(INTERM_VARS[p]), .cfg_in(FF_CHAIN_OR[$signed(p + m*P)]), .data_out(or_results[$signed(p + m*P)]));
        end

        // Assign to outputs
        //assign OUTPUT_VALS[m] = |or_rows[m]; // OR reduction
        reduce_or #(
            .NUM_INTERM_STAGES(P),
            .ROW_INDEX(m),
            .LEN(P*M)
        ) reduce_or_I (
            .data_in(or_results),
            .reduced_out(OUTPUT_VALS[m])
        );
    end
    endgenerate
    // ---
    
endmodule
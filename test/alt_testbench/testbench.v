module pal_tb ();

// configure these
parameter NUM_INPUTS = 8; // update by hand!
parameter NUM_INTERM_STAGES = 11;
parameter NUM_OUPUTS = 5;
// ---

localparam BITSTREAM_LEN = $signed(2*NUM_INPUTS*NUM_INTERM_STAGES + NUM_INTERM_STAGES*NUM_OUPUTS);

//reg clk_en_tb;
reg clk_tb; // this clock is unused...
reg clk_pal_tb;

// Currently: O0 = ~I0 | I1 & ~(I2 & I3)
wire [BITSTREAM_LEN-1:0] bitstream; // TODO: Update width by hand (according to assignment below)
assign bitstream = 231'b000010000000000000000010001100000000000000000101100000000000100000001100000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000001000000000001000000000001000000000001100000; // TODO: Update this by hand

//assign clk_pal_tb = clk_tb ^ clk_en_tb;

reg enable_tb;
reg config_tb;
reg [NUM_INPUTS-1:0] inputs_tb;
wire [NUM_OUPUTS-1:0] outputs_tb;

// TT signals
wire [7:0] tt_ui_in_tb;
wire [7:0] tt_uo_out_tb;
wire [7:0] tt_uio_in_tb;
wire [7:0] tt_uio_out_tb; // output - i dont care...
wire [7:0] tt_uio_oe_tb; // output - i dont care...
reg tt_ena_tb;
wire tt_clk_tb; // UNUSED!!!
reg tt_res_n_tb;

assign tt_ui_in_tb = inputs_tb; // TODO: Naive: If >8 inputs are configured then the MSB-bits are truncated!
assign outputs_tb = tt_uo_out_tb; // TODO: Naive: If >8 outputs are configured then the MSB-bits are truncated!
assign tt_uio_in_tb = {5'b0, clk_pal_tb, enable_tb, config_tb}; // config bit is LSB

//assign clk_tb = clk_pal_tb;

// UUT
tt_um_MATTHIAS_M_PAL_TOP_WRAPPER uut(
    .ui_in(tt_ui_in_tb),        // Dedicated inputs
    .uo_out(tt_uo_out_tb),      // Dedicated outputs
    .uio_in(tt_uio_in_tb),      // IOs: Input path
    .uio_out(tt_uio_out_tb),    // IOs: Output path
    .uio_oe(tt_uio_oe_tb),      // IOs: Enable path (active high: 0=input, 1=output)
    .ena(tt_ena_tb),            // will go high when the design is enabled
    .clk(tt_clk_tb),            // clock
    .rst_n(tt_res_n_tb)         // reset_n - low to reset
);


// Clock source
/*initial begin
    clk_tb=0;
    forever #2 clk_tb=~clk_tb;
end*/

integer i;
// Testcase
initial begin
    $dumpfile("./output/SIM.vcd");
    $dumpvars(0, pal_tb);

    // Bitstream programming
    clk_pal_tb = 1'b0;
    tt_res_n_tb = 1'b1;
    tt_ena_tb = 1'b1;
    enable_tb = 1'b0;

    #10

    for (i = 0; i < BITSTREAM_LEN; i = i + 1) begin
        #2
        config_tb = bitstream[i];
        clk_pal_tb = 1'b1;
        #2;
        clk_pal_tb = 1'b0;
	end

    clk_pal_tb = 1'b0;
    #10
    // Now set the outputs active
    enable_tb = 1'b1;

    // here the output is 0
    inputs_tb = 8'b0000_0000;

    #100

    // Change some of the upper bits -> these are not used in the logic function
    // thus this should have no effect
    inputs_tb = 8'b0000_0001;

    #100

    inputs_tb = 8'b0000_0010;

    #100

    inputs_tb = 8'b0000_0100;

    #100

    inputs_tb = 8'b0000_1000;

    #100

    inputs_tb = 8'b0000_1100;

    #100

    inputs_tb = 8'b0000_0000;

    #100

    inputs_tb = 8'b0000_0010; //! should be 1

    #100

    inputs_tb = 8'b0000_0110; //! should be 0

    #100

    inputs_tb = 8'b0000_0011; //! should be 1

    #100

    // when enable is de-asserted the outputs should go to 0
    enable_tb = 0;

    inputs_tb = 8'b0000_0111; //! should be 1 but enable is off

    #100

    inputs_tb = 8'b0000_0000; //! should be 0 but enable is off

    #100

    #50

    // now back to 1 because it is re-asserted
    enable_tb = 1;

    #100

    $finish;
end
    
endmodule

// BUG:
// All outputs output the value of the O0...
module pal_tb ();

// configure these
parameter NUM_INPUTS = 8;
parameter NUM_OUPUTS = 8;
parameter NUM_INTERM_STAGES = 8;
// ---

localparam BITSTREAM_LEN = $signed(2*NUM_INPUTS*NUM_INTERM_STAGES + NUM_INTERM_STAGES*NUM_OUPUTS);

//reg clk_en_tb;
reg clk_tb; // this clock is unused...
reg clk_pal_tb;

wire [192:0] bitstream; // TODO: Update width by hand (according to assignment below)
assign bitstream = 192'b000000000000000011000000000000000000000010000000000000000100000000000000000000000000000000000000000000000000000000000000000000001100000011000000110000001100000011000000110000001100000011000000; // TODO: Update this by hand

//assign clk_pal_tb = clk_tb ^ clk_en_tb;

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
wire tt_clk_tb;
reg tt_res_n_tb;

assign tt_ui_in_tb = inputs_tb; // TODO: Naive: If >8 inputs are configured then the MSB-bits are truncated!
assign outputs_tb = tt_uo_out_tb; // TODO: Naive: If >8 outputs are configured then the MSB-bits are truncated!
assign tt_uio_in_tb = {7'b0, config_tb}; // config bit is LSB

assign tt_clk_tb = clk_tb;

// UUT
TT_MATTHIAS_M_PAL_TOP_WRAPPER uut(
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
initial begin
    clk_tb=0;
    forever #2 clk_tb=~clk_tb;
end

integer i;
// Bitstream programming
initial begin
    clk_pal_tb = 1'b0;
    tt_res_n_tb = 1'b1;
    tt_ena_tb = 1'b1;

    #10

    for (i = 0; i < BITSTREAM_LEN; i = i + 1) begin
        config_tb = bitstream[i];
        clk_pal_tb = 1'b1;
        #2;
        clk_pal_tb = 1'b0;
	end

    clk_pal_tb = 1'b0;
end

// Testcase
initial begin
    $dumpfile("./output/SIM.vcd");
    $dumpvars(0, pal_tb);

    #1000

    inputs_tb = 8'b0000_1111;

    #1000

    inputs_tb = 8'b0000_0000;

    #1000

    inputs_tb = 8'b0000_1010;

    #1000

    $finish;
end
    
endmodule
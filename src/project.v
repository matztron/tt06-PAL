/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module tt_um_MATTHIAS_M_PAL_TOP_WRAPPER (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0. 
  assign uio_out = 0;
  // IO pin configuration
  assign uio_oe = 8'b0000_0000; // all IOs are inputs (the LSB is used to shift in Config data)
  assign uo_out[7:4] = 4'b0000;

  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  // PAL size parameters
  parameter NUM_INPUTS = 8;
  parameter NUM_INTERMEDIATE_STAGES = 4;
  parameter NUM_OUTPUTS = 4;
  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  // Pin assignment
  // Clock: uio_in[2]
  // Reset: res_n
  // Enable: uio_in[1]
  // Config bit: uio_in[0]

  // Input vars: ui_in[7:0]
  // Output vars: uo_out[3:0]

  // clk is unused!

  // PAL instance
  PAL #(
    .N(NUM_INPUTS), // Number of Inputs
    .M(NUM_OUTPUTS), // NUmber of outputs
    .P(NUM_INTERMEDIATE_STAGES) // Number of intermediate stages
  ) pal_I (
    .CLK(uio_in[2]), // do clock gating with ena signal?
    .RES_N(rst_n),
    .EN(ena & uio_in[1]), // if the enable signal is asserted the configuration is applied to the PAL fabric (also the design must be selected with the tto_en)
    .CFG(uio_in[0]),
    .INPUT_VARS(ui_in),
    .OUTPUT_VALS(uo_out[3:0])
  );

endmodule

`timescale 1us/1us

module pattern_checker #(
    parameter [7:0] DEFAULT_SEED = 8'h5A
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        full_empty,
    input  wire [63:0] dout,

    input  wire        load_seed,
    input  wire [7:0]  seed,

    output reg         rd,
    output reg         out,
    output reg         error_flag,
    output reg [15:0]  error_count,
    output reg [63:0]  dcheck
);

// internal logic missing
endmodule

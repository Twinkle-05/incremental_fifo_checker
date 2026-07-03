`timescale 1us/1us

module generator #(
    parameter [7:0] DEFAULT_SEED = 8'h5A
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        en,
    input  wire        almost_full,

    input  wire        load_seed,
    input  wire [7:0]  seed,

    output reg         wr,
    output reg [63:0]  din
);

// internal logic missing
endmodule

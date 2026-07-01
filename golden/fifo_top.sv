`timescale 1us/1us

module fifo_top (
    input  wire clk,
    input  wire rst,
    input  wire en,

    output wire out
);

    // Internal signals
    wire [63:0] din;
    wire [63:0] dout;
    wire [63:0] dcheck;

    wire wr;
    wire rd;

    wire full;
    wire empty;
    wire almost_full;
    wire checker_empty;

    assign checker_empty = empty | !en;

    //=========================================================
    // Incremental Data Generator
    //=========================================================
    generator generator_inst (
        .clk         (clk),
        .en          (en),
        .rst         (rst),
        .almost_full (full),
        .wr          (wr),
        .din         (din)
    );

    //=========================================================
    // Synchronous FIFO
    //=========================================================
    fifo_sync fifo_sync_inst (
        .clk_i          (clk),
        .rst_i          (rst),
        .wr_en_i        (wr),
        .rd_en_i        (!checker_empty),
        .wr_data_i      (din),
        .full_o         (full),
        .empty_o        (empty),
        .almost_full_o  (almost_full),
        .rd_data_o      (dout)
    );

    //=========================================================
    // Incremental Data Checker
    //=========================================================
    pattern_checker checker_inst (
        .clk        (clk),
        .rst        (rst),
        .full_empty (checker_empty),
        .dout       (dout),
        .rd         (rd),
        .out        (out),
        .dcheck     (dcheck)
    );

endmodule
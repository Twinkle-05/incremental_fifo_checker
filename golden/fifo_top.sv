`timescale 1us/1us

module fifo_top (
    input  wire        clk,
    input  wire        rst,
    input  wire        en,

    input  wire        load_seed,
    input  wire [7:0]  seed,

    output wire        out,
    output wire        error_flag,
    output wire [15:0] error_count
);

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
    // LFSR Byte-by-Byte Data Generator
    //=========================================================
    generator generator_inst (
        .clk         (clk),
        .rst         (rst),
        .en          (en),
        .almost_full (almost_full),

        .load_seed   (load_seed),
        .seed        (seed),

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
        .rd_en_i        (rd),
        .wr_data_i      (din),

        .full_o         (full),
        .empty_o        (empty),
        .almost_full_o  (almost_full),
        .rd_data_o      (dout)
    );

    //=========================================================
    // Independent LFSR Pattern Checker
    //=========================================================
    pattern_checker checker_inst (
        .clk          (clk),
        .rst          (rst),
        .full_empty   (checker_empty),
        .dout         (dout),

        .load_seed    (load_seed),
        .seed         (seed),

        .rd           (rd),
        .out          (out),
        .error_flag   (error_flag),
        .error_count  (error_count),
        .dcheck       (dcheck)
    );

endmodule
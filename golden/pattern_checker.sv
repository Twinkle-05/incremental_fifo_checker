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

    reg [7:0] lfsr;
    reg [63:0] expected_word;

    function automatic [7:0] next_lfsr(input [7:0] cur);
        begin
            // Same polynomial as generator
            next_lfsr = {cur[6:0], cur[7] ^ cur[5] ^ cur[4] ^ cur[3]};
        end
    endfunction

    function automatic [63:0] build_expected_word(input [7:0] start_lfsr);
        reg [7:0] temp;
        reg [7:0] b0, b1, b2, b3, b4, b5, b6, b7;
        begin
            temp = start_lfsr;

            b0 = temp; temp = next_lfsr(temp);
            b1 = temp; temp = next_lfsr(temp);
            b2 = temp; temp = next_lfsr(temp);
            b3 = temp; temp = next_lfsr(temp);
            b4 = temp; temp = next_lfsr(temp);
            b5 = temp; temp = next_lfsr(temp);
            b6 = temp; temp = next_lfsr(temp);
            b7 = temp;

            build_expected_word = {b7, b6, b5, b4, b3, b2, b1, b0};
        end
    endfunction

    function automatic [7:0] advance_8(input [7:0] start_lfsr);
        integer k;
        reg [7:0] temp;
        begin
            temp = start_lfsr;
            for (k = 0; k < 8; k = k + 1)
                temp = next_lfsr(temp);

            advance_8 = temp;
        end
    endfunction

    always @(*) begin
        rd = !full_empty;
    end

    always @(posedge clk) begin
        if (rst) begin
            lfsr        <= DEFAULT_SEED;
            out         <= 1'b1;
            error_flag  <= 1'b0;
            error_count <= 16'd0;
            dcheck      <= 64'd0;
        end else begin
            if (load_seed) begin
                lfsr        <= (seed == 8'h00) ? DEFAULT_SEED : seed;
                out         <= 1'b1;
                error_flag  <= 1'b0;
                error_count <= 16'd0;
                dcheck      <= 64'd0;
            end else if (!full_empty) begin
                expected_word = build_expected_word(lfsr);
                dcheck <= expected_word;

                if (dout == expected_word) begin
                    out <= 1'b1;
                end else begin
                    out <= 1'b0;
                    error_flag <= 1'b1;
                    error_count <= error_count + 16'd1;
                end

                lfsr <= advance_8(lfsr);
            end
        end
    end

endmodule
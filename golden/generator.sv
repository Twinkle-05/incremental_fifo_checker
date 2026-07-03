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

    reg [7:0] lfsr;
    reg [2:0] byte_pos;
    reg [63:0] pack_reg;

    function automatic [7:0] next_lfsr(input [7:0] cur);
        begin
            // x^8 + x^6 + x^5 + x^4 + 1
            next_lfsr = {cur[6:0], cur[7] ^ cur[5] ^ cur[4] ^ cur[3]};
        end
    endfunction

    always @(posedge clk) begin
        if (rst) begin
            lfsr     <= DEFAULT_SEED;
            byte_pos <= 3'd0;
            pack_reg <= 64'd0;
            din      <= 64'd0;
            wr       <= 1'b0;
        end else begin
            wr <= 1'b0;

            if (load_seed) begin
                lfsr     <= (seed == 8'h00) ? DEFAULT_SEED : seed;
                byte_pos <= 3'd0;
                pack_reg <= 64'd0;
                din      <= 64'd0;
            end else if (en && !almost_full) begin

                case (byte_pos)
                    3'd0: pack_reg[7:0]   <= lfsr;
                    3'd1: pack_reg[15:8]  <= lfsr;
                    3'd2: pack_reg[23:16] <= lfsr;
                    3'd3: pack_reg[31:24] <= lfsr;
                    3'd4: pack_reg[39:32] <= lfsr;
                    3'd5: pack_reg[47:40] <= lfsr;
                    3'd6: pack_reg[55:48] <= lfsr;
                    3'd7: begin
                        din <= {lfsr, pack_reg[55:0]};
                        wr  <= 1'b1;
                    end
                endcase

                lfsr <= next_lfsr(lfsr);

                if (byte_pos == 3'd7)
                    byte_pos <= 3'd0;
                else
                    byte_pos <= byte_pos + 3'd1;
            end
        end
    end

endmodule
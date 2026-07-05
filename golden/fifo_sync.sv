`timescale 1us/1us

module fifo_sync #(
    parameter DATA_WIDTH = 64,
    parameter DEPTH      = 16,
    parameter ADDR_WIDTH = 4
)(
    input  wire                  clk_i,
    input  wire                  rst_i,
    input  wire                  wr_en_i,
    input  wire                  rd_en_i,
    input  wire [DATA_WIDTH-1:0] wr_data_i,

    output wire                  full_o,
    output wire                  empty_o,
    output wire                  almost_full_o,
    output wire [DATA_WIDTH-1:0] rd_data_o
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    reg [ADDR_WIDTH-1:0] wr_ptr;
    reg [ADDR_WIDTH-1:0] rd_ptr;
    reg [ADDR_WIDTH:0]   count;
    reg [DATA_WIDTH-1:0] rd_data_reg;

    assign full_o        = (count == DEPTH);
    assign empty_o       = (count == 0);
    assign almost_full_o = (count >= DEPTH-1);
    assign rd_data_o     = rd_data_reg;

    always @(posedge clk_i) begin
        if (rst_i) begin
            wr_ptr      <= 0;
            rd_ptr      <= 0;
            count       <= 0;
            rd_data_reg <= 0;
        end else begin
            if (wr_en_i && !full_o) begin
                mem[wr_ptr] <= wr_data_i;
                wr_ptr <= wr_ptr + 1'b1;
            end

            if (rd_en_i && !empty_o) begin
                rd_data_reg <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1'b1;
            end

            case ({wr_en_i && !full_o, rd_en_i && !empty_o})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end

endmodule
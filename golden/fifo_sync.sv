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

    assign full_o        = (count == DEPTH);
    assign empty_o       = (count == 0);
    assign almost_full_o = (count >= DEPTH-1);

    assign rd_data_o = mem[rd_ptr];

    always @(posedge clk_i) begin
        if (rst_i) begin
            wr_ptr    <= 0;
            rd_ptr    <= 0;
            count     <= 0;
        end else begin

            // write only if FIFO not full
            if (wr_en_i && !full_o) begin
                mem[wr_ptr] <= wr_data_i;
                wr_ptr <= wr_ptr + 1'b1;
            end

            // read only if FIFO not empty
            if (rd_en_i && !empty_o) begin
                rd_ptr <= rd_ptr + 1'b1;
            end

            // update count
            case ({wr_en_i && !full_o, rd_en_i && !empty_o})
                2'b10: count <= count + 1'b1; // only write
                2'b01: count <= count - 1'b1; // only read
                default: count <= count;      // no change or simultaneous read/write
            endcase
        end
    end

endmodule

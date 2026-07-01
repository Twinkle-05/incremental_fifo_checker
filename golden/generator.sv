`timescale 1us/1us

module generator (
    input  wire        clk,
    input  wire        en,
    input  wire        rst,
    input  wire        almost_full,

    output reg         wr,
    output reg [63:0]  din
);

    parameter MAX_VALUE = 8'h0C;

    reg [7:0] j;
    reg [7:0] arr [0:7];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            j   <= 8'h00;
            din <= 64'h0;
            wr  <= 1'b0;
        end else begin
            if (en && !almost_full) begin
                for (i = 0; i < 8; i = i + 1) begin
                    arr[i] = j;

                    if (j == MAX_VALUE)
                        j = 8'h00;
                    else
                        j = j + 8'h01;
                end

                din <= {arr[7], arr[6], arr[5], arr[4],
                        arr[3], arr[2], arr[1], arr[0]};

                wr <= 1'b1;
            end else begin
                wr <= 1'b0;
                din <= din;
            end
        end
    end

endmodule
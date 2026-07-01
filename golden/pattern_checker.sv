`timescale 1us/1us

module pattern_checker (
    input  wire        clk,
    input  wire        rst,
    input  wire        full_empty,
    input  wire [63:0] dout,

    output reg         rd,
    output reg         out,
    output reg [63:0]  dcheck
);

    parameter MAX_VALUE = 8'h0C;

    reg [7:0] j;
    reg [7:0] arr [0:7];
    reg [63:0] expected;
    integer i;

    always @(*) begin
        rd = !full_empty;
    end

    always @(posedge clk) begin
        if (rst) begin
            j      <= 8'h00;
            dcheck <= 64'h0;
            out    <= 1'b0;
        end else begin
            if (!full_empty) begin
                for (i = 0; i < 8; i = i + 1) begin
                    arr[i] = j;

                    if (j == MAX_VALUE)
                        j = 8'h00;
                    else
                        j = j + 8'h01;
                end

                expected = {arr[7], arr[6], arr[5], arr[4],
                            arr[3], arr[2], arr[1], arr[0]};

                dcheck <= expected;
                out    <= (expected == dout);
            end
        end
    end

endmodule
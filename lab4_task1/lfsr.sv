module lfsr(
    output logic [7:0] out
    ,input logic [7:0] load_num
    ,input logic shift, clk, reset
    );

    logic [7:0] num;

    assign out = num;

    always_ff @(posedge clk) begin
        if (reset) begin
            num <= load;
        end else if (shift) begin
            num <= {1'b0, num[7:1]};
        end
    end

endmodule  // lfsr
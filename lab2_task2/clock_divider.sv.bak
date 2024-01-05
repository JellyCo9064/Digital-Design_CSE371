// divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... [23] = 3Hz, [24] = 1.5Hz, [25] = 0.75Hz, ...
module clock_divider (
  input   logic        clock
  ,output logic [31:0] divided_clocks
  );

  initial begin
    divided_clocks = '0;
  end

  always_ff @(posedge clock) begin
    divided_clocks <= divided_clocks + 'd1;
  end

endmodule  // clock_divider
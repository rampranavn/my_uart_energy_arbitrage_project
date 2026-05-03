module boud_generator #(
  parameter int BOUD_RATE = 9600,      // baud rate for this design
  parameter int CLK_FREQ  = 50000000,  // clock frequency
  parameter int SAMPLING  = 16,        // number of sampling
  parameter int N         = 9          // counter width, works for 50MHz/9600/16 ~= 325
) (
  input  logic clk,
  input  logic rst,
  output logic tick
);

  localparam int DIVIDER = (CLK_FREQ / (BOUD_RATE * SAMPLING));

  logic [N-1:0] counter;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      tick    <= 1'b0 ;
      counter <= '0 ;
    end
    else if (counter == DIVIDER-1) begin
      tick    <= 1'b1 ;
      counter <= '0 ;
    end
    else begin
      counter <= counter + {{(N-1){1'b0}}, 1'b1} ;
      tick    <= 1'b0 ;
    end
  end
endmodule

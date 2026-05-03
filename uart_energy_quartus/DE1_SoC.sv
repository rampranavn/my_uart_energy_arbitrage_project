module DE1_SoC(
  input  logic       CLOCK_50,
  input  logic [3:0] KEY,
  inout  tri   [1:0] GPIO_0,
  output logic [9:0] LEDR
);
  logic rst;
  logic uart_rx;
  logic uart_tx;
  logic charge;
  logic discharge;
  logic idle;
  logic [15:0] price;
  logic [7:0] soc;
  logic [1:0] energy_state;

  assign rst = ~KEY[0];
  assign uart_rx = GPIO_0[0];
  assign GPIO_0[1] = uart_tx;

  uart_energy_top DUT(
    .clk(CLOCK_50),
    .rst(rst),
    .rx(uart_rx),
    .tx(uart_tx),
    .charge(charge),
    .discharge(discharge),
    .idle(idle),
    .price(price),
    .soc(soc),
    .energy_state(energy_state)
  );

  assign LEDR[0] = charge;
  assign LEDR[1] = discharge;
  assign LEDR[2] = idle;
  assign LEDR[4:3] = energy_state;
  assign LEDR[9:5] = soc[4:0];
endmodule

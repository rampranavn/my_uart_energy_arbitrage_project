module uart_energy_top(
  input  logic        clk,
  input  logic        rst,
  input  logic        rx,
  output logic        tx,
  output logic        charge,
  output logic        discharge,
  output logic        idle,
  output logic [15:0] price,
  output logic [7:0]  soc,
  output logic [1:0]  energy_state
);
  logic wr_uart ;
  logic rd_uart ;
  logic tx_full ;
  logic rx_empty ;
  logic [7:0] tx_data ;
  logic [7:0] rx_data ;
  logic sample_valid ;

  top_uart UART(
    .clk(clk),
    .rst(rst),
    .wr_uart(wr_uart),
    .rd_uart(rd_uart),
    .rx(rx),
    .tx(tx),
    .tx_full(tx_full),
    .rx_empty(rx_empty),
    .w_data(tx_data),
    .r_data(rx_data)
  );

  uart_energy_controller CTRL(
    .clk(clk),
    .rst(rst),
    .rx_empty(rx_empty),
    .rx_data(rx_data),
    .rd_uart(rd_uart),
    .tx_full(tx_full),
    .wr_uart(wr_uart),
    .tx_data(tx_data),
    .price(price),
    .soc(soc),
    .sample_valid(sample_valid),
    .charge(charge),
    .discharge(discharge),
    .idle(idle),
    .energy_state(energy_state)
  );

endmodule

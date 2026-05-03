module top_uart(
  input  logic       clk,
  input  logic       rst,
  input  logic       wr_uart,
  input  logic       rd_uart,
  input  logic       rx,
  input  logic [7:0] w_data,
  output logic       tx,
  output logic       tx_full,
  output logic       rx_empty,
  output logic [7:0] r_data
);

  top_transmitter TX(
    .clk(clk),
    .rst(rst),
    .wr_uart(wr_uart),
    .tx_full(tx_full),
    .w_data(w_data),
    .tx(tx)
  );

  top_receiver RX(
    .clk(clk),
    .rst(rst),
    .rd_uart(rd_uart),
    .rx(rx),
    .rx_empty(rx_empty),
    .r_data(r_data)
  );

endmodule

module top_receiver(
  input  logic       clk,
  input  logic       rst,
  input  logic       rd_uart,
  input  logic       rx,
  output logic       rx_empty,
  output logic [7:0] r_data
);

  logic [7:0] rx_data ;
  logic rx_done_tick , s_tick ;
  logic rx_full ;

  fifo rx_fifo(
    .clk(clk),
    .rst(rst),
    .ren(rd_uart),
    .wr(rx_done_tick),
    .w_data(rx_data),
    .empty(rx_empty),
    .full(rx_full),
    .r_data(r_data)
  );

  boud_generator bgen(
    .clk(clk),
    .rst(rst),
    .tick(s_tick)
  );

  receiver rxmod(
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .s_tick(s_tick),
    .rx_done_tick(rx_done_tick),
    .rx_data(rx_data)
  );

endmodule

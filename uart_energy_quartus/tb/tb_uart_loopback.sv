`timescale 1ns/1ps

module tb_uart_loopback;
  logic clk ;
  logic rst ;
  logic wr_uart ;
  logic rd_uart ;
  logic rx ;
  logic [7:0] w_data ;

  logic tx ;
  logic tx_full ;
  logic rx_empty ;
  logic [7:0] r_data ;

  top_uart dut(
    .clk(clk),
    .rst(rst),
    .wr_uart(wr_uart),
    .rd_uart(rd_uart),
    .rx(rx),
    .tx(tx),
    .tx_full(tx_full),
    .rx_empty(rx_empty),
    .w_data(w_data),
    .r_data(r_data)
  );

  // loop TX back into RX
  always_comb rx = tx ;

  // Faster sim baud
  defparam dut.TX.bgen.BOUD_RATE = 1000000 ;
  defparam dut.TX.bgen.N = 3 ;
  defparam dut.RX.bgen.BOUD_RATE = 1000000 ;
  defparam dut.RX.bgen.N = 3 ;

  initial clk = 0 ;
  always #10 clk = ~clk ;

  task automatic write_uart_fifo(input logic [7:0] data);
    begin
      @(posedge clk);
      w_data <= data ;
      wr_uart <= 1'b1 ;
      @(posedge clk);
      wr_uart <= 1'b0 ;
    end
  endtask

  initial begin
    rst = 1 ;
    wr_uart = 0 ;
    rd_uart = 0 ;
    w_data = 0 ;

    repeat(5) @(posedge clk);
    rst = 0 ;

    write_uart_fifo(8'hA5);

    wait(rx_empty == 0);
    @(posedge clk);
    rd_uart <= 1'b1 ;
    @(posedge clk);
    rd_uart <= 1'b0 ;
    @(posedge clk);

    if (r_data == 8'hA5) $display("PASS: loopback received A5");
    else $display("ERROR: expected A5, got %h", r_data);

    $finish;
  end
endmodule

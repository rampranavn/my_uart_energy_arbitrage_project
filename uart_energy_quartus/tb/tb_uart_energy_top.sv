`timescale 1ns/1ps

module tb_uart_energy_top;
  logic clk ;
  logic rst ;
  logic rx ;
  logic tx ;

  logic charge ;
  logic discharge ;
  logic idle ;
  logic [15:0] price ;
  logic [7:0] soc ;
  logic [1:0] energy_state ;

  // For faster simulation, override the baud generator parameters.
  // clk = 50 MHz, baud = 1 MHz, sampling = 16 => divider = 3
  uart_energy_top dut(
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .tx(tx),
    .charge(charge),
    .discharge(discharge),
    .idle(idle),
    .price(price),
    .soc(soc),
    .energy_state(energy_state)
  );

  defparam dut.UART.TX.bgen.BOUD_RATE = 1000000 ;
  defparam dut.UART.TX.bgen.N = 3 ;
  defparam dut.UART.RX.bgen.BOUD_RATE = 1000000 ;
  defparam dut.UART.RX.bgen.N = 3 ;

  localparam integer BIT_TIME = 960 ; // ns for 1 Mbps serial bit with divider=3 at 50 MHz

  initial clk = 0 ;
  always #10 clk = ~clk ; // 50 MHz

  task automatic uart_send_byte(input logic [7:0] data);
    int i ;
    begin
      rx = 1'b0 ;          // start bit
      #(BIT_TIME);

      for (i = 0; i < 8; i = i + 1) begin
        rx = data[i] ;     // LSB first
        #(BIT_TIME);
      end

      rx = 1'b1 ;          // stop bit
      #(BIT_TIME);
    end
  endtask

  task automatic uart_receive_byte(output logic [7:0] data);
    int i ;
    begin
      wait(tx == 1'b0);
      #(BIT_TIME + (BIT_TIME / 2));

      for (i = 0; i < 8; i = i + 1) begin
        data[i] = tx ;
        #(BIT_TIME);
      end

      #(BIT_TIME / 2);
    end
  endtask

  task automatic send_price(input logic [15:0] p);
    begin
      uart_send_byte(p[15:8]);
      uart_send_byte(p[7:0]);
    end
  endtask

  initial begin
    logic [7:0] status_byte ;
    logic [7:0] reported_soc ;
    int i ;

    rx = 1'b1 ;
    rst = 1'b1 ;

    #(500);
    rst = 1'b0 ;
    #(500);

    if (soc != 8'd100) $display("ERROR: expected reset SOC=100, got %0d", soc);

    // price 4000, soc 100 => SELL, then SOC decrements to 99
    send_price(16'd4000);
    uart_receive_byte(status_byte);
    uart_receive_byte(reported_soc);
    if ((status_byte != 8'h53) || (reported_soc != 8'd99) || !discharge || soc != 8'd99) begin
      $display("ERROR: expected SELL/S and SOC=99, got status=%h reported_soc=%0d internal_soc=%0d", status_byte, reported_soc, soc);
    end
    else $display("PASS: SELL detected, SOC decremented");

    // price 2500, soc 99 => IDLE because SOC is still above the buy limit
    send_price(16'd2500);
    uart_receive_byte(status_byte);
    uart_receive_byte(reported_soc);
    if ((status_byte != 8'h49) || (reported_soc != 8'd99) || !idle || soc != 8'd99) begin
      $display("ERROR: expected IDLE/I and SOC=99, got status=%h reported_soc=%0d internal_soc=%0d", status_byte, reported_soc, soc);
    end
    else $display("PASS: IDLE detected, SOC unchanged");

    // Sell ten more times so SOC drops below the buy threshold.
    for (i = 0; i < 10; i = i + 1) begin
      send_price(16'd4000);
      uart_receive_byte(status_byte);
      uart_receive_byte(reported_soc);
    end

    if (soc != 8'd89) $display("ERROR: expected SOC=89 after repeated sells, got %0d", soc);

    // price 2500, soc 89 => BUY, then SOC increments to 90
    send_price(16'd2500);
    uart_receive_byte(status_byte);
    uart_receive_byte(reported_soc);
    if ((status_byte != 8'h42) || (reported_soc != 8'd90) || !charge || soc != 8'd90) begin
      $display("ERROR: expected BUY/B and SOC=90, got status=%h reported_soc=%0d internal_soc=%0d", status_byte, reported_soc, soc);
    end
    else $display("PASS: BUY detected, SOC incremented");

    $display("UART energy top test complete.");
    $finish;
  end

endmodule

`timescale 1ns/1ps

module tb_energy_arbitrage_fsm;
  logic clk ;
  logic rst ;
  logic valid ;
  logic [15:0] price ;
  logic [7:0] soc ;

  logic charge ;
  logic discharge ;
  logic idle ;
  logic [1:0] state ;

  energy_arbitrage_fsm dut(
    .clk(clk),
    .rst(rst),
    .price(price),
    .soc(soc),
    .valid(valid),
    .charge(charge),
    .discharge(discharge),
    .idle(idle),
    .state(state)
  );

  initial clk = 0 ;
  always #10 clk = ~clk ;

  task automatic apply_sample(input logic [15:0] p, input logic [7:0] s);
    begin
      @(posedge clk);
      price <= p ;
      soc <= s ;
      valid <= 1'b1 ;
      @(posedge clk);
      valid <= 1'b0 ;
      @(posedge clk);
    end
  endtask

  initial begin
    rst = 1 ;
    valid = 0 ;
    price = 0 ;
    soc = 0 ;

    repeat(5) @(posedge clk);
    rst = 0 ;

    apply_sample(16'd2500, 8'd50); // BUY
    if (!charge) $display("ERROR: expected BUY/charge");

    apply_sample(16'd4000, 8'd50); // SELL
    if (!discharge) $display("ERROR: expected SELL/discharge");

    apply_sample(16'd3300, 8'd50); // IDLE
    if (!idle) $display("ERROR: expected IDLE");

    apply_sample(16'd2500, 8'd95); // too full to buy
    if (!idle) $display("ERROR: expected IDLE because SOC high");

    apply_sample(16'd4000, 8'd10); // too low to sell
    if (!idle) $display("ERROR: expected IDLE because SOC low");

    $display("Energy FSM test complete.");
    $finish;
  end
endmodule

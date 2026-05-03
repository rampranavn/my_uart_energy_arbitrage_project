module energy_arbitrage_fsm #(
  parameter logic [15:0] BUY_THRESHOLD  = 16'd3000,  // $30.00 encoded as 3000
  parameter logic [15:0] SELL_THRESHOLD = 16'd3600,  // $36.00 encoded as 3600
  parameter logic [7:0]  SOC_MIN        = 8'd20,     // do not sell below 20%
  parameter logic [7:0]  SOC_MAX        = 8'd90      // do not buy above 90%
) (
  input  logic        clk,
  input  logic        rst,
  input  logic [15:0] price,
  input  logic [7:0]  soc,
  input  logic        valid,
  output logic        charge,
  output logic        discharge,
  output logic        idle,
  output logic [1:0]  state
);

  localparam [1:0] S_IDLE = 2'b00 ;
  localparam [1:0] S_BUY  = 2'b01 ;
  localparam [1:0] S_SELL = 2'b10 ;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= S_IDLE ;
    end
    else begin
      if (valid) begin
        if ((price < BUY_THRESHOLD) && (soc < SOC_MAX)) begin
          state <= S_BUY ;
        end
        else if ((price > SELL_THRESHOLD) && (soc > SOC_MIN)) begin
          state <= S_SELL ;
        end
        else begin
          state <= S_IDLE ;
        end
      end
    end
  end

  always_comb begin
    charge    = 1'b0 ;
    discharge = 1'b0 ;
    idle      = 1'b0 ;

    case(state)
      S_BUY: begin
        charge = 1'b1 ;
      end

      S_SELL: begin
        discharge = 1'b1 ;
      end

      default: begin
        idle = 1'b1 ;
      end
    endcase
  end
endmodule

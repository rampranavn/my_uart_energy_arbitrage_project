module uart_energy_controller(
  input  logic        clk,
  input  logic        rst,
  input  logic        rx_empty,
  input  logic [7:0]  rx_data,
  output logic        rd_uart,
  input  logic        tx_full,
  output logic        wr_uart,
  output logic [7:0]  tx_data,
  output logic [15:0] price,
  output logic [7:0]  soc,
  output logic        sample_valid,
  output logic        charge,
  output logic        discharge,
  output logic        idle,
  output logic [1:0]  energy_state
);

  logic [3:0] byte_state ;
  logic [7:0] price_hi ;
  logic [7:0] response_soc ;

  localparam [3:0] WAIT_PRICE_HI = 4'd0 ;
  localparam [3:0] READ_PRICE_HI = 4'd1 ;
  localparam [3:0] SAVE_PRICE_HI = 4'd2 ;
  localparam [3:0] WAIT_PRICE_LO = 4'd3 ;
  localparam [3:0] READ_PRICE_LO = 4'd4 ;
  localparam [3:0] SAVE_PRICE_LO = 4'd5 ;
  localparam [3:0] WAIT_FSM      = 4'd6 ;
  localparam [3:0] UPDATE_SOC    = 4'd7 ;
  localparam [3:0] SEND_STATUS   = 4'd8 ;
  localparam [3:0] SEND_SOC      = 4'd9 ;

  energy_arbitrage_fsm energy_fsm(
    .clk(clk),
    .rst(rst),
    .price(price),
    .soc(soc),
    .valid(sample_valid),
    .charge(charge),
    .discharge(discharge),
    .idle(idle),
    .state(energy_state)
  );

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      byte_state   <= WAIT_PRICE_HI ;
      rd_uart      <= 1'b0 ;
      wr_uart      <= 1'b0 ;
      tx_data      <= 8'h00 ;
      price        <= 16'h0000 ;
      soc          <= 8'd100 ;
      price_hi     <= 8'h00 ;
      response_soc <= 8'd100 ;
      sample_valid <= 1'b0 ;
    end
    else begin
      rd_uart      <= 1'b0 ;
      wr_uart      <= 1'b0 ;
      sample_valid <= 1'b0 ;

      case(byte_state)
        WAIT_PRICE_HI: begin
          if (!rx_empty) begin
            rd_uart <= 1'b1 ;
            byte_state <= READ_PRICE_HI ;
          end
        end

        READ_PRICE_HI: begin
          byte_state <= SAVE_PRICE_HI ;
        end

        SAVE_PRICE_HI: begin
          price_hi <= rx_data ;
          byte_state <= WAIT_PRICE_LO ;
        end

        WAIT_PRICE_LO: begin
          if (!rx_empty) begin
            rd_uart <= 1'b1 ;
            byte_state <= READ_PRICE_LO ;
          end
        end

        READ_PRICE_LO: begin
          byte_state <= SAVE_PRICE_LO ;
        end

        SAVE_PRICE_LO: begin
          price <= {price_hi, rx_data} ;
          sample_valid <= 1'b1 ;
          byte_state <= WAIT_FSM ;
        end

        WAIT_FSM: begin
          // Give energy_arbitrage_fsm one clock to register the new state.
          byte_state <= UPDATE_SOC ;
        end

        UPDATE_SOC: begin
          if ((energy_state == 2'b01) && (soc < 8'd100)) begin
            soc <= soc + 8'd1 ;
            response_soc <= soc + 8'd1 ;
          end
          else if ((energy_state == 2'b10) && (soc > 8'd0)) begin
            soc <= soc - 8'd1 ;
            response_soc <= soc - 8'd1 ;
          end
          else begin
            response_soc <= soc ;
          end

          byte_state <= SEND_STATUS ;
        end

        SEND_STATUS: begin
          if (!tx_full) begin
            wr_uart <= 1'b1 ;

            // ACK/status byte back to PC:
            // 0x42 = BUY, 0x53 = SELL, 0x49 = IDLE
            if (energy_state == 2'b01) begin
              tx_data <= 8'h42 ; // "B"
            end
            else if (energy_state == 2'b10) begin
              tx_data <= 8'h53 ; // "S"
            end
            else begin
              tx_data <= 8'h49 ; // "I"
            end

            byte_state <= SEND_SOC ;
          end
        end

        SEND_SOC: begin
          if (!tx_full) begin
            wr_uart <= 1'b1 ;
            tx_data <= response_soc ;
            byte_state <= WAIT_PRICE_HI ;
          end
        end

        default: begin
          byte_state <= WAIT_PRICE_HI ;
        end
      endcase
    end
  end

endmodule

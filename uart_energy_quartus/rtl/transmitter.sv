module transmitter #(
  parameter int DBIT    = 8,   // number of data bits
  parameter int SB_TICK = 16   // number of stop ticks
) (
  input  logic            clk,
  input  logic            rst,
  input  logic            tx_start,
  input  logic [DBIT-1:0] tx_data,
  input  logic            s_tick,
  output logic            tx_done_tick,
  output logic            tx
);

  logic [3:0] s_reg ;
  logic [2:0] n_reg ;
  logic [DBIT-1:0] b_reg ;
  logic [1:0] state ;

  localparam [1:0] idle=0 , start=1 , data=2 , stop=3 ;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= idle ;
      tx <= 1'b1 ;
      tx_done_tick <= 1'b0 ;
      s_reg <= 4'd0 ;
      n_reg <= 3'd0 ;
      b_reg <= '0 ;
    end
    else begin
      tx_done_tick <= 1'b0 ;

      case(state)
        idle: begin
          tx <= 1'b1 ;
          if (tx_start) begin
            state <= start ;
            s_reg <= 4'd0 ;
            b_reg <= tx_data ;
          end
        end

        start: begin
          tx <= 1'b0 ;
          if (s_tick) begin
            if (s_reg == 4'd15) begin
              state <= data ;
              s_reg <= 4'd0 ;
              n_reg <= 3'd0 ;
            end
            else begin
              s_reg <= s_reg + 4'd1 ;
            end
          end
        end

        data: begin
          tx <= b_reg[0] ;
          if (s_tick) begin
            if (s_reg == 4'd15) begin
              s_reg <= 4'd0 ;
              b_reg <= b_reg >> 1 ;
              if (n_reg == DBIT-1) begin
                state <= stop ;
              end
              else begin
                n_reg <= n_reg + 3'd1 ;
              end
            end
            else begin
              s_reg <= s_reg + 4'd1 ;
            end
          end
        end

        stop: begin
          tx <= 1'b1 ;
          if (s_tick) begin
            if (s_reg == SB_TICK-1) begin
              state <= idle ;
              tx_done_tick <= 1'b1 ;
              s_reg <= 4'd0 ;
            end
            else begin
              s_reg <= s_reg + 4'd1 ;
            end
          end
        end

        default: begin
          state <= idle ;
        end
      endcase
    end
  end
endmodule

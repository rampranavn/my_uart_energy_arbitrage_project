module receiver #(
  parameter int DBIT    = 8,
  parameter int SB_TICK = 16
) (
  input  logic            clk,
  input  logic            rst,
  input  logic            rx,
  input  logic            s_tick,
  output logic            rx_done_tick,
  output logic [DBIT-1:0] rx_data
);

  logic [3:0] s_reg ;
  logic [2:0] n_reg ;
  logic [DBIT-1:0] b_reg ;
  logic [1:0] state ;

  localparam [1:0] idle=0 , start=1 , data=2 , stop=3 ;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= idle ;
      rx_done_tick <= 1'b0 ;
      s_reg <= 4'd0 ;
      n_reg <= 3'd0 ;
      b_reg <= '0 ;
      rx_data <= '0 ;
    end
    else begin
      rx_done_tick <= 1'b0 ;

      case(state)
        idle: begin
          if (~rx) begin
            state <= start ;
            s_reg <= 4'd0 ;
          end
        end

        start: begin
          if (s_tick) begin
            if (s_reg == 4'd7) begin
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
          if (s_tick) begin
            if (s_reg == 4'd15) begin
              b_reg <= {rx,b_reg[DBIT-1:1]} ;
              s_reg <= 4'd0 ;
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
          if (s_tick) begin
            if (s_reg == SB_TICK-1) begin
              state <= idle ;
              rx_done_tick <= 1'b1 ;
              rx_data <= b_reg ;
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

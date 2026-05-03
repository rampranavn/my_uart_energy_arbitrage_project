module top_transmitter(
  input  logic       clk,
  input  logic       rst,
  input  logic       wr_uart,
  input  logic [7:0] w_data,
  output logic       tx_full,
  output logic       tx
);

  logic [7:0] tx_fifo_out ;
  logic tx_empty , tx_done_tick , s_tick ;
  logic tx_start ;
  logic tx_fifo_ren ;
  logic [1:0] tx_ctrl_state ;

  localparam [1:0] TX_WAIT_DATA = 2'd0 ;
  localparam [1:0] TX_READ_FIFO = 2'd1 ;
  localparam [1:0] TX_START_TX  = 2'd2 ;
  localparam [1:0] TX_BUSY_TX   = 2'd3 ;

  fifo tx_fifo(
    .clk(clk),
    .rst(rst),
    .ren(tx_fifo_ren),
    .wr(wr_uart),
    .w_data(w_data),
    .empty(tx_empty),
    .full(tx_full),
    .r_data(tx_fifo_out)
  );

  boud_generator bgen(
    .clk(clk),
    .rst(rst),
    .tick(s_tick)
  );

  transmitter txmod(
    .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .tx_data(tx_fifo_out),
    .s_tick(s_tick),
    .tx_done_tick(tx_done_tick),
    .tx(tx)
  );

  // Control FSM for TX FIFO -> transmitter.
  // FIFO r_data is registered, so read first, then start TX one clock later.
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      tx_start      <= 1'b0 ;
      tx_fifo_ren   <= 1'b0 ;
      tx_ctrl_state <= TX_WAIT_DATA ;
    end
    else begin
      tx_start    <= 1'b0 ;
      tx_fifo_ren <= 1'b0 ;

      case(tx_ctrl_state)
        TX_WAIT_DATA: begin
          if (!tx_empty) begin
            tx_fifo_ren <= 1'b1 ;
            tx_ctrl_state <= TX_READ_FIFO ;
          end
        end

        TX_READ_FIFO: begin
          // One clock later, tx_fifo_out contains the selected byte.
          tx_ctrl_state <= TX_START_TX ;
        end

        TX_START_TX: begin
          tx_start <= 1'b1 ;
          tx_ctrl_state <= TX_BUSY_TX ;
        end

        TX_BUSY_TX: begin
          if (tx_done_tick) begin
            tx_ctrl_state <= TX_WAIT_DATA ;
          end
        end

        default: begin
          tx_ctrl_state <= TX_WAIT_DATA ;
        end
      endcase
    end
  end

endmodule

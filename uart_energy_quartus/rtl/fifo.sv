module fifo #(
  parameter int FIFO_WIDTH   = 8,   // number of bits in a word
  parameter int FIFO_DEPTH   = 16,  // number of FIFO entries
  parameter int POINTER_SIZE = 4    // log2(FIFO_DEPTH)
) (
  input  logic                    clk,
  input  logic                    rst,
  input  logic                    ren,
  input  logic                    wr,
  input  logic [FIFO_WIDTH - 1:0] w_data,
  output logic                    empty,
  output logic                    full,
  output logic [FIFO_WIDTH - 1:0] r_data
);

  logic [FIFO_WIDTH - 1:0] mem_fifo [FIFO_DEPTH - 1:0] ;

  // One extra MSB is used as a wrap bit.
  logic [POINTER_SIZE:0] rd_ptr, wr_ptr ;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      wr_ptr <= '0 ;
    end
    else begin
      if (wr && full != 1) begin
        mem_fifo[wr_ptr[POINTER_SIZE-1:0]] <= w_data ;
        wr_ptr <= wr_ptr + {{POINTER_SIZE{1'b0}}, 1'b1} ;
      end
    end
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      rd_ptr <= '0 ;
      r_data <= '0 ;
    end
    else begin
      if (ren && empty != 1) begin
        r_data <= mem_fifo[rd_ptr[POINTER_SIZE-1:0]] ;
        rd_ptr <= rd_ptr + {{POINTER_SIZE{1'b0}}, 1'b1} ;
      end
    end
  end

  assign full  = (wr_ptr[POINTER_SIZE] != rd_ptr[POINTER_SIZE]) &&
                 (wr_ptr[POINTER_SIZE-1:0] == rd_ptr[POINTER_SIZE-1:0]) ;

  assign empty = (wr_ptr == rd_ptr) ;

endmodule

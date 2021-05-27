
module snes_igr (
  input CLK_i,
  input NRST_i,

  input CTRL_CLK_i,
  input CTRL_LATCH_i,
  input CTRL_SDATA_i,
  
  output reg [15:0] pdata_LL,

  output reg FORCE_REGION_o,
  output reg PALMODE_o,
  
  output reg [1:0] REQ_RST_o
);


`define CMD_FORCE_VMODE_BIOS  16'h5fcf
`define CMD_FORCE_VMODE_NTSC  16'hdf4f
`define CMD_FORCE_VMODE_PAL   16'h9fcf
`define CMD_REQ_SRST          16'hcfcf
`define CMD_REQ_DRST          16'hdf8f
`define CMD_REQ_LRST          16'hd7cf


reg spi_en = 1'b0;
reg [15:0] pdata = 16'b0;
reg pdata_valid_tgl = 1'b0;
reg [3:0] spi_cnt = 4'd0;

reg clk_edge = 1'b0;


//always @(negedge CTRL_CLK_i or posedge CTRL_LATCH_i or negedge NRST_i)begin
always @(posedge CLK_i or negedge NRST_i)begin
  
  if (!NRST_i) begin
    spi_en <= 1'b0;
    pdata <= 16'b0;
    pdata_valid_tgl <= 1'b0;
    spi_cnt <= 4'd0;
	 clk_edge <= 1'b0;
	 //FORCE_REGION_o <= 1'b0;
    //PALMODE_o <= 1'b0;
    //REQ_RST_o <= 2'b00;
  end else if (CTRL_LATCH_i) begin
    spi_en <= 1'b1;
    spi_cnt <= 4'd15;
    pdata <= 16'h0000;
	 clk_edge <= 1'b0;
  end else if (!CTRL_CLK_i &!clk_edge) begin
    //if (spi_en) begin
	 clk_edge <= 1'b1;
	 pdata[spi_cnt] <= CTRL_SDATA_i;
	 if (~|spi_cnt) begin
	   spi_en <= 1'b0;
	   pdata_valid_tgl <= ~pdata_valid_tgl;
	 end else begin
	   spi_cnt <= spi_cnt - 1'd1;		  
	 end
  end else if (CTRL_CLK_i) begin
	 clk_edge <= 1'b0;
  end
end


//reg [15:0] pdata_L, pdata_LL;
reg [15:0] pdata_L;
reg pdata_valid_tgl_L, pdata_valid_tgl_LL, pdata_valid_tgl_LLL;

always @(posedge CLK_i) begin
  pdata_LL <= pdata_L;
  pdata_L <= pdata;
  pdata_valid_tgl_LLL <= pdata_valid_tgl_LL;
  pdata_valid_tgl_LL <= pdata_valid_tgl_L;
  pdata_valid_tgl_L <= pdata_valid_tgl;
end


always @(posedge CLK_i or negedge NRST_i)
  if (!NRST_i) begin
    FORCE_REGION_o <= 1'b0;
    PALMODE_o <= 1'b0;
    REQ_RST_o <= 2'b00;
  end else begin
    if (pdata_valid_tgl_LLL ^ pdata_valid_tgl_LL) begin
      case (pdata_LL)
        `CMD_FORCE_VMODE_BIOS: begin
            FORCE_REGION_o <= 1'b0;
          end
        `CMD_FORCE_VMODE_NTSC: begin
            FORCE_REGION_o <= 1'b1;
            PALMODE_o <= 1'b0;
          end
        `CMD_FORCE_VMODE_PAL: begin
            FORCE_REGION_o <= 1'b1;
            PALMODE_o <= 1'b1;
          end
        `CMD_REQ_SRST: begin
            REQ_RST_o <= 2'b01;
          end
        `CMD_REQ_DRST: begin
            REQ_RST_o <= 2'b10;
          end
        `CMD_REQ_LRST: begin
            REQ_RST_o <= 2'b11;
          end
      endcase
    end
  end

endmodule

`ifndef _osd_vh_
`define _osd_vh_


parameter FONT_WIDTH = 8;
parameter FONT_HEIGHT = 12;

parameter OSD_CHAR_IN_ROWS = 42;
parameter OSD_NUMBER_ROWS = 8;

parameter OSD_X1 = 22 + 44;
parameter OSD_X2 = (FONT_WIDTH * OSD_CHAR_IN_ROWS / 2) - 1 + OSD_X1;
parameter OSD_Y1_NTSC = 64;
parameter OSD_Y2_NTSC = (FONT_HEIGHT * OSD_NUMBER_ROWS) - 1 + OSD_Y1_NTSC;
parameter OSD_Y1_PAL = 64;
parameter OSD_Y2_PAL = (FONT_HEIGHT * OSD_NUMBER_ROWS) - 1 + OSD_Y1_PAL;

reg osd_on = 0;
reg [8:0] v_count; //1..224/239, v_count = 0 when VBLANK is cleared
reg [8:0] h_count; //22..277, h_count = 1 when HBLANK is cleared
reg [1:0] osd_brightness;

`endif
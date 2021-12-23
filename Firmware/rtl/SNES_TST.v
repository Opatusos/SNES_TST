`define EDGE_SENSITIVE_CLKEN

module SNES_TST(
	input VBLANK,				//0: not vblank; 1: vblank
	input HBLANK,				//0: not hblank; 1: hblank
	input PAWR,					//PPU data write enable
	input PARD,					//PPU data read enable
	input FIELD,				//shows if the actual field is even or odd
	input TOUMEI,				//???shows if the screen is all black or not???
	input CSYNCI,				//csync from PPU2
	output CSYNCO,				//csync to system; can be dejittered
	input [7:0] PADDRESS,	//PPU Address
	input [7:0] DATA,			//PPU Data
	input MCLKSYS,				//Master Clock from system
	input MCLKOSC,				//Master Clock from oscillator
	output REGPSEL,			//D4 region patch control; 0: patch not applied; 1: patch applied (this signal could be dropped, if a new signal is needed)
	output REGPAT,				//D4 region patch value; 0: PAL; 1: NTSC
	input SYSREG,	 			//identifies the system region; 0: NTSC; 1: PAL
	output MD7PAT,				//applies the patch for mode 7
	input OVER1,				//from PPU1; shows if the actual pixel is inside or outside of Mode7 memory
	output OVERPAT,			//goes to PPU2; same as the OVER1 signal, only differs if the mode 7 patch is applied
	output MCLKO,				//Master Clock to system
	input SUBCAR,				//subcarrier output for NTSC systems; this will not get dejittered
	input RESETI,				//reset signal from Reset Button; 0: run; 1: reset
	output RESETO,				//reset signal to PPU2; 0: run; 1: reset
	output REGION,	 			//sets the region; 0: NTSC; 1: PAL
	inout [3:0] CIC,			//Cic signals
	input CONTL,	 			//input controller latch
	input CONTD,	 			//input controller data
	output CONTDOUT,			//output controller data; input for system can be disabled
	input CONTC,	 			//input controller clock
	output [3:1] LED,
	output RGBSEL,	 			//0: PPU RGB; 1: FPGA RGB
	output AMPFILT, 			//0: THS7374 filter is on; 1: filter is off
	output DACCLK,
	output CSYNCDAC,			//0: sync on green off
	output BLANKDAC,			//0: drives ADV7123 to blanking
	output PPURESET,			//0: PPU2 is off; 1: PPU2 is on
	
	input [4:0] TST_R,
	input [4:0] TST_G,
	input [4:0] TST_B,
	output TST15,	 			//0: PPU2 Test Mode off; 1: PPU2 Test Mode On

	//output reg[9:1] RDIG,
	output [9:1] RDIG,
	output [9:1] GDIG,
	output [9:1] BDIG
);

`include "include/osd.vh"

wire mclk_ntsc = MCLKOSC;
wire mclk_ntsc_dejitter = mclk_ntsc & gclk_en;
wire mclk_pal = MCLKSYS;


wire [7:0] data = DATA;
wire [7:0] address = PADDRESS;
wire pawr = PAWR;

//wire screen_over_data = data[7] & !data[6];
reg mode01234;
reg mode7;
reg mode56;
reg pseudohires;
reg screen_over;
//assign mode7 = (mode == 7) ? 1'b1 : 1'b0; 
wire over;


wire mclock;
wire dacclock256h;
wire dacclock512h;
wire dacclock;
assign dacclock = (mode56 | (pseudohires & mode01234)) ? dacclock512h : dacclock256h;
wire clockosc = MCLKOSC;
wire clocksys = MCLKSYS;

wire resetin = RESETI;
wire resetout;
wire region = ciccontrol[0];
wire sysregion = SYSREG;

//wire [3:0] cic;
//assign CIC = cic;


//assign GCLK_o = SYSREG ? mclk_pal : mclk_ntsc_dejitter;
//assign CSYNCO = SYSREG ? CSYNCI : csync_dejitter;

reg[9:1] rdig;
reg[9:1] gdig;
reg[9:1] bdig;

assign RDIG = rdig;
assign GDIG = gdig;
assign BDIG = bdig;


assign MCLKO = mclock;
//assign MCLKO =mclk_ntsc;
assign CSYNCO = CSYNCI;
//assign TST15 = 1'b1;
//assign TST15 = (VBLANK | blanking) ? 1'b0 : 1'b1;
assign TST15 = (VBLANK) ? 1'b0 : 1'b1;
assign RGBSEL = 1'b1;
//assign RGBSEL = testoutput[5];
assign AMPFILT = 1'b1;
assign DACCLK = dacclock;
//assign DACCLK = MCLKO;
assign CSYNCDAC = 1'b0;
//assign BLANKDAC = 1'b1;
assign BLANKDAC = CSYNCO;
//assign REGION = SYSREG;
//assign REGION = !SYSREG;
assign REGION = region;
//assign REGION = regio;

assign REGPSEL = 1'b0;
assign REGPAT = 1'b1;
assign MD7PAT = over & !OVER1;
assign OVERPAT = over ? 1'b1 : OVER1;
//output MCLKO,

//assign RESETO = RESETI;
assign RESETO = resetout;

//assign LED[1] = 1'b1;
//assign LED[1] = test1;
assign LED[1] = cicfail;
assign LED[3] = over;
//assign RDIG[9] = 1'b1;

assign PPURESET = 1'b1;

wire regio;
reg [10:0] h_cnt;
reg [2:0] g_cyc;
reg csync_prev;
reg csync_dejitter;
reg gclk_en;
//reg [1:0] sc_ctr;
reg [2:0] address_edge;
//reg [2:0] mode;
//reg mode_edge;
//reg screen_over_edge;
reg [3:0] brightness;
reg blanking;

reg [26:0] Y;
reg Pb;
reg Pr;

reg [15:0] cictest;

reg [1:0] ciccontrol;
reg cicfail;

reg [1:0] vclk_counter;

//reg [2:0]rgbout;
//reg vbl;



assign over = mode7 & screen_over;
//assign OVERPAT = over ? over : OVER1;
//assign OVERPAT = over ? over : OVER1;
//assign TST = 4'b1000;
//assign TST15 = 1'b1;
//assign TST15 = CSYNCO;
//assign TST15 = TOUMEI;
//assign RESETO = RESETI;
//assign REGPSEL = 1'b0;

reg resetcic;

wire [9:1] digitalgreen ;

//reg [9:1] red;
//assign RDIG[9:1] = red[9:1];

wire [31:0] testoutput;
wire [2:0] sync;

assign sync[0] = VBLANK;
assign sync[1] = HBLANK;
assign sync[2] = CSYNCI;

//assign RDIG[9:1] = HBLANK ? 0 : rgb[8:0];
//assign GDIG[8:0] = rgb[17:9];
//assign BDIG[8:0] = rgb[26:18];
/*
snes_tst_cpu snes_tst_logic_controller (
	.reset_reset_n ( resetout ),
	.clk_clk ( mclock ),
	.config_output_export (testoutput),
	.cont_data_export (contdata)
	);
*/

//wire [9:1] GDIG = digitalgreen[9:1];

//wire [4:0] inputgreen  = TST_G;

//assign SPARE1 = over;

/*always @(*) begin
	case(PADDRESS [7:0])
		8'b00000000: address_edge <= 3'b110;
		8'b00000101: address_edge <= 3'b101;
		8'b00011010: address_edge <= 3'b011;
		default: address_edge <= 3'b111;
	endcase
end*/
/*
always @(*) begin
	if((PADDRESS [7:0] == 8'b00111111) && !PARD)
		DATA[4] <= SUPERCIC_REGION;
	else DATA[4] <= 1'bz;
end
*//*
multiplier	multiplier_red (
	.dataa ( TST_R ),
	.datab ( brightness ),
	.result ( RDIG )
	);*/
/*multiplier	multiplier_green (
	.dataa ( TST_G ),
	.datab ( brightness ),
	.result ( GDIG )
	);*/
	/*
multiplier	multiplier_blue (
	.dataa ( TST_B ),
	.datab ( brightness ),
	.result ( BDIG )
	);*/
	
	
/*
cic_lock_top snes_tst_cic (
	.cic_clk (CIC[3]),
	.pll_locked (CONTL),   
	.pll_rst_n (CSYNCDAC),
	.port0_IN  (RESETI),
	.port0_OUT (RGBSEL),
	.port0_OE (AMPFILT),
	.dir (BLANKDAC),
	.cart_cic_reset (MD7PAT),
	.sys_reset (RESETO)
	);

*/
wire test1;
wire test2;
wire test3;

clock snes_tst_clock(
	.clockosc (clockosc),
	.clocksys (clocksys),
	.region (region),
	.sysregion (sysregion),
	.reset (resetout),
	
	.mclock (mclock),
	.dacclock256h (dacclock256h),
	.dacclock512h (dacclock512h)
);

cic_lock_top snes_tst_cic (
		
		.cic_clk (CIC[3]),
		.pll_locked (resetcic),
		
		.port0_INOUT (CIC[1:0]),
		
		.pal_ntsc (ciccontrol[0]),
		.cic_fail (cicfail),
		
		.cart_cic_reset (CIC[2]),
		.sys_reset (resetout)
	);

wire [15:0] contdata;
	
snes_igr snes_tst_igr(
	.CLK_i (mclock),
   .NRST_i (resetout),

   .CTRL_CLK_i (CONTC),
   .CTRL_LATCH_i (CONTL),
   .CTRL_SDATA_i (CONTD),

	.pdata_LL (contdata),
	
   .FORCE_REGION_o (test1),
   .PALMODE_o (test2),
  
   .REQ_RST_o (test3)
	);
	/*
always @(posedge mclk_ntsc) begin
    if ((h_cnt >= 1024) && (csync_prev==1'b1) && (CSYNCI==1'b0)) begin
        h_cnt <= 0;
        if (h_cnt == 340*4-1)
            g_cyc <= 4;
        else
            csync_dejitter <= CSYNCI;
    end else begin
        h_cnt <= h_cnt + 1'b1;
        if (g_cyc > 0)
            g_cyc <= g_cyc - 1'b1;
        if (g_cyc <= 1)
            csync_dejitter <= CSYNCI;
    end

    csync_prev <= CSYNCI;
end*/
/*
always @(posedge mclk_ntsc) begin
    if (sc_ctr == 2'h2) begin
        sc_ctr <= 2'h0;
        SC_o <= ~SC_o;
    end else begin
        sc_ctr <= sc_ctr + 2'h1;
    end
end
*/

reg [10:0]font_address;
reg [3:0]font_x_counter;
wire [7:0]font_data;
reg font_bit;
reg [3:0]font_y_counter;
reg y_helper;


font_rom	font_rom_inst (
	.address ( font_address ),
	.clock ( mclock ),
	.q ( font_data )
	);


//always @(negedge dacclock) begin
always @(negedge mclock) begin
	if(VBLANK)begin
		font_address[10:0] <= 0;
		font_x_counter <= 0;
		font_y_counter <= 0;
		/*if(font_y_counter[3:0] < 12) font_y_counter[3:0] <= font_y_counter[3:0] + 1;
		else font_y_counter[3:0] <= 0;*/
	end
	if(HBLANK) y_helper <= 0;
	if((h_count > OSD_X1) && (h_count <= OSD_X2) && (v_count > OSD_Y1_NTSC) && (v_count <= OSD_Y2_NTSC)) begin
		osd_brightness <= 4;
		//font_bit <= font_data[font_x_counter[3:1] +:1];
		font_bit <= (font_data & (8'b1 << font_x_counter[3:1])) ? 1'b1 : 1'b0;
		//font_bit <= (8'b10100110 & (8'b1 << font_x_counter[3:1])) ? 1'b1 : 1'b0;
		//font_bit <= font_data[3] ? 1'b1 : 1'b0;
		//font_bit <= (font_data & 8'b00000100) ? 1'b1 : 1'b0;
		//font_bit <= font_data ? 1'b1 : 1'b0;
		if(font_x_counter==13 && h_count > (OSD_X1 + 3)) font_address[10:0] <= font_address[10:0] + 4'b1100;
	end
	else begin
		osd_brightness <= 0;
		font_bit <= 0;
	end
	if(h_count == OSD_X1) begin
		font_x_counter <= 0;
		font_address[10:0] <= {7'b000_0000, font_y_counter[3:0]};
	end
	else if((h_count > OSD_X1) && (h_count <= OSD_X2)) begin
		font_x_counter <= font_x_counter + 1;
	end
	else if (h_count == (OSD_X2 + 1) && y_helper == 0) begin
		y_helper <= 1;
		if(font_y_counter < 4'd11) font_y_counter <= font_y_counter + 1'b1;
		else font_y_counter <= 0;
	end
	
	//RDIG[9:1] <= TST_R[4:0] *(* multstyle = "dsp" *) 4'b1111;
	//GDIG[9:1] <= TST_G[4:0] *(* multstyle = "dsp" *) 4'b1111;
	//BDIG[9:1] <= TST_B[4:0] *(* multstyle = "dsp" *) 4'b1111;
	
	rdig[9:1] <= TST_R[4:0] *(* multstyle = "dsp" *) brightness;
	gdig[9:1] <= TST_G[4:0] *(* multstyle = "dsp" *) brightness;
	bdig[9:1] <= TST_B[4:0] *(* multstyle = "dsp" *) brightness;

	
	/*if(font_bit) begin
		RDIG[9:1] <= 465;
		GDIG[9:1] <= 465;
		BDIG[9:1] <= 465;
	end
	else begin
		RDIG[9:1] <= (TST_R[4:0] >> osd_brightness) *(* multstyle = "dsp" *) brightness;
		GDIG[9:1] <= (TST_G[4:0] >> osd_brightness) *(* multstyle = "dsp" *) brightness;
		BDIG[9:1] <= (TST_B[4:0] >> osd_brightness) *(* multstyle = "dsp" *) brightness;
	end*/
	//GDIG[9:1] <= (font_x_counter[3:0] ) *(* multstyle = "dsp" *) brightness;
	//RDIG[9:1] <= font_bit ? 465 : (TST_R[4:0] >> osd_brightness) *(* multstyle = "dsp" *) brightness;
	//RDIG[9:1] <= rgb[8:0];
	/*if (VBLANK || HBLANK) begin
		red = 0;
	end
	else begin
		red[9:1] <= 300;//rgb[8:0];
	end*/
	//GDIG[9:1] <= font_bit ? 465 : (TST_G[4:0] >> osd_brightness) *(* multstyle = "dsp" *) brightness;
	//BDIG[9:1] <= font_bit ? 465 : (TST_B[4:0] >> osd_brightness) *(* multstyle = "dsp" *) brightness;
end

always @(posedge mclock) begin
	vclk_counter <= vclk_counter + 1;
	if(VBLANK) begin
		v_count <= 0;
		h_count <= 0;
	end
	/*else begin
		if(vclk_counter == 0) v_count <= v_count + 1;
	end*/
	/*if(HBLANK) begin
		h_count = 1;
	end*/
	else begin
		if(h_count >= 337) begin
			h_count <= 0;
			v_count <= v_count + 1;
		end
		else if(HBLANK && h_count == 0) h_count <= 0;
		else begin
			if(vclk_counter == 0) h_count <= h_count + 1;
		end
	end
end


/*
always @(negedge dacclock) begin
	RDIG[9:1] <= rgb[8:0];
	//GDIG[9:1] <= rgb[17:9];
	GDIG[9:1] <= TST_G[4:0] *(* multstyle = "dsp" *) brightness;
	BDIG[9:1] <= rgb[26:18];
end
	*/
`ifdef EDGE_SENSITIVE_CLKEN
//Update clock gate enable signal on negative edge
always @(negedge mclock) begin
   gclk_en <= (g_cyc == 0);
	/*if(!PAWR && !address_edge[0]) BRIGHTNESS [3:0] <= DATA [3:0];
	if(!PAWR && !address_edge[1]) mode <= mode_data;
	if(!PAWR && !address_edge[2]) screen_over <= screen_over_data;*/
	if(resetout) begin
		//brightness [3:0] <= 4'b1111;
		if(!pawr && (address [7:0] == 8'b00000000))begin
			brightness [3:0] <= data [3:0];
			blanking <= data[7];
		end
		
		if(!pawr && (address [7:0] == 8'h05)) begin
			
			if(data[2:0] == 3'b111) begin
				mode7 <= 1'b1;
				mode56 <= 1'b0;
				mode01234 <= 1'b0;
			end
			else if(data[2:0] == 3'b101 || data[2:0] == 3'b110) begin
				mode7 <= 1'b0;
				mode56 <= 1'b1;
				mode01234 <= 1'b0;
			end
			else begin
				mode7 <= 1'b0;
				mode56 <= 1'b0;
				mode01234 <= 1'b1;
			end
		end
		
		else if(!pawr && (address [7:0] == 8'h1A)) begin
			if(data[7:6] == 2'b10)
				screen_over <= 1'b1; 
			else screen_over <= 1'b0;
		end
		
		else if(!pawr && (address [7:0] == 8'h33)) begin
			if(data[3] == 1'b1) pseudohires <= 1'b1;
			else pseudohires <= 1'b0;
		end
		//register 2133 D3 -> pseudo 512, most likely 10 MHz video clock is needed
		//true 512 mode on mode 5 and 6
		
		
	end
	else begin
		brightness [3:0] <= 4'b1111;
		mode7 <= 1'b0;
		mode56 <= 1'b0;
		mode01234 <= 1'b0;
		pseudohires <= 1'b0;
		screen_over <= 1'b0;
		//rgbout <= 3'b000;
		//vbl <= 1;
	end
	/*if(HBLANK) begin
		if(vbl)begin
			rgbout <= 3'b020;
			vbl <= 1'b0;
		end
	end
	else begin vbl <=1'b1;
	end*//*
	if(RESETI) begin
		cictest <= 0;
		resetcic<= 1'b0;
	end
	else begin
		cictest <= cictest + 1'b1;
		if(cictest == 32767) resetcic <= 1'b1;
	end*/
	/*if(rgbout < 3'b100)begin
		rgbout <= rgbout + 1'b1;
	end*/
	//else begin
		//rgbout <= 3'b000;
	
	
	/*
	RDIG[9:1] <= TST_R[4:0] *(* multstyle = "dsp" *) brightness;
	GDIG[9:1] <= TST_G[4:0] *(* multstyle = "dsp" *) brightness;
	BDIG[9:1] <= TST_B[4:0] *(* multstyle = "dsp" *) brightness;
	*/
	
	
	//end
	//RDIG[9:1] <= TST_R[4:0] * brightness;
	//GDIG[9:1] <= TST_G[4:0] * brightness;
	//BDIG[9:1] <= TST_B[4:0] * brightness;

	/*Y[26:0] <= (RDIG[9:1] *(* multstyle = "dsp" *) 78381) + (GDIG[9:1] *(* multstyle = "dsp" *) 153879) + (BDIG[9:1] *(* multstyle = "dsp" *) 29884);
	RDIG[9:1] <= Y[26:0] / 262144;*/
	/*Y[26:0] <= (RDIG[9:1] *(* multstyle = "dsp" *) 153) + (GDIG[9:1] *(* multstyle = "dsp" *) 301) + (BDIG[9:1] *(* multstyle = "dsp" *) 58);
	GDIG[9:1] <= Y[26:0] / 512;*/

	/*if(brightness [3:0] == 4'b0001) begin
		if(TST_R[4:0] == 5'b00001) RDIG[9:1] <= 9'b000000001;
		if(TST_R[4:0] == 5'b00010) RDIG[9:1] <= 9'b000000010;
		if(TST_R[4:0] == 5'b00011) RDIG[9:1] <= 9'b000000011;
		if(TST_R[4:0] == 4) RDIG[9:1] <= 4;
		if(TST_R[4:0] == 5) RDIG[9:1] <= 5;
		if(TST_R[4:0] == 6) RDIG[9:1] <= 6;
		if(TST_R[4:0] == 7) RDIG[9:1] <= 7;
		if(TST_R[4:0] == 8) RDIG[9:1] <= 8;
		if(TST_R[4:0] == 9) RDIG[9:1] <= 9;
		if(TST_R[4:0] == 10) RDIG[9:1] <= 10;
		if(TST_R[4:0] == 11) RDIG[9:1] <= 11;
		if(TST_R[4:0] == 12) RDIG[9:1] <= 12;
	end*/
		
end
`else
//ATF1502AS macrocells support D latch mode,
//enabling level sensitive update of gclk_en during negative phase
always @(*) begin
    if (!mclk_ntsc)
        gclk_en <= (g_cyc == 0);
end
`endif




//cic control
always @(negedge mclock) begin
	if(resetin) begin
		ciccontrol[1:0] <= 2'b00;
		cictest <= 0;
		resetcic<= 1'b0;
	end
	else begin
		if(!cicfail) ciccontrol[1] <= 1'b0;
		else if(!ciccontrol[1]) begin 
			ciccontrol[0] <= ~ciccontrol[0];
			ciccontrol[1] <= 1'b1;
			cictest <= 0;
			resetcic<= 1'b0;
		end
		
		if(cictest != 32767) begin
			//resetcic <= 1'b0;
			if(cictest < 32766)cictest <= cictest + 1'b1;
			else begin
				//ciccontrol[0] <= ~ciccontrol[0];
				resetcic<= 1'b1;
				cictest <= 32767;
			end
		end
		//else begin
			//resetcic<= 1'b1;
		//end
		
		//cictest <= cictest + 1'b1;
		//if(cictest == 32767) resetcic <= 1'b1;
	end
end

endmodule
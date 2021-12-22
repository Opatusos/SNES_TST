module clock(
	input clockosc,
	input clocksys,
	input region,
	input sysregion,
	input reset,
	
	output mclock,
	output dacclock256h,
	output dacclock512h
);

	wire locked;
	//wire mclockntsc;
	//wire mclockpal;
	pll	snes_tst_pll (
		.inclk0 ( clockosc ),
		.c0 ( mclockntsc ),
		.c1 ( mclockpal ),
		.locked ( locked )
		);


	assign mclock = locked ? (sysregion ? (region ? clocksys : mclockntsc) : (region ? mclockpal : clocksys)) : 1'b0;	
//assign mclock = clocksys;
//assign mclock = region ? clocksys : mclockntsc;
	reg [1:0] dacclockdivider;
	assign dacclock256h = dacclockdivider[1];
	assign dacclock512h = dacclockdivider[0];

	always @(posedge mclock) begin
		if(!reset) dacclockdivider <= 2'b00;
		else begin
			dacclockdivider <= dacclockdivider + 1'b1;
			//if(dacclockdivider[ == 
			//dacclock256h <= ~dacclock256h;
		end
	end

endmodule

# SNES-TST

This projects intends to clean up the blurry RGB video on the 3-chip SNES by using the PPU2's test pins. The board has only been tried on a SNSP-CPU-01 motherboard but it should work with all revisions. The firmware is missing most of the board's functions. The planned functions are the following:
- dual analog ouput (verified, need further noise analysis, furthermore direct comparision is needed to the original video)
- Mode-7 patch for the test pins (verified)
- SuperCIC (verified)
- dual-frequency oscillator (not tested)
- controller support (partwise verified)
- dejitter (not tested)
- D4 patch (not tested)
- RGB LED support with PWM (not tested)

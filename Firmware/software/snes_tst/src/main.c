/*********************************************************************************
 *
 * This file is part of the SNES TST project.
 *
 * SNES TST is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 * main.c
 *
 *  Created on: 12 May 2021
 *      Author: Opatus
 */

#include "config.h"
#include "system.h"
#include "alt_types.h"
#include "osd.h"

int main() {
	alt_u32 controller;
	/*
	alt_u32 testRGBOut;
	alt_u16 testDataR,testDataG, testDataB;
	alt_u8 testSync = 4, syncFlag = 0;
	initializeConfig ();

	testDataR = 116;
	testDataG = 116;
	testDataB = 232;
	*/
	/* Event loop never exits. */
	while (1){


		controller = IORD_ALTERA_AVALON_PIO_DATA(CONTROLLER_DATA_BASE);
		IOWR_ALTERA_AVALON_PIO_DATA(CONFIG_OUTPUT_BASE, controller);

/*		if(syncFlag){
			testDataR = 116;
			//if(testDataG < 465) testDataG++;
			//else testDataG = 116;
		}
		else{
			//testDataG = 116;
			if(testDataR < 465) testDataR++;
			else testDataR = 116;
			//testDataR = 300;
		}
		testRGBOut = testDataR + (testDataG << 9) + (testDataB << 18);

		//testDataR = testSync * 90;
		IOWR_ALTERA_AVALON_PIO_DATA(CONFIG_OUTPUT_BASE, testRGBOut);

		testSync = IORD_ALTERA_AVALON_PIO_DATA(SYNC_BASE);
		syncFlag = (testSync & 0b001) ? 1 : 0;
	*/
	}

	return 0;
}

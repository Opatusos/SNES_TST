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
 * osd.c
 *
 *  Created on: 12 May 2021
 *      Author: Opatus
 */

#include "osd.h"
#include "system.h"
#include "alt_types.h"
#include "altera_avalon_pio_regs.h"

void print_osd_data(const char* combined_font_data, alt_u16 start_position){
	alt_u8 i = 0;
	alt_u8 char_position = start_position;
	alt_u32 osd_data;
	alt_u16 x_position = start_position % OSD_LINE_LENGTH;

	//OSDRAM_WR_ENABLE();
	while(combined_font_data[i]){
		if((x_position + i) > OSD_LINE_LENGTH) break;
		osd_data = OSDRAM_WR_BITS + (char_position << OSDRAM_POSITION_SHIFT) + (combined_font_data[i] << OSDRAM_FONT_SHIFT);
		print_osd_char(osd_data);
		i++;
		char_position++;


	}
	OSDRAM_WR_DISABLE();
}

void print_osd_char(alt_u32 osd_data){
	IOWR_ALTERA_AVALON_PIO_DATA(OSD_RAM_BASE, osd_data);
}



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
 * osd.h
 *
 *  Created on: 12 May 2021
 *      Author: Opatus
 */

#include "alt_types.h"

#ifndef SRC_OSD_H_
#define SRC_OSD_H_

#define OSD_LINE_LENGTH				46

#define OSDRAM_POSITION_SHIFT		2
#define OSDRAM_FONT_SHIFT    		(OSDRAM_POSITION_SHIFT + 9)
#define OSDRAM_WR_BITS				0b01

#define OSDRAM_WR_ENABLE()			IOWR_ALTERA_AVALON_PIO_SET_BITS(OSD_RAM_BASE,OSDRAM_WR_BITS)
#define OSDRAM_WR_DISABLE()			IOWR_ALTERA_AVALON_PIO_CLEAR_BITS(OSD_RAM_BASE,OSDRAM_WR_BITS)

void print_osd_data(const char* combined_font_data, alt_u16 start_position);
void print_osd_char(alt_u32 osd_data);


#endif /* SRC_OSD_H_ */

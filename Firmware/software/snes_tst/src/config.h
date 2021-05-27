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
 * config.h
 *
 *  Created on: 12 May 2021
 *      Author: Opatus
 */

#include "alt_types.h"
#include "altera_avalon_pio_regs.h"

#ifndef SRC_CONFIG_H_
#define SRC_CONFIG_H_


typedef struct Config{
	alt_u8 test;
}Config;

void initializeConfig (void);



#endif /* SRC_CONFIG_H_ */

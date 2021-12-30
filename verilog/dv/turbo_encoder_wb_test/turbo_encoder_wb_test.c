/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include "verilog/dv/caravel/defs.h"
#include "verilog/dv/caravel/stub.c"

/*
	Wishbone Test:
		- Configures MPRJ lower 8-IO pins as outputs
		- Checks counter value through the wishbone port
*/

void main()
{

	/* 
	IO Control Registers
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 3-bits | 1-bit | 1-bit | 1-bit  | 1-bit  | 1-bit | 1-bit   | 1-bit   | 1-bit | 1-bit | 1-bit   |
	Output: 0000_0110_0000_1110  (0x1808) = GPIO_MODE_USER_STD_OUTPUT
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 110    | 0     | 0     | 0      | 0      | 0     | 0       | 1       | 0     | 0     | 0       |
	
	 
	Input: 0000_0001_0000_1111 (0x0402) = GPIO_MODE_USER_STD_INPUT_NOPULL
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 001    | 0     | 0     | 0      | 0      | 0     | 0       | 0       | 0     | 1     | 0       |
	*/

	/* Set up the housekeeping SPI to be connected internally so	*/
	/* that external pin changes don't affect it.			*/

	reg_spimaster_config = 0xa002;	// Enable, prescaler = 2,
                                        // connect to housekeeping SPI

	// Connect the housekeeping SPI to the SPI master
	// so that the CSB line is not left floating.  This allows
	// all of the GPIO pins to be used for user functions.

    reg_mprj_io_37 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_36 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_35 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_34 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_33 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_32 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_31 = GPIO_MODE_USER_STD_OUTPUT;

     /* Apply configuration */
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);

    reg_mprj_datah = 0x0000003F;

	reg_la1_oenb = reg_la1_iena = 0xFFFFFF80;    // [63:32]

    reg_la1_data = 0x00000000;

    // Flag start of the test

    /*for (int i = 0; i < 56; i++){
        reg_mprj_slave = input_data[i];
    }

    for (int i = 0; i < 56; i++){
        while (reg_mprj_slave == out_ref_data[i])
        reg_mprj_slave = input_data[i];
    }*/

    reg_mprj_slave = 0x0000c043;
    reg_mprj_slave = 0x0000c002;
    reg_mprj_slave = 0x0000c003;
    reg_mprj_slave = 0x0000c000;
    reg_mprj_slave = 0x0000c000;
    reg_mprj_slave = 0x0000c000;
    reg_mprj_slave = 0x0000c000;
    reg_mprj_slave = 0x0000c003;
    reg_mprj_slave = 0x0000c003;
    reg_mprj_slave = 0x0000c001;
    reg_mprj_slave = 0x0000c003;
    reg_mprj_slave = 0x0000c002;
    reg_mprj_slave = 0x0000c000;
    reg_mprj_slave = 0x0000c001;
    reg_mprj_slave = 0x0000c000;
    reg_mprj_slave = 0x0000c001;
    reg_mprj_slave = 0x0000c000;
    reg_mprj_slave = 0x0000c000;
    reg_mprj_slave = 0x0000c000;
    reg_mprj_slave = 0x0000c000;
    reg_mprj_slave = 0x0000c000;
    reg_mprj_slave = 0x0000c002;
    reg_mprj_slave = 0x0000c001;
    reg_mprj_slave = 0x0000c002;
    reg_mprj_slave = 0x0000c000;
    reg_mprj_slave = 0x0000c001;
    reg_mprj_slave = 0x0000c003;
    reg_mprj_slave = 0x0000c002;
    reg_mprj_slave = 0x0000c002;
    reg_mprj_slave = 0x0000c002;
    reg_mprj_slave = 0x0000c001;
    reg_mprj_slave = 0x0000c001;
    reg_mprj_slave = 0x0000c002;
    reg_mprj_slave = 0x0000c000;
    reg_mprj_slave = 0x0000c002;
    reg_mprj_slave = 0x0000c002;
    reg_mprj_slave = 0x0000c001;
    reg_mprj_slave = 0x0000c002;
    reg_mprj_slave = 0x0000c003;
    reg_mprj_slave = 0x0000c000;
    reg_mprj_slave = 0x0000c002;
    reg_mprj_slave = 0x0000c001;
    reg_mprj_slave = 0x0000c003;
    reg_mprj_slave = 0x0000c001;
    reg_mprj_slave = 0x0000c001;
    reg_mprj_slave = 0x0000c000;
    reg_mprj_slave = 0x0000c001;
    reg_mprj_slave = 0x0000c002;
    reg_mprj_slave = 0x0000c001;
    reg_mprj_slave = 0x0000c002;
    reg_mprj_slave = 0x0000c000;
    reg_mprj_slave = 0x0000c003;
    reg_mprj_slave = 0x0000c001;
    reg_mprj_slave = 0x0000c000;
    reg_mprj_slave = 0x0000c000;
    reg_mprj_slave = 0x0000c083;

    for (int i = 0; i < 8; i++);

    reg_mprj_slave = 0x00006000;

    while (reg_mprj_slave != 0x0000c070);
    while (reg_mprj_slave != 0x0000c022);
    while (reg_mprj_slave != 0x0000c038);
    while (reg_mprj_slave != 0x0000c004);
    while (reg_mprj_slave != 0x0000c007);
    while (reg_mprj_slave != 0x0000c001);
    while (reg_mprj_slave != 0x0000c00e);
    while (reg_mprj_slave != 0x0000c032);
    while (reg_mprj_slave != 0x0000c03b);
    while (reg_mprj_slave != 0x0000c01d);
    while (reg_mprj_slave != 0x0000c03f);
    while (reg_mprj_slave != 0x0000c020);
    while (reg_mprj_slave != 0x0000c00c);
    while (reg_mprj_slave != 0x0000c01b);
    while (reg_mprj_slave != 0x0000c00f);
    while (reg_mprj_slave != 0x0000c010);
    while (reg_mprj_slave != 0x0000c000);
    while (reg_mprj_slave != 0x0000c005);
    while (reg_mprj_slave != 0x0000c00c);
    while (reg_mprj_slave != 0x0000c00d);
    while (reg_mprj_slave != 0x0000c006);
    while (reg_mprj_slave != 0x0000c027);
    while (reg_mprj_slave != 0x0000c015);
    while (reg_mprj_slave != 0x0000c02e);
    while (reg_mprj_slave != 0x0000c002);
    while (reg_mprj_slave != 0x0000c01e);
    while (reg_mprj_slave != 0x0000c035);
    while (reg_mprj_slave != 0x0000c02d);
    while (reg_mprj_slave != 0x0000c028);
    while (reg_mprj_slave != 0x0000c029);
    while (reg_mprj_slave != 0x0000c017);
    while (reg_mprj_slave != 0x0000c01b);
    while (reg_mprj_slave != 0x0000c02f);
    while (reg_mprj_slave != 0x0000c004);
    while (reg_mprj_slave != 0x0000c022);
    while (reg_mprj_slave != 0x0000c028);
    while (reg_mprj_slave != 0x0000c01c);
    while (reg_mprj_slave != 0x0000c026);
    while (reg_mprj_slave != 0x0000c036);
    while (reg_mprj_slave != 0x0000c008);
    while (reg_mprj_slave != 0x0000c02d);
    while (reg_mprj_slave != 0x0000c01f);
    while (reg_mprj_slave != 0x0000c037);
    while (reg_mprj_slave != 0x0000c01e);
    while (reg_mprj_slave != 0x0000c017);
    while (reg_mprj_slave != 0x0000c009);
    while (reg_mprj_slave != 0x0000c01a);
    while (reg_mprj_slave != 0x0000c02c);
    while (reg_mprj_slave != 0x0000c019);
    while (reg_mprj_slave != 0x0000c026);
    while (reg_mprj_slave != 0x0000c009);
    while (reg_mprj_slave != 0x0000c036);
    while (reg_mprj_slave != 0x0000c015);
    while (reg_mprj_slave != 0x0000c005);
    while (reg_mprj_slave != 0x0000c004);
    while (reg_mprj_slave != 0x0000c0b2);

    reg_mprj_datah = 0x0000003E;
}

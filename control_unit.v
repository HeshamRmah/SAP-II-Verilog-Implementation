/*
 * Module: Control Unit (Controller)
 *
 * Brief : The controller-sequencer produces the control words or microinstructions that coordinate and direct the rest of the computer. 
 * Because SAP-2 has a bigger instruction set, the controller-sequencer has more hardware. 
 * Although the CON word is bigger, the idea is the same. 
 * the control word or microinstruction determines how the registers react to the next positive clock edge. 
 *
 * Input :
 * CLK    = Clock
 * nCLR   = Clear (0 :clear)
 * opcode = From Instruction Register
 *
 * Total Output of (28) Control Signals CON :
 * Cp     = Increment PC
 * Ep     = Enable PC ouput to WBUS (1 = Enable)
 * nLp    = Enable PC output to WBUS
 * CE     = Enabled the output & input to MDR (0 write, initially write data to Memory, 1 read, always Read address from MAR)
 * Em     = Enable MDR to write on WBUS
 * nLm    = Enable MDR to Load WBUS data   (0 = enable)
 * Er     = Enable MDR to write to Memory
 * nLr    = Enable MDR to Load Memory data (0 = enable)
 * nLi    = Load IR from WBUS (8-bit). 0 = load
 * nLa    = Load to Accumulator. (0 = Load)
 * Ea     = Enable Accumulator to Write to WBUS
 * nLt    = Load to Register TMP. (0 = Load)
 * Et     = Enable TMP Register to Write to WBUS
 * nLb    = Load to Register B. (0 = Load)
 * Eb     = Enable B Register to Write to WBUS
 * nLc    = Load to Register C. (0 = Load)
 * Ec     = Enable C Register to Write to WBUS
 * Lo3    = Load Data from WBUS into out port 3
 * Lo4    = Load Data from WBUS into out port 4
 * Sr     = shift register right to transfer data serially in out port 4
 * Sel3   = ALU Selector Bit 3
 * Sel2   = ALU Selector Bit 2
 * Sel1   = ALU Selector Bit 1
 * Sel0   = ALU Selector Bit 0
 * nLw    = Enable MAR to Load WBUS data (0 = enable)
 * Eu     = Enable ALU Output to WBUS
 * Ei1    = Enable Input Port 1 Output to WBUS
 * Ei2    = Enable Input Port 2 Output to WBUS
 */
module control_unit (
			output reg [27:0] CON, // All Control Signal in one Vector (Add any bits as Needed)
			input             CLK,
			input             nCLR,
			input      [7:0]  opcode );

	// T-States
	parameter T01 = 18'b000000_000000_000001;
	parameter T02 = 18'b000000_000000_000010;
	parameter T03 = 18'b000000_000000_000100;
	parameter T04 = 18'b000000_000000_001000;
	parameter T05 = 18'b000000_000000_010000;
	parameter T06 = 18'b000000_000000_100000;
	parameter T07 = 18'b000000_000001_000000;
	parameter T08 = 18'b000000_000010_000000;
	parameter T09 = 18'b000000_000100_000000;
	parameter T10 = 18'b000000_001000_000000;
	parameter T11 = 18'b000000_010000_000000;
	parameter T12 = 18'b000000_100000_000000;
	parameter T13 = 18'b000001_000000_000000;
	parameter T14 = 18'b000010_000000_000000;
	parameter T15 = 18'b000100_000000_000000;
	parameter T16 = 18'b001000_000000_000000;
	parameter T17 = 18'b010000_000000_000000;
	parameter T18 = 18'b100000_000000_000000;
	
	// Instruction OP_Code
	parameter ADD_B    = 8'b1000_0000;
	parameter ADD_C    = 8'b1000_0001;
	parameter ANA_B    = 8'b1010_0000;
	parameter ANA_C    = 8'b1010_0001;
	parameter ANI      = 8'b1110_0110;
	parameter CALL     = 8'b1100_1101;
	parameter CMA      = 8'b0010_1111;
	parameter DCR_A    = 8'b0011_1101;
	parameter DCR_B    = 8'b0000_0101;
	parameter DCR_C    = 8'b0000_1101;
	parameter HLT      = 8'b0111_0110;
	parameter IN       = 8'b1101_1011;
	parameter INR_A    = 8'b0011_1100;
	parameter INR_B    = 8'b0000_0100;
	parameter INR_C    = 8'b0000_1100;
	parameter JM       = 8'b1111_1010;
	parameter JMP      = 8'b1100_0011;
	parameter JNZ      = 8'b1100_0010;
	parameter JZ       = 8'b1100_1010;
	parameter LDA      = 8'b0011_1010;
	parameter MOV_A_B  = 8'b0111_1000;
	parameter MOV_A_C  = 8'b0111_1001;
	parameter MOV_B_A  = 8'b0100_0111;
	parameter MOV_B_C  = 8'b0100_0001;
	parameter MOV_C_A  = 8'b0100_1111;
	parameter MOV_C_B  = 8'b0100_1000;
	parameter MVI_A    = 8'b0011_1110;
	parameter MVI_B    = 8'b0000_0110;
	parameter MVI_C    = 8'b0000_1110;
	parameter NOP      = 8'b0000_0000;
	parameter ORA_B    = 8'b1011_0000;
	parameter ORA_C    = 8'b1011_0001;
	parameter ORI      = 8'b1111_0110;
	parameter OUT      = 8'b1101_0011;
	parameter RAL      = 8'b0001_0111;
	parameter RAR      = 8'b0001_1111;
	parameter RET      = 8'b1100_1001;
	parameter STA      = 8'b0011_0010;
	parameter SUB_B    = 8'b1001_0000;
	parameter SUB_C    = 8'b1001_0001;
	parameter XRA_B    = 8'b1010_1000;
	parameter XRA_C    = 8'b1010_1001;
	parameter XRI      = 8'b1110_1110;
	
	// Ring Counter
	reg nCLR_state;
	wire [17:0] state; 
	ring_counter RC (state,CLK,nCLR_state); 

	initial begin
		CON <= 0 ;
	end
	
	always @(state,opcode,nCLR) begin

	nCLR_state <= (state != T01)? nCLR_state : nCLR;

        if(!nCLR) begin
		// Reset all the Control Signal
		CON <= 28'h25D5008 ;
        end
		
        else begin
            		/*
			* One Way to Change the Control Signals (Suggested)
			* Depending on each Opcode (which has Number of T-state) we Change the Control Signals Vector (CON)
			* NOTE : in the Last T-state for every Opcode it's Obligated to Reset the Ring Counter to state : T01 ,
			* to start the Next Instruction without Halting the Program till the Ring Counter Complets it's Cycle
			*/
			nCLR_state <= 1'b1; // Remove the Clear Signal from Ring Counter

			case (state)
				T01: begin
					CON <= 28'h64D5000 ;
				end
					
				T02: begin
					CON <= 28'hAD55008 ;
				end

				default :

					case (opcode)
						ADD_B : case (state) // 1- ADD_B

								T03: begin
									CON <= 28'h25C7008 ;
								end
							
								T04: begin
									CON   <= 28'h259500C ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end

								default: CON <= 28'h25D5008 ;
						endcase
					
						ADD_C : case (state) // 2- ADD_C

								T03: begin
									CON <= 28'h25C5808 ;
								end
							
								T04: begin
									CON <= 28'h259500C ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						ANA_B : case (state) // 3- ANA_B
							
								T03: begin
									CON <= 28'h25C7008;
								end
							
								T04: begin
									CON <= 28'h259502C ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end

								default: CON <= 28'h25D5008 ;
							endcase
							
						ANA_C : case (state) // 4- ANA_C

								T03: begin
									CON <= 28'h25C5808;
								end
							
								T04: begin
									CON <= 28'h259502C ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
							
								default: CON <= 28'h25D5008 ;
							endcase
							
						ANI : case (state) // 5- ANI

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
								end
							
								T05: begin
									CON <= 0 ;
								end
							
								T06: begin
									CON <= 0 ;
								end
							
								T07: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
							
								default: CON <= 28'h25D5008 ;
							endcase
							
						CALL : case (state) // 6- CALL

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
								end
							
								T05: begin
									CON <= 0 ;
								end
							
								T06: begin
									CON <= 0 ;
								end
							
								T07: begin
									CON <= 0 ;
								end
							
								T08: begin
									CON <= 0 ;
								end
							
								T09: begin
									CON <= 0 ;
								end
							
								T10: begin
									CON <= 0 ;
								end
							
								T11: begin
									CON <= 0 ;
								end
							
								T12: begin
									CON <= 0 ;
								end
							
								T13: begin
									CON <= 0 ;
								end
							
								T14: begin
									CON <= 0 ;
								end
							
								T15: begin
									CON <= 0 ;
								end
							
								T16: begin
									CON <= 0 ;
								end
							
								T17: begin
									CON <= 0 ;
								end
							
								T18: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						CMA : case (state) // 7- CMA

								T03: begin
									CON <= 28'h25D5008;
								end
							
								T04: begin
									CON <= 28'h25950DC ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
							
								default: CON <= 28'h25D5008 ;
							endcase
							
						DCR_A : case (state) // 8- DCR_A

								T03: begin
									CON <= 28'h25E5008;
								end
							
								T04: begin
									CON <= 28'h259504C ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						DCR_B : case (state) // 9- DCR_B

								T03: begin
									CON <= 28'h25C7008 ;
								end
							
								T04: begin
									CON <= 28'h259504C ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						DCR_C : case (state) // 10- DCR_C

								T03: begin
									CON <= 28'h25C5808 ;
								end
							
								T04: begin
									CON <= 28'h259504C ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						HLT : case (state) // 11- HLT

								T03: begin
									CON <= 28'h25D5008 ;
								end
							
								T04: begin
									CON <= 28'h25D5008 ;
								end
							
								T05: begin
									CON <= 28'h25D5008 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						IN : case (state) // 12- IN

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
								end
							
								T05: begin
									CON <= 0 ;
								end
							
								T06: begin
									CON <= 0 ;
								end
							
								T07: begin
									CON <= 0 ;
								end
							
								T08: begin
									CON <= 0 ;
								end
							
								T09: begin
									CON <= 0 ;
								end
							
								T10: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						INR_A : case (state) // 13- INR_A

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						INR_B : case (state) // 14-INR_B

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						INR_C : case (state) // 15- INR_C

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						JM : case (state) // 16- JM

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
								end
							
								T05: begin
									CON <= 0 ;
								end
							
								T06: begin
									CON <= 0 ;
								end
							
								T07: begin
									CON <= 0 ;
								end
							
								T08: begin
									CON <= 0 ;
								end
							
								T09: begin
									CON <= 0 ;
								end
							
								T10: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
							
								default: CON <= 28'h25D5008 ;
							endcase
							
						JMP : case (state) // 17- JMP

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
								end
							
								T05: begin
									CON <= 0 ;
								end
							
								T06: begin
									CON <= 0 ;
								end
							
								T07: begin
									CON <= 0 ;
								end
							
								T08: begin
									CON <= 0 ;
								end
							
								T09: begin
									CON <= 0 ;
								end
							
								T10: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
							
								default: CON <= 28'h25D5008 ;
							endcase
							
						JNZ : case (state) // 18- JNZ

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
								end
							
								T05: begin
									CON <= 0 ;
								end
							
								T06: begin
									CON <= 0 ;
								end
							
								T07: begin
									CON <= 0 ;
								end
							
								T08: begin
									CON <= 0 ;
								end
							
								T09: begin
									CON <= 0 ;
								end
							
								T10: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
							
								default: CON <= 28'h25D5008 ;
							endcase
							
						JZ : case (state) // 19- JZ

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
								end
							
								T05: begin
									CON <= 0 ;
								end
							
								T06: begin
									CON <= 0 ;
								end
							
								T07: begin
									CON <= 0 ;
								end
							
								T08: begin
									CON <= 0 ;
								end
							
								T09: begin
									CON <= 0 ;
								end
							
								T10: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						LDA : case (state) // 20- LDA

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
								end
							
								T05: begin
									CON <= 0 ;
								end
							
								T06: begin
									CON <= 0 ;
								end
							
								T07: begin
									CON <= 0 ;
								end
							
								T08: begin
									CON <= 0 ;
								end
							
								T09: begin
									CON <= 0 ;
								end
							
								T10: begin
									CON <= 0 ;
								end
							
								T11: begin
									CON <= 0 ;
								end
							
								T12: begin
									CON <= 0 ;
								end
							
								T13: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								default: CON <= 28'h25D5008 ;
							endcase
							
						MOV_A_B : case (state) // 21- MOV_A_B

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
							
								default: CON <= 28'h25D5008 ;
							endcase
							
						MOV_A_C : case (state) // 22- MOV_A_C

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						MOV_B_A : case (state) // 23- MOV_B_A

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						MOV_B_C : case (state) // 24- MOV_B_C

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						MOV_C_A : case (state) // 25- MOV_C_A

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						MOV_C_B : case (state) // 26- MOV_C_B

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						MVI_A : case (state) // 27- MVI_A

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
								end
							
								T05: begin
									CON <= 0 ;
								end
							
								T06: begin
									CON <= 0 ;
								end
							
								T07: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end

								default: CON <= 28'h25D5008 ;
							endcase
							
						MVI_B : case (state) // 28- MVI_B

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
								end
							
								T05: begin
									CON <= 0 ;
								end
							
								T06: begin
									CON <= 0 ;
								end
							
								T07: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
							
								default: CON <= 28'h25D5008 ;
							endcase
							
						MVI_C : case (state) // 29- MVI_C

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
								end
							
								T05: begin
									CON <= 0 ;
								end
							
								T06: begin
									CON <= 0 ;
								end
							
								T07: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
							
								default: CON <= 28'h25D5008 ;
							endcase
							
						NOP : case (state) // 30- NOP

								T03: begin
									CON <= 28'h25D5008 ;
								end
							
								T04: begin
									CON <= 28'h25D5008 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
							
								default: CON <= 28'h25D5008 ;
							endcase
							
						ORA_B : case (state) // 31- ORA_B

								T03: begin
									CON <= 28'h25C7008 ;
								end
							
								T04: begin
									CON <= 28'h259503C ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
							
								default: CON <= 28'h25D5008 ;
							endcase
							
						ORA_C : case (state) // 32- ORA_C

								T03: begin
									CON <= 28'h25C5808 ;
								end
							
								T04: begin
									CON <= 28'h259503C ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
							
								default: CON <= 28'h25D5008 ;
							endcase
							
						ORI : case (state) // 33- ORI

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
								end
							
								T05: begin
									CON <= 0 ;
								end
							
								T06: begin
									CON <= 0 ;
								end
							
								T07: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						OUT : case (state) // 34- OUT

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
								end
							
								T05: begin
									CON <= 0 ;
								end
							
								T06: begin
									CON <= 0 ;
								end
							
								T07: begin
									CON <= 0 ;
								end
							
								T08: begin
									CON <= 0 ;
								end
							
								T09: begin
									CON <= 0 ;
								end
							
								T10: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						RAL : case (state) // 35- RAL

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						RAR : case (state) // 36- RAR

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						RET : case (state) // 37- RET

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
								end
							
								T05: begin
									CON <= 0 ;
								end
							
								T06: begin
									CON <= 0 ;
								end
							
								T07: begin
									CON <= 0 ;
								end
							
								T08: begin
									CON <= 0 ;
								end
							
								T09: begin
									CON <= 0 ;
								end
							
								T10: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						STA : case (state) // 38- STA

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
								end
							
								T05: begin
									CON <= 0 ;
								end
							
								T06: begin
									CON <= 0 ;
								end
							
								T07: begin
									CON <= 0 ;
								end
							
								T08: begin
									CON <= 0 ;
								end
							
								T09: begin
									CON <= 0 ;
								end
							
								T10: begin
									CON <= 0 ;
								end
							
								T11: begin
									CON <= 0 ;
								end
							
								T12: begin
									CON <= 0 ;
								end
							
								T13: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						SUB_B : case (state) // 39- SUB_B

								T03: begin
									CON <= 28'h25C7008 ;
								end
							
								T04: begin
									CON <= 28'h259501C ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						SUB_C : case (state) // 40- SUB_C

								T03: begin
									CON <= 28'h25C5808 ;
								end
							
								T04: begin
									CON <= 28'h259501C;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						XRA_B : case (state) // 41- XRA_B

								T03: begin
									CON <= 28'h25C7008 ;
								end
							
								T04: begin
									CON <= 28'h259506C ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
							
						XRA_C : case (state) // 42- XRA_C

								T03: begin
									CON <= 28'h25C5808 ;
								end
							
								T04: begin
									CON <= 28'h259506C ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h259506C ;
							endcase
							
						XRI : case (state) // 43- XRI

								T03: begin
									CON <= 0 ;
								end
							
								T04: begin
									CON <= 0 ;
								end
							
								T05: begin
									CON <= 0 ;
								end
							
								T06: begin
									CON <= 0 ;
								end
							
								T07: begin
									CON <= 0 ;
									nCLR_state <= 1'b0;  // Reset The Ring Counter
								end
								
								default: CON <= 28'h25D5008 ;
							endcase
				
				
						default: CON <= 28'h25D5008 ;
					endcase
			endcase
			
        end
    end
endmodule
/***************************************************************************/
module t_control_unit ;

	wire [11:0] CON;					
	reg  [7:0]  opcode;
	reg         CLK,nCLR;

	control_unit Control_Unit (CON,CLK,nCLR,opcode);

	initial begin 
		CLK = 0 ;
		forever #50 CLK = ~CLK ;
	end

	initial begin 
			
			// Write your Test Cases here :
			
			
	end

endmodule
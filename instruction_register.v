/**
* Module: Instruction Registor (IR)
*
* Brief : Because SAP-2 has more instructions than SAP-1, we will use 8 bits for the op code rather than 4. 
* An 8-bit op code can accommodate 256 instructions. SAP-2 has only 42 instructions, so there will be no problem coding them with 8 bits.
* Using an 8-bit op code also allows upward compat-ibility with the 8080/8085 instruction set because it is based on an 8-bit op code. 
* As mentioned earlier, all SAP instructions are identical with 8080/8085 instructions. 
*
* Input :
* WBUS   = Data from WBUS
* CLK    = Clock
* nLi    = Load IR from WBUS (8-bit). 0 = load
* nCLR   = Clear
*
* Output :
* opcode = Op Code to Determine the Operation
*/
module instruction_register (
				output [7:0] opcode,
				input  [7:0] WBUS,
				input        CLK,
				input        nLi,
				input        nCLR );

	parameter Zero_State     = 8'b0000_0000;

	reg [7:0] OpReg ;

	initial begin
		OpReg <= Zero_State;
	end
    
	assign opcode = OpReg ;
	
	always @(posedge CLK) begin

		if(!nCLR) begin
			OpReg <= Zero_State;
		end

		else begin

			if(!nLi) begin
				// Load the data
				OpReg <= WBUS;
			end

			else begin
				// DO Nothing
				OpReg <= OpReg;
			end
		end
	end
	
endmodule
/*************************************** Test Bench ***************************************/
module t_instruction_register ;

	wire [7:0] opcode;
	reg  [7:0] WBUS;
	reg        CLK;
	reg        nLi,nCLR ;

	instruction_register IR (opcode,WBUS,CLK,nLi,nCLR);

	initial begin 
		CLK = 1 ;
		forever #50 CLK = ~CLK ;
	end

	initial begin 
		
		     nCLR = 0 ; nLi = 1 ; WBUS = 8'hca;  // Clear (Reset)
		#100 nCLR = 1 ; nLi = 0 ; WBUS = 8'hca;  // Load From WBUS
		#100 nCLR = 1 ; nLi = 1 ; WBUS = 8'he9;  // Do Nothing
		#100 nCLR = 1 ; nLi = 0 ; WBUS = 8'hfe;  // Load From WBUS
		#100 nCLR = 1 ; nLi = 0 ; WBUS = 8'h87;  // Load From WBUS
		#100 nCLR = 1 ; nLi = 1 ; WBUS = 8'hfe;  // Do Nothing
		#100 nCLR = 1 ; nLi = 0 ; WBUS = 8'h99;  // Load From WBUS
		#100 nCLR = 1 ; nLi = 0 ; WBUS = 8'h8e;  // Load From WBUS
		#100 nCLR = 0 ; nLi = 0 ; WBUS = 8'h8e;  // Clear (Reset)
		#100 nCLR = 1 ; nLi = 1 ; WBUS = 8'h57;  // Do Nothing
		#100 nCLR = 1 ; nLi = 0 ; WBUS = 8'h67;  // Load From WBUS

	end

endmodule

/*
* Module: Accumulator
*
* Brief : The Accumulator (A) is a buffer register that stores inter-mediate answers during a computer run.
* The two-state output of the accumulator goes to the ALU ,the three-state output to the W bus.
* Therefore, the 8-bit word in the accumulator continuously drives the ALU, but this same word appears on the bus only when EA is active. 
*
* Input :
* WBUS   = Data from WBUS
* CLK    = Clock
* nLa    = Load Register A at negedge (Write). 0 -> Write
* Ea     = Write to WBUS.
*
* Output :
* WBUS   = Data To the WBUS
* alu    = Data to ALU
*/
module accumulator(
			inout  [7:0] WBUS,
			output [7:0] alu,
			input        CLK,
			input        nLa,
			input        Ea );

	parameter High_Impedance = 8'bzzzz_zzzz;
	parameter Zero_State     = 8'b0000_0000;
	
	reg  [7:0] accreg;
    
	initial begin
		accreg <= Zero_State;
	end	
	
	assign WBUS = (Ea)? accreg : High_Impedance ;  // if Enabe == 1 -> Out to WBUS

	assign alu  = accreg ;

	always @(negedge CLK ) begin
	
		if(!nLa) accreg <= WBUS ;   // Load Data to Register
		
		else     accreg <= accreg ; // Do Nothing
		
	end
	
endmodule
/*************************************** Test Bench ***************************************/
module t_accumulator ;

	wire [7:0] WBUS;
	wire [7:0] alu;
	reg        CLK;
	reg        nLa,Ea ;
	reg  [7:0] in ;

	accumulator Accumulator (WBUS,alu,CLK,nLa,Ea);

	assign WBUS = (!nLa)? in : 8'bzzzz_zzzz ;

	initial begin 
		CLK = 1 ;
		forever #50 CLK = ~CLK ;
	end

	initial begin 
	
		      nLa = 1;  Ea = 0;  in = 8'b0000_0000;  // Clear (Reset)
		#100  nLa = 0;  Ea = 0;  in = 8'b0000_1010;  // Load with (10)
		#100  nLa = 1;  Ea = 0;                      // WBUS High_Impedance
		#100  nLa = 0;  Ea = 0;  in = 8'b0010_0000;  // Load with (32)
		#100  nLa = 1;  Ea = 1;                      // Out Data to WBUS

	end

endmodule

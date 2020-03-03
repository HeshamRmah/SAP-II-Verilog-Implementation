/**
* Module: MAR
*
* Brief : During the fetch cycle, the MAR receives 16-bit addresses from the program counter. 
* The two-state MAR output then addresses the desired memory location. 
*
* Input :
* WBUS    = the Data from the WBUS.
* nLw     = Enable MAR to Load WBUS data (0 = enable)
* CLK     = Clock
*
* Output :
* address = Address to the RAM
*/
module mar (
		output reg [15:0] address,
		input      [15:0] WBUS,
		input             nLw ,
		input             CLK );		
	
	parameter Zero_State     = 8'b0000_0000;

	reg [15:0] addr ;

	initial begin
		address <= Zero_State;
	end
	
	always @(negedge CLK) begin 
	
		if(!nLw)	address <= WBUS;
		
		else		address <= address;
	end	
	
endmodule
/*************************************** Test Bench ***************************************/
module t_mar;

	wire [15:0] address;
	reg  [15:0] WBUS;
	reg         CLK;
	reg         nLw;

	mar MAR (address,WBUS,nLw,CLK);

	initial begin 
		CLK = 1 ;
		forever #50 CLK = ~CLK ;
	end

	initial begin 
		nLw = 1;  WBUS = 16'h1234;
	#100	nLw = 0;  WBUS = 16'h1234;
	#100	nLw = 0;  WBUS = 16'h1111;	
	#100	nLw = 1;  WBUS = 16'h1234;	
		
	end

endmodule

/**
* Module: Memory Data Register (MDR)
* haven't complete test bench yet
*
* Brief : The memory data register (MDR) is an 8-bit buffer register , Its output sets up the RAM. 
* The memory data register receives data from the bus before a write operation, and it sends data to the bus after a read operation. 
*
* Input :
* WBUS = Data from WBUS.
* data = data from Memory
* nLw  = Enable MDR to Load WBUS data 	(0 = enable)
* nLr  = Enable MDR to Load Memory data (0 = enable)
* Em   = Enable MDR to write on WBUS
* CLK  = Clock
*
* Output :
* WBUS = data to WBUS
* data = data to Memory
*/
module mdr (
		inout [7:0] WBUS,
		inout [7:0] data,
		input       nLw ,
		input	    nLr,
		input	    Em,
		input       CLK );		
	
	reg [7:0] mdrreg ;
	
	parameter Zero_State     = 8'b0000_0000;
	parameter High_Impedance = 8'bzzzz_zzzz;
	
	assign WBUS = Em? mdrreg : High_Impedance;
	assign data = mdrreg;
	
	initial begin	mdrreg <= Zero_State;	end
    
	always @(posedge CLK) begin

		if      (!nLw)	mdrreg <= WBUS;

		else if (!nLr)	mdrreg <= data;

		else            mdrreg <= mdrreg;
	end
	
endmodule
/*************************************** Test Bench ***************************************/
module t_mdr;

	wire [7:0] WBUS;
	wire [7:0] data;
	reg         CLK;
	reg         nLw;
	reg	    nLr;
	reg         Em;
	
	reg [7:0] temp_WBUS;
	reg [7:0] temp_data;

	parameter Zero_State     = 8'b0000_0000;
	parameter High_Impedance = 8'bzzzz_zzzz;
	
	assign WBUS = temp_WBUS;
	assign data = temp_data;
	
	mdr MDR (WBUS,data,nLw,nLr,Em,CLK);	
	
	initial begin 
		CLK = 1 ;
		forever #50 CLK = ~CLK ;
	end

	initial begin 
		nLw = 1;	nLr = 1;	Em = 0;		temp_WBUS = 8'h15;	temp_data = 8'h17;	//do nothing	
	#100	nLw = 0;	nLr = 1;	Em = 0;		temp_WBUS = 8'h25;	temp_data = 8'h27;	//load from WBUS
	#100	nLw = 1;	nLr = 0;	Em = 0;		temp_WBUS = 8'h35;	temp_data = 8'h37;	//load form Memory
	#100	nLw = 1;	nLr = 1;	Em = 1;		temp_WBUS = 8'h45;	temp_data = 8'h47;	//write on WBUS

	
	end

endmodule

/**
* Module: Memory Data Register (MDR)
*
* Brief : The memory data register (MDR) is an 8-bit buffer register , Its output sets up the RAM. 
* The memory data register receives data from the bus before a write operation, and it sends data to the bus after a read operation. 
*
* Input :
* WBUS = Data from WBUS.
* data = data from Memory
* Em   = Enable MDR to write on WBUS
* nLm  = Enable MDR to Load WBUS data 	(0 = enable)
* Er   = Enable MDR to write to Memory
* nLr  = Enable MDR to Load Memory data (0 = enable)
* CLK  = Clock
*
* Output :
* WBUS = data to WBUS
* data = data to Memory
*/
module mdr (
		inout [7:0] WBUS,
		inout [7:0] data,
		input	    Em,
		input       nLm ,
		input	    Er,
		input	    nLr,
		input       CLK );		
	
	reg [7:0] mdrreg ;
	//reg [7:0] datareg ;
	
	parameter Zero_State     = 8'b0000_0000;
	parameter High_Impedance = 8'bzzzz_zzzz;
	
	assign WBUS = (Em) ? mdrreg  : High_Impedance;
	assign data = (Er) ? mdrreg  : High_Impedance;
	
	initial begin	
		mdrreg  <= Zero_State;
		//datareg <= Zero_State;
	end
    
	always @(posedge CLK) begin

		if (!nLr) begin 
			mdrreg  <= data;
			//datareg <= data;
		end
		else if (!nLm) begin
			mdrreg  <= WBUS;
			//datareg <= datareg;
		end
		else begin            
			mdrreg  <= mdrreg;
			//datareg <= datareg;
		end
	end
	
endmodule
/*************************************** Test Bench ***************************************/
module t_mdr;

	wire [7:0] WBUS;
	wire [7:0] data;
	reg        CLK;
	reg        Em;
	reg        nLm;
	reg        Er;
	reg        nLr;
	
	reg [7:0] temp_WBUS;
	reg [7:0] temp_data;

	parameter Zero_State     = 8'b0000_0000;
	parameter High_Impedance = 8'bzzzz_zzzz;
	
	assign WBUS = (!nLm) ? temp_WBUS : WBUS;
	assign data = (!nLr) ? temp_data : data;
	
	mdr MDR (WBUS,data,Em,nLm,Er,nLr,CLK);	
	
	initial begin 
		CLK = 1 ;
		forever #50 CLK = ~CLK ;
	end

	initial begin 
	
		Em = 0;  nLm = 1;  Er = 0;  nLr = 1;  temp_WBUS = 8'h00;  temp_data = 8'h00;	// Do Nothing	
	#100	Em = 0;  nLm = 0;  Er = 0;  nLr = 1;  temp_WBUS = 8'h25;  temp_data = 8'h27;	// Load from WBUS
	#100	Em = 0;  nLm = 1;  Er = 0;  nLr = 0;  temp_WBUS = 8'h35;  temp_data = 8'h57;	// Load form Memory
	#100	Em = 1;  nLm = 1;  Er = 0;  nLr = 1;  temp_WBUS = 8'h28;  temp_data = 8'h97;	// Write on WBUS
	#100	Em = 0;  nLm = 1;  Er = 0;  nLr = 0;  temp_WBUS = 8'h35;  temp_data = 8'h37;	// Load form Memory
	#100	Em = 0;  nLm = 0;  Er = 0;  nLr = 1;  temp_WBUS = 8'hEC;  temp_data = 8'hA5;	// Load from WBUS
	#100	Em = 0;	 nLm = 1;  Er = 1;  nLr = 1;  temp_WBUS = 8'h45;  temp_data = 8'h47;	// Write to Memory

	end

endmodule

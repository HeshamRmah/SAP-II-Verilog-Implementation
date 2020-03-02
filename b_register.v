/*
* Module: B Register
*
* Brief : The B register is another buffer register.
* It is used in holding the data. A low LB and positive clock edge load the word on the W bus into the B register.
*
* Input :
* WBUS   = Data from WBUS 
* CLK    = Clock
* nLb    = Load to Register B. (0 = Load)
* Eb     = Enable B Register to Write to WBUS
*
* Output :
* WBUS    = Data to WBUS
*/
module b_register (
					inout  [7:0] WBUS,
					input        CLK,
					input        nLb,
					input        Eb  );

	parameter High_Impedance = 8'bzzzz_zzzz;
	parameter Zero_State     = 8'b0000_0000;
	
	reg [7:0] breg;
  
	initial begin
		breg <= Zero_State;
	end
	
	// nLb : for Load to B Register
	// Eb  : Enable to out to WBUS
	
	assign WBUS = (Eb)? breg : High_Impedance;  // if Enabe == 1 -> Out to WBUS

	always @(posedge CLK ) begin
	
		if(!nLb) breg <= WBUS ;   // Load Data to Register
		
		else     breg <= breg ;   // Do Nothing
		
	end
	
endmodule
/*************************************** Test Bench ***************************************/
module t_b_register ;

	wire [7:0] WBUS;
	reg        CLK,nLb,Eb;
	reg  [7:0] in ;

	b_register B_Register (WBUS,CLK,nLb,Eb);
	
	assign WBUS = (!nLb)? in : 8'bzzzz_zzzz ;

	initial begin 
		CLK = 1 ;
		forever #50 CLK = ~CLK ;
	end

	initial begin 
		
		      nLb = 1;  Eb = 0;  in = 8'b0000_0000;  // Clear (Reset)
		#100  nLb = 0;  Eb = 0;  in = 8'b0000_1010;  // Load with (10)
		#100  nLb = 1;  Eb = 0;                      // WBUS High_Impedance
		#100  nLb = 0;  Eb = 0;  in = 8'b0010_0000;  // Load with (32)
		#100  nLb = 1;  Eb = 1;                      // Out Data to WBUS
	end

endmodule
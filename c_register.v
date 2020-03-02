/*
* Module: C Register
*
* Brief : The C register is another buffer register.
* It is used in holding the data. A low LC and positive clock edge load the word on the W bus into the C register.
*
* Input :
* WBUS   = Data from WBUS 
* CLK    = Clock
* nLc    = Load to Register C. (0 = Load)
* Ec     = Enable C Register to Write to WBUS
*
* Output :
* WBUS    = Data to WBUS
*/
module c_register (
			inout  [7:0] WBUS,
			input        CLK,
			input        nLc,
			input        Ec  );

	parameter High_Impedance = 8'bzzzz_zzzz;
	parameter Zero_State     = 8'b0000_0000;
	
    	reg [7:0] creg;
  
    	initial begin
     	   creg <= Zero_State;
    	end
	
	assign WBUS = (Ec)? creg : High_Impedance;  // if Enabe == 1 -> Out to WBUS

	always @(posedge CLK ) begin
	
		if(!nLc) creg <= WBUS ;   // Load Data to Register
		
		else     creg <= creg ;   // Do Nothing
	end

endmodule
/*************************************** Test Bench ***************************************/
module t_c_register ;

	wire [7:0] WBUS;
	reg        CLK;
	reg        nLc;
	reg        Ec;
	reg  [7:0] in ;

	c_register C_Register (WBUS,CLK,nLc,Ec);
	
	assign WBUS = (!nLc)? in : 8'bzzzz_zzzz ;

	initial begin 
		CLK = 1 ;
		forever #50 CLK = ~CLK ;
	end

	initial begin 
		
		      nLc = 1;  Ec = 0;  in = 8'b0000_0000;  // Clear (Reset)
		#100  nLc = 0;  Ec = 0;  in = 8'b0000_1010;  // Load with (10)
		#100  nLc = 1;  Ec = 0;                      // WBUS High_Impedance
		#100  nLc = 0;  Ec = 0;  in = 8'b0010_0000;  // Load with (32)
		#100  nLc = 1;  Ec = 1;                      // Out Data to WBUS
		
	end

endmodule

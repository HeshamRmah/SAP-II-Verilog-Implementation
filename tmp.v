/*
* Module: TMP Register
*
* Brief : 
*
* Input :
* WBUS   = Data from WBUS 
* CLK    = Clock
* nLt    = Load to Register TMP. (0 = Load)
* Et     = Enable TMP Register to Write to WBUS
*
* Output :
* alu     = data to ALU Unit 
* WBUS    = Data to WBUS
*/
module tmp_register (
			inout  [7:0] WBUS,
			output [7:0] alu,
			input        CLK,
			input        nLt,
			input        Et  );

	parameter High_Impedance = 8'bzzzz_zzzz;
	parameter Zero_State     = 8'b0000_0000;
	
	reg [7:0] tmpreg;
  
	initial begin
        	tmpreg <= Zero_State;
    	end
	
	assign WBUS = (Et)? tmpreg : High_Impedance;  // if Enabe == 1 -> Out to WBUS
	assign alu = tmpreg ;

	always @(posedge CLK ) begin
	
		if(!nLt) tmpreg <= WBUS ;     // Load Data to Register
		
		else     tmpreg <= tmpreg ;   // Do Nothing
		
	end
	
endmodule
/*************************************** Test Bench ***************************************/
module t_tmp_register ;

	wire [7:0] WBUS;
	wire [7:0] alu;
	reg        CLK,nLt,Et;
	reg  [7:0] in ;

	tmp_register TMP_Register (WBUS,alu,CLK,nLt,Et);
	
	assign WBUS = (!nLt)? in : 8'bzzzz_zzzz ;

	initial begin 
		CLK = 0 ;
		forever #50 CLK = ~CLK ;
	end

	initial begin 
		
		      nLt = 1;  Et = 0;  in = 8'b0000_0000;  // Clear (Reset)
		#100  nLt = 0;  Et = 0;  in = 8'b0000_1010;  // Load with (10)
		#100  nLt = 1;  Et = 0;                      // WBUS High_Impedance
		#100  nLt = 0;  Et = 0;  in = 8'b0010_0000;  // Load with (32)
		#100  nLt = 1;  Et = 1;                      // Out Data to WBUS
		
	end

endmodule

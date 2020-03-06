/*
* Module: Input Port 1
*
* Brief : SAP-2 has a hexadecimal keyboard encoder is connected to port 1. 
* It allows us to enter hexadecimal instructions and data through port 1. 
* Notice that the hexadecimal keyboard encoder sends a READY signal to bit 0 of port 2. 
* This signal indicates when the data in port 1 is valid. 
* Also notice the SERIAL IN signal going to pin 7 of port 2. 
*
* Input :
* Keyboard   = Data fron Hexadecimal Keyboard Encoder
* Ei1        = Enable Input Port 1 Output to WBUS
* acknowedge = acknowedge Signal
* CLK        = Clock
* nCLR       = Clear (0 :clear)
*
* Output :
* WBUS    = Data to WBUS
* ready   = Send Ready Signal to Input Port 2
*/
module input_port_1 (
			output [7:0] WBUS,
			output reg   ready,
			input  [7:0] Keyboard,
			input        Ei1,acknowedge,CLK,nCLR  );

	parameter High_Impedance = 8'bzzzz_zzzz;
	parameter Zero_State     = 8'b0000_0000;
	
	reg [7:0] data;         // Register to hold the Current data
  
	initial begin
		data <= Zero_State;
	end
	
	assign WBUS = (Ei1)? data : High_Impedance; //data_to_bus_with_enable
	
	always@(posedge CLK) begin
	
		data <= Keyboard;			        // store_input_from_keyboard_into_data_register
	
		if(~nCLR)           data  <= 0;     // clear_condition
	
		else if(acknowedge) ready <= 1'b1;  // readybit_enable
	
		else begin                          // general
			data  = data;
			ready <= 1'b0;
		end           
	
	end

endmodule
/*************************************** Test Bench ***************************************/
module t_input_port_1 ;

	wire [7:0] WBUS;
	wire       ready;
	reg  [7:0] Keyboard;
	reg        Ei1,acknowedge,CLK,nCLR;

	input_port_1 Input_Port_1 (WBUS,ready,Keyboard,Ei1,acknowedge,CLK,nCLR);
	
	initial begin CLK =1; forever #50 CLK=~CLK; end 

	initial begin 
		
	     nCLR = 0; acknowedge = 0;  Ei1 = 0;  Keyboard = 8'hac;
	#100 nCLR = 1; acknowedge = 1;  Ei1 = 0;  Keyboard = 8'hac; 
	#100 nCLR = 1; acknowedge = 0;  Ei1 = 1;  Keyboard = 8'hab; 
	#100 nCLR = 1; acknowedge = 0;  Ei1 = 1;  Keyboard = 8'had; 
		
	end

endmodule
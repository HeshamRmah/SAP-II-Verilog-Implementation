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
* acknowedge = acknowedge Signal
*
* Output :
* WBUS    = Data to WBUS
* ready   = Send Ready Signal to Input Port 2
*/
module input_port_1 (
					output [7:0] WBUS,
					output       ready,
					input  [7:0] Keyboard,
					input        acknowedge );

	parameter High_Impedance = 8'bzzzz_zzzz;
	parameter Zero_State     = 8'b0000_0000;
	
    reg [7:0] data;
  
    initial begin
        data <= Zero_State;
    end
	
	// Write your Code here :
	
	
	
	
	
	
	
	
	
	
endmodule
/*************************************** Test Bench ***************************************/
module t_input_port_1 ;

	wire [7:0] WBUS;
	wire       ready;
	reg  [7:0] Keyboard;
	reg        acknowedge;

	input_port_1 Input_Port_1 (WBUS,ready,Keyboard,acknowedge );

	initial begin 
		
		// Write your Test Cases here :
		
	end

endmodule
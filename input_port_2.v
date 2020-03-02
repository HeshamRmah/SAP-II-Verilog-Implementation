/*
* Module: Input Port 2
*
* Brief : 
*
* Input :
* ready     = Received Ready Signal from Input Port 1
* serial_in = input Data in Serial form
* CLK       = Clock
* nCLR      = Clear (0 :clear)
*
* Output :
* WBUS    = Data to WBUS
*/
module input_port_2 (
			output [7:0] WBUS,
			input        ready,
			input        serial_in,CLK,nCLR );

	parameter High_Impedance = 8'bzzzz_zzzz;
	parameter Zero_State     = 8'b0000_0000;
	
	reg [7:0] data;
  
	initial begin
		data <= Zero_State;
	end
	
	assign WBUS = (ready)? data : High_Impedance;
	
	always @(posedge CLK) begin
		
		data[0] <= ready;

		if(!nCLR) data = Zero_State;  
		
		else if(ready) begin 
			data[7] = serial_in; 
			data    = data >> 1; 
		end
		
		else data = data;
		
	end

endmodule
/*************************************** Test Bench ***************************************/
module t_input_port_2 ;

	wire [7:0] WBUS;
	reg        ready;
	reg        serial_in,CLK,nCLR;

	input_port_2 Input_Port_2 (WBUS,ready,serial_in,CLK,nCLR);
	
	initial begin CLK=1; forever #50 CLK=~CLK; end 

	initial begin 
		
	     nCLR = 0; ready = 0; serial_in = 1'b0;
	#100 nCLR = 1; ready = 1; serial_in = 1'b1;
	#100 nCLR = 1; ready = 1; serial_in = 1'b1;
	#100 nCLR = 1; ready = 1; serial_in = 1'b0;	
	#100 nCLR = 1; ready = 1; serial_in = 1'b1;
	#100 nCLR = 1; ready = 0; serial_in = 1'b0;
		
	end

endmodule

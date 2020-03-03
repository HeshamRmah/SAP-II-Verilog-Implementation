/*
* Module: Input Port 2
*
* Brief : 
*
* Input :
* ready     = Received Ready Signal from Input Port 1
* Ei2        = Enable Input Port 2 Output to WBUS
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
			input        Ei2,serial_in,CLK,nCLR );

	parameter High_Impedance = 8'bzzzz_zzzz;
	parameter Zero_State     = 8'b0000_0000;
	
	reg [7:0] data;
  
	initial begin
		data <= Zero_State;
	end
	
	assign WBUS = (Ei2)? data : High_Impedance;  //data_to_bus_with_enable
	
	always @(posedge CLK) begin
		
		data[0] <= ready;            // store_input_from_ready_into_data_register

		if(!nCLR) data = Zero_State; // clear_condition
		
		else if(ready) begin         // load_data_and_shift
			data[7] = serial_in; 
			data    = data >> 1; 
		end
		
		else data = data;            // general
		
	end

endmodule
/*************************************** Test Bench ***************************************/
module t_input_port_2 ;

	wire [7:0] WBUS;
	reg        ready;
	reg        Ei2,serial_in,CLK,nCLR;

	input_port_2 Input_Port_2 (WBUS,ready,Ei2,serial_in,CLK,nCLR);
	
	initial begin CLK=1; forever #50 CLK=~CLK; end 

	initial begin 
		
	     nCLR = 0; ready = 0; Ei2 = 0; serial_in = 1'b0;
	#100 nCLR = 1; ready = 1; Ei2 = 1; serial_in = 1'b1;
	#100 nCLR = 1; ready = 1; Ei2 = 1; serial_in = 1'b1;
	#100 nCLR = 1; ready = 1; Ei2 = 1; serial_in = 1'b0;	
	#100 nCLR = 1; ready = 1; Ei2 = 1; serial_in = 1'b1;
	#100 nCLR = 1; ready = 0; Ei2 = 1; serial_in = 1'b0;
		
	end

endmodule

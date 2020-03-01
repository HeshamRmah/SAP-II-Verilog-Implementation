/*
* Module: out_port_4
*
* Brief : The contents of the accumulator can also be sent to port 4. 
* Notice that pin 7 of port 4 sends an ACKNOWLEDGE signal to the hexadecimal encoder. 
* This ACKNOWLEDGE signal and the READY signal are part of a concept called handshaking. 
* Also notice the SERIAL OUT signal from pin 0 of port 4. 
*
* Input :
* WBUS = Data from WBUS
* Lo4  = load from WBUS
* Sr = shift register right to transfer data serially
*
* Output :
* serial_out = Data out in serial form
* acknowedge = acknowedge Signal
*/
module out_port_4 (
					output      serial_out,
					output      acknowedge,
					input [7:0] WBUS, 
					input       CLK,
					input       Lo4,
					input       Sr);
					
	reg [7:0] register4;
	
	assign serial_out = register4[0];
	assign acknowedge = register4[7];
	
	always @(posedge CLK) begin

		if     (Lo4)	 register4 <= WBUS;
		else if(Sr) register4 <= (register4>>1);
		else 		 register4 <= register4;
	end
	
endmodule
/*************************************** Test Bench ***************************************/
module t_out_port_4 ;
	
	wire serial_out, acknowedge;
	reg [7:0] WBUS; 
	reg CLK, Lo4, Sr;
	
	out_port_4 out (serial_out,acknowedge,WBUS,CLK,Lo4,Sr);
	
	initial begin 
		CLK = 1 ;
		forever #50 CLK = ~CLK ;
	end
	
	initial begin 

		Lo4 = 0;  Sr = 0;	WBUS = 8'h15;
	#100	Lo4 = 1;  Sr = 0;	WBUS = 8'h25;
	#100	Lo4 = 1;  Sr = 1;	WBUS = 8'h35;
	#100	Lo4 = 0;  Sr = 1;	WBUS = 8'h45;
	#100	Lo4 = 0;  Sr = 0;	WBUS = 8'h55;
	#100	Lo4 = 0;  Sr = 0;	WBUS = 8'h65;
	#100	Lo4 = 0;  Sr = 0;	WBUS = 8'h75;
	#100	Lo4 = 1;  Sr = 0;	WBUS = 8'h85;
		
	end

endmodule

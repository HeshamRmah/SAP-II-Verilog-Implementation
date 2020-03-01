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
* shift_r = shift register right to transfer data serially
*
* Output :
* serial_out = Data out in serial form
* acknowedge = acknowedge Signal
*/
module out_port_4 (
					output serial_out,
					output acknowedge,
					input [7:0] WBUS, 
					input CLK,
					input Lo4,
					input shift_r);
					
	reg [7:0] register4;
	
	assign serial_out = register4[0];
	assign acknowedge = register4[7];
	
	always @(posedge CLK) begin
		if(Lo4)			register4 <= WBUS;
		else if(shift_r)	register4 <= (register4>>1);
		else 			register4 <= register4;
	end
	
endmodule
/*************************************** Test Bench ***************************************/
module t_out_port_4 ;
	
	wire serial_out, acknowedge;
	reg [7:0] WBUS; 
	reg CLK, Lo4, shift_r;
	
	out_port_4 out(serial_out,acknowedge,WBUS,CLK,Lo4,shift_r);
	
	initial begin 
		CLK = 0 ;
		forever #50 CLK = ~CLK ;
	end
	
	initial begin 
			Lo4 = 0;	shift_r = 0;	WBUS = 8'h15;
	#100	Lo4 = 1;	shift_r = 0;	WBUS = 8'h25;
	#100	Lo4 = 1;	shift_r = 1;	WBUS = 8'h35;
	#100	Lo4 = 0;	shift_r = 1;	WBUS = 8'h45;
	#100	Lo4 = 0;	shift_r = 0;	WBUS = 8'h55;
	#100	Lo4 = 0;	shift_r = 0;	WBUS = 8'h65;
	#100	Lo4 = 0;	shift_r = 0;	WBUS = 8'h75;
	#100	Lo4 = 1;	shift_r = 0;	WBUS = 8'h85;
		
		
		
	end

endmodule

/*
* Module: out_port_3
*
* Brief : The contents of the accumulator can be loaded into port 3, which drives a hexadecimal display. 
* This allows us to see the processed data.
*
* Input :
* WBUS   = Data from WBUS 
* Lo3	 = load data from bus
* CLK    = clock signal
*
* Output :
* out    = Data to Hexadecimal Display
*/
module out_port_3 (
			output reg [7:0] out,
			input      [7:0] WBUS,
			input            CLK,
			input            Lo3 );

	always @(posedge CLK) begin

		if (Lo3)  out <= WBUS;

		else	  out <= out;
	
	end
	
endmodule
/*************************************** Test Bench ***************************************/
module t_out_port_3 ;

	wire [7:0] out;
	reg  [7:0] WBUS ;
	reg        CLK;
	reg        Lo3;

	out_port_3 out_3(out,WBUS,CLK,Lo3 );

	initial begin 
		CLK = 1 ;
		forever #50 CLK = ~CLK ;
	end

	initial begin 

		Lo3 = 0;  WBUS = 8'h15;
	#100	Lo3 = 1;  WBUS = 8'h25;
	#100	Lo3 = 1;  WBUS = 8'h35;
	#100	Lo3 = 1;  WBUS = 8'h45;
		
	end

endmodule

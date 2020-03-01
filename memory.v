/**
* Module: 64K Memory 
*
* Brief : The memory has a 2K ROM with addresses of 0000H to 07FFH. 
* This ROM contains a program called a monitor that initializes the computer on power-up, interprets the keyboard inputs, and so forth. 
* The rest of the memory is a 62K RAM with addresses from 0800H to FFFFH. 
*
* Input :
* data : data from MDR
* address = address of memory location to read or write
* nCE     = Enabled the output & input to MDR (0 write, 1 read, always Read address from MAR)
* CLK	  = clock signal
*
* Output : Data to MDR
* data = Address to the RAM
*/
module memory (
		inout  [07:0] data,
		input  [15:0] address,
		input         nCE, 
		input 	      CLK );		
	
	parameter Zero_State     = 8'b0000_0000;
	parameter High_Impedance = 8'bzzzz_zzzz;
	parameter memory_size    = 65536;	

	reg [7:0] memory [0:memory_size]; // 8-bits x 64K Memory Location

	assign data = (nCE) ? memory[address] : High_Impedance;

	integer i;
	initial begin
		for (i = 0; i<memory_size; i=i+1)
			memory[i] <= i;
	end
	
	always @(posedge CLK) begin

		if(!nCE) memory[address] <= data;
	end

endmodule
/***************************************************************************/
module t_memory;

	wire [07:0] data;
	reg  [15:0] address;
	reg         nCE;
	parameter High_Impedance = 8'bzzzz_zzzz;

	reg [07:0]in; 

	assign data = (!nCE)? in : High_Impedance;

	memory Memory (data,address,nCE);	
	
	initial begin
		nCE = 1'b1;	address = 16'h0000;	
	#100	nCE = 1'b1;	address = 16'h0001;	
	#100	nCE = 1'b1;	address = 16'h0002;
	#100	nCE = 1'b0;	address = 16'h0003;	in = 8'h20;
	#100	nCE = 1'b0;	address = 16'h0004;	in = 8'h30;

	end

endmodule

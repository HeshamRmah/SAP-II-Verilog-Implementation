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
* CE      = Enabled the output & input to MDR (0 write, initially write data to Memory, 1 read, always Read address from MAR)
* CLK	  = clock signal
*
* Output : Data to MDR
* data    = Address to the RAM
*/
module memory (
		inout  [07:0] data,
		input  [15:0] address,
		input         CE, 
		input 	      CLK );		
	
	parameter Zero_State     = 8'b0000_0000;
	parameter High_Impedance = 8'bzzzz_zzzz;
	parameter memory_size    = 65536;	

	reg [7:0] memory [0:memory_size]; // 8-bits x 64K Memory Location

	assign data = (!CE) ? memory[address] : High_Impedance;

	integer i;
	initial begin
		for (i = 5; i <= memory_size; i=i+1)
			memory[i] <= i;
		
		memory[0] <= 8'b1000_0000;
		memory[1] <= 8'b1001_0001;
		memory[2] <= 8'b1001_0000;
		memory[3] <= 8'b1010_1000;
		memory[4] <= 8'b1010_1001;
	end
	
	always @(posedge CLK) begin

		if(CE) memory[address] <= data;
	end

endmodule
/***************************************************************************/
module t_memory;

	wire [07:0] data;
	reg  [15:0] address;
	reg         CE,CLK;

	parameter High_Impedance = 8'bzzzz_zzzz;

	reg [07:0] in; 

	assign data = (CE)? in : High_Impedance;

	memory Memory (data,address,CE,CLK);	

	initial begin 
		CLK = 1 ;
		forever #50 CLK = ~CLK ;
	end
	
	initial begin
		CE = 1'b0;	address = 16'h0000;	
	#100	CE = 1'b0;	address = 16'h0001;	
	#100	CE = 1'b0;	address = 16'h0002;
	#100	CE = 1'b1;	address = 16'h0003;	in = 8'h20;
	#100	CE = 1'b1;	address = 16'h0004;	in = 8'h30;

	end

endmodule

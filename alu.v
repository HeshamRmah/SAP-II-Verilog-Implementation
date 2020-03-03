/*
* Module: 8-bit ALU & 2-bit Flags
*
* Brief : ALUs have 4 or more control bits that determine the arithmetic or logic operation performed on words A and B. 
* The ALU used in SAP-2 includes arithmetic and logic operations. 
* a flag is a flip-flop that keeps track of a changing condition during a computer run. 
* The SAP-2 computer has two flags. The sign flag is set when the accumulator contents become negative during the execution 
*
* Input :
* accumulator  = data From Accumulator
* tmp          = data From Register TMP.
* Sel          = Operation Selector 
* Eu           = Enable output to WBUS
*
* Output :
* WBUS   = Data to WBUS.
* flags  = zero & sign Flags  (flags[0] = Zero Flag )(flags[1] = Sign Flag)
* sel [3] -> 1 if the operation does not affect the flags
*/
module alu (
		output [7:0]  WBUS,
		output [1:0]  flags,
		input  [7:0]  accumulator,
		input  [7:0]  tmp,
		input  [3:0]  Sel,
		input         Eu );

	parameter High_Impedance = 8'bzzzz_zzzz;
	parameter Zero_State     = 8'b0000_0000;
	
	parameter ADD  = 4'b0000;
	parameter SUB  = 4'b0001;
	parameter AND  = 4'b0010;
	parameter OR   = 4'b0011;
	parameter DCR  = 4'b0100;
	parameter INC  = 4'b0101;
	parameter XOR  = 4'b0110;
	parameter CMA  = 4'b1101;
	parameter RAL  = 4'b1110;
	parameter RAR  = 4'b1111;
			
	reg [7:0] result ; // register for the result 

	initial begin
		result <= Zero_State;
	end

	assign flags[0] = Sel[3]? flags[0] : ((result == 0)? 1 : 0 );    // Zero Flag 
	assign flags[1] = Sel[3]? flags[1] : ((result[7]== 1)? 1 : 0) ;  // Sign Flag 

	assign WBUS = (Eu) ? result : High_Impedance ;     // DATA tO WBUS IF ENABLE 

	always @(*)
		case(Sel)
		
			ADD : result  <= accumulator + tmp ;                // add x  , x is b , c 
			SUB : result  <= accumulator - tmp ;                // sub x 
			AND : result  <= accumulator & tmp ;                // and x , ani
			OR  : result  <= accumulator | tmp ;                // or x ,  ori 
			DCR : result  <= tmp - 1 ;                          // dcr x , 
			INC : result  <= tmp + 1 ;                          // inc x , 
			XOR : result  <= accumulator ^ tmp ;                // xor x ,  xori 
			CMA : result  <= ~ accumulator ;                    // Complement A 
			RAL : result  <= {accumulator[6:0],accumulator[7]}; // ral 
			RAR : result  <= {accumulator[0],accumulator[7:1]}; // rar
		
		endcase

endmodule
/*************************************** Test Bench ***************************************/
module t_alu ;

	wire [7:0]  WBUS;
	wire [1:0]  flags;
	reg  [7:0]  accumulator;
	reg  [7:0]  tmp;
	reg  [3:0]  Sel;
	reg         Eu;
	
	parameter ADD  = 4'b0000;
	parameter SUB  = 4'b0001;
	parameter AND  = 4'b0010;
	parameter OR   = 4'b0011;
	parameter DCR  = 4'b0100;
	parameter INC  = 4'b0101;
	parameter XOR  = 4'b0110;
	parameter RAL  = 4'b1110;
	parameter RAR  = 4'b1111;

	alu ALU (WBUS,flags,accumulator,tmp,Sel,Eu);

	initial begin 

		      Eu = 0 ; Sel = ADD ; accumulator = 5  ; tmp = 5 ;    // result = High due to eu = 0
		#100  Eu = 1 ; Sel = ADD ; accumulator = 5  ; tmp = 5 ;    // result = 5 + 5 = 10
		#100  Eu = 0 ; Sel = SUB ; accumulator = 7  ; tmp = 5 ;    // result = High due to eu = 0
		#100  Eu = 1 ; Sel = SUB ; accumulator = 10 ; tmp = 5 ;    // result = 10 -5  = 5
		#100  Eu = 1 ; Sel = SUB ; accumulator = 2  ; tmp = 5 ;    // result = 2 -5  = -3   sign flag = 1 
		#100  Eu = 1 ; Sel = AND ; accumulator = 2  ; tmp = 5 ;    // result = 2 & 5 = 0    zero flag = 1 
		#100  Eu = 1 ; Sel = OR  ; accumulator = 2  ; tmp = 5 ;    // 2 | 5 = 7
		#100  Eu = 1 ; Sel = RAR ; accumulator = 10 ; tmp = 5 ;    // rar 00001010 -> 00000101
		#100  Eu = 1 ; Sel = DCR ; accumulator = 2  ; tmp = 5 ;    // result = tmp - 1 
		#100  Eu = 1 ; Sel = XOR ; accumulator = 15 ; tmp = 5 ;    // 15 ^ 5 = 10

	end

endmodule
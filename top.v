/*
* Project       : Implementation of SAP 2
* Author's Name : Hesham Mohamed Adb El-Hamed Ali
* Date          : 26/2/2020
* File Name     : CPU Top
*
* Inputs of the Module :
* Keyboard  = Input from Keyboard
* CLK       = Clock
* nCLR      = Clear (0 :clear)
* serial_in = Input Data in Serial Form
*
* Output of the Module :
* P3_out     = Output Data from Port 4
* serial_out = Output Data in Serial Form
*/
module top (output [7:0] P3_out,output serial_out,input [7:0] Keyboard,input CLK ,nCLR,serial_in);
	
/****************************************************************************************/	
	// (28) Control Signals 
	wire Cp,Ep,nLp,CE,Em,nLm,Er,nLr,nLi,nLa,Ea,nLt,Et,nLb,Eb,nLc,Ec,Lo3,Lo4,Sr,Sel3,Sel2,Sel1,Sel0,nLw,Eu,Ei1,Ei2 ;
	// Accumulator Module
	wire  [7:0] acc_BUS,acc_alu;
	// ALU Module
	wire [7:0]  alu_BUS;
	wire [1:0]  alu_flags;
	// B Register Module
	wire [7:0] Breg_BUS;
	// C Register Module
	wire [7:0] Creg_BUS;
	// Control Unit Module
	wire [27:0] CON;
	// input Port 1 Module
	wire [7:0] P1_BUS;
	wire       ready;
	// input Port 2 Module
	wire [7:0] P2_BUS;
	// Instruction Register Module
	wire [7:0] opcode;
	// MAR Module
	wire [15:0] mar_address;
	// MDR Module
	wire [7:0]  mdr_BUS;
	// Memory Module
	
	// Output Port 4 Module
	wire       acknowedge;
	// Program Counter Module
	wire [15:0] pc_BUS;
	// TMP Register Module
	wire [7:0] tmp_BUS,tmp_alu;
	// Connection Between Memory and MDR
	wire [7:0] mem_mdr;
/************************************************************************/	
	parameter Zero_State     = 8'b0000_0000;
	parameter High_Impedance = 8'bzzzz_zzzz;
	// WBUS Register
	reg  [15:0] WBUS; 
	initial begin
		WBUS <= Zero_State;
	end
/***************************************************************************/
	always @(*) begin
	
		// assign the WBUS Register Depending on Control Signals
		WBUS = (Ep)  ? pc_BUS   : WBUS ;
		WBUS = (Ea)  ? acc_BUS  : WBUS [7:0];
		WBUS = (Em)  ? mdr_BUS  : WBUS [7:0];
		WBUS = (Et)  ? tmp_BUS  : WBUS [7:0];
		WBUS = (Eb)  ? Breg_BUS : WBUS [7:0];
		WBUS = (Ec)  ? Creg_BUS : WBUS [7:0];
		WBUS = (Eu)  ? alu_BUS  : WBUS [7:0];
		WBUS = (Ei1) ? P1_BUS   : WBUS [7:0];
		WBUS = (Ei2) ? P2_BUS   : WBUS [7:0];
		
	end
	
	// Assign each Module input to WBUS when Loading is Selected
	assign pc_BUS   = (!nLp)? WBUS       : {High_Impedance,High_Impedance} ;
	assign acc_BUS  = (!nLa)? WBUS [7:0] : High_Impedance ;
	assign mdr_BUS  = (!nLm)? WBUS [7:0] : High_Impedance ;
	assign tmp_BUS  = (!nLt)? WBUS [7:0] : High_Impedance ;
	assign Breg_BUS = (!nLb)? WBUS [7:0] : High_Impedance ;
	assign Creg_BUS = (!nLc)? WBUS [7:0] : High_Impedance ;

	// Assign all (28) Control Signals to CON Vector
	assign {Cp,Ep,nLp,CE,Em,nLm,Er,nLr,nLi,nLa,Ea,nLt,Et,nLb,Eb,nLc,Ec,Lo3,Lo4,Sr,Sel3,Sel2,Sel1,Sel0,nLw,Eu,Ei1,Ei2} = CON[27:0] ;
	
/*********************************************************************************/
	// Connect all the Modules

	accumulator Accumulator (acc_BUS,acc_alu,CLK,nLa,Ea );
	
	alu ALU (alu_BUS,alu_flags,acc_alu,tmp_alu,{Sel3,Sel2,Sel1,Sel0},Eu );

	b_register B_Register (Breg_BUS,CLK,nLb,Eb );
	
	c_register C_Register (Creg_BUS,CLK,nLc,Ec );

	control_unit Controller (CON,CLK,nCLR,opcode );

	input_port_1 Input_Port_1 (P1_BUS,ready,Keyboard,Ei1,acknowedge,CLK,nCLR );

	input_port_2 Input_Port_2 (P2_BUS,ready,Ei1,serial_in,CLK,nCLR );

	instruction_register IR (opcode,WBUS[7:0],CLK,nLi,nCLR );
	
	mar MAR (mar_address,WBUS,nLw,CLK );

	mdr MDR (mdr_BUS,mem_mdr,Em,nLm,Er,nLr,CLK );

	memory Memory (mem_mdr,mar_address,CE,CLK );

	out_port_3 Out_Port_3 (P3_out,WBUS[7:0],CLK,Lo3 );

	out_port_4 Out_Port_4 (serial_out,acknowedge,WBUS[7:0],CLK,Lo4,Sr);

	program_counter PC (pc_BUS,Cp,Ep,nLp,CLK,nCLR);

	tmp_register TMP (tmp_BUS,tmp_alu,CLK,nLt,Et);
	
endmodule
/***************************************************************************/
module t_top;

	wire [7:0] P3_out;
	wire serial_out;
	reg [7:0] Keyboard;
	reg CLK ,nCLR ,serial_in ;

	top SAP_II (P3_out,serial_out,Keyboard,CLK,nCLR,serial_in);

	initial begin 
		CLK = 1 ;
		forever #50 CLK = ~CLK ;
	end

	initial begin 

		     nCLR = 0 ;
		#100 nCLR = 1 ;

	end

endmodule

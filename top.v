/*
* Project       : Implementation of SAP 2
* Author's Name : Hesham Mohamed Adb El-Hamed Ali
* Date          : 26/2/2020
* File Name     : CPU Top
*
* Inputs of the Module :
* CLK   = Clock
* nCLR  = Clear (0 :clear)
*/
module top (input CLK ,nCLR,serial_in,Keyboard);
	
/****************************************************************************************/	
	wire Cp,Ep,nLp,nCE,Em,nLm,Er,nLr,nLi,nLa,Ea,nLt,Et,nLb,Eb,nLc,Ec,Lo3,Lo4,Sr,Sel3,Sel2,Sel1,Sel0,nLw,Eu ;

	wire  [7:0] acc_BUS,acc_alu;
	
	wire [7:0]  alu_BUS;
	wire [1:0]  alu_flags;
	
	wire [7:0] Breg_BUS;
	
	wire [7:0] Creg_BUS;
	
	wire [27:0] CON;
	
	wire [7:0] P1_BUS;
	wire       ready;
	
	wire [7:0] P2_BUS;
	
	wire [7:0] opcode;
	
	wire [15:0] mar_address;
	
	wire [7:0] mdr_BUS,mdr_data;
	
	wire [7:0] mem_data;
	
	wire [7:0] P3_out;
	
	wire       serial_out,acknowedge;
	
	wire [15:0] pc_BUS;
	
	wire  [7:0] tmp_BUS,tmp_alu;
/************************************************************************/	
	parameter Zero_State = 8'b0000_0000;
	
	reg  [15:0] WBUS;
	
	initial begin
		WBUS <= Zero_State;
	end
/***************************************************************************/
	always @(*) begin
	
		// assign the WBUS Register Depending on Control Signals
		WBUS = (Ep)  ? pc_BUS   : WBUS ;
		WBUS = (Ea)  ? acc_BUS  : WBUS ;
		WBUS = (Em)  ? mdr_BUS  : WBUS ;
		WBUS = (Et)  ? tmp_BUS  : WBUS ;
		WBUS = (Eb)  ? Breg_BUS : WBUS ;
		WBUS = (Ec)  ? Creg_BUS : WBUS ;
		WBUS = (Eu)  ? alu_BUS  : WBUS ;
		WBUS = (Lo3) ? P1_BUS   : WBUS ;
		WBUS = (Lo4) ? P2_BUS   : WBUS ;
		
	end
	
	assign {Cp,Ep,nLp,nCE,Em,nLm,Er,nLr,nLi,nLa,Ea,nLt,Et,nLb,Eb,nLc,Ec,Lo3,Lo4,Sr,Sel3,Sel2,Sel1,Sel0,nLw,Eu} = CON[27:2] ;
	
/*********************************************************************************/
	accumulator Accumulator (acc_BUS,acc_alu,CLK,nLa,Ea );
	
	alu ALU (alu_BUS,alu_flags,acc_alu,tmp_alu,{Sel3,Sel2,Sel1,Sel0},Eu );

	b_register B_Register (Breg_BUS,CLK,nLb,Eb );
	
	c_register C_Register (Creg_BUS,CLK,nLc,Ec );

	control_unit Controller (CON,CLK,nCLR,opcode );

	input_port_1 Input_Port_1 (P1_BUS,ready,Keyboard,acknowedge );

	input_port_2 Input_Port_2 (P2_BUS,ready,serial_in );

	instruction_register IR (opcode,WBUS,CLK,nLi,nCLR );
	
	mar MAR (mar_address,WBUS,nLw,CLK );

	mdr MDR (mdr_BUS,mdr_data,Em,nLm,Er,nLr,CLK );

	memory Memory (mem_data,mar_address,nCE,CLK );

	out_port_3 Out_Port_3 (P3_out,WBUS,CLK,Lo3 );

	out_port_4 Out_Port_4 (serial_out,acknowedge,WBUS,CLK,Lo4,Sr);

	program_counter PC (pc_BUS,Cp,Ep,nLp,CLK,nCLR);

	tmp_register TMP (tmp_BUS,tmp_alu,CLK,nLt,Et);
	
endmodule
/***************************************************************************/
module t_top;

	reg CLK ,nCLR ,serial_in ,Keyboard;

	top SAP_II (CLK,nCLR,serial_in,Keyboard);

	initial begin 
		CLK = 1 ;
		forever #50 CLK = ~CLK ;
	end

	initial begin 

			 nCLR = 0 ;
		#100 nCLR = 1 ;

	end

endmodule

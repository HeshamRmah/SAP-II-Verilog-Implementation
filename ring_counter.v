/*
* Ring counter
* Generates the T-States for the Control Unit (Controller)
*
* Author's Name : Hesham Mohamed Adb El-Hamed Ali
*
* Input :
* CLK   = Clock
* nCLR  = Clear (0 :clear)
*
* Output :
* stste = T-States for the Control Unit
*/
module ring_counter (
			output reg [17:0] state,
			input             CLK,
			input             nCLR );

	// T-States
    	parameter T01    = 18'b000000_000000_000001;
    	parameter T02    = 18'b000000_000000_000010;
    	parameter T03    = 18'b000000_000000_000100;
    	parameter T04    = 18'b000000_000000_001000;
	parameter T05    = 18'b000000_000000_010000;
	parameter T06    = 18'b000000_000000_100000;
	parameter T07    = 18'b000000_000001_000000;
	parameter T08    = 18'b000000_000010_000000;
	parameter T09    = 18'b000000_000100_000000;
	parameter T10    = 18'b000000_001000_000000;
	parameter T11    = 18'b000000_010000_000000;
	parameter T12    = 18'b000000_100000_000000;
	parameter T13    = 18'b000001_000000_000000;
	parameter T14    = 18'b000010_000000_000000;
	parameter T15    = 18'b000100_000000_000000;
	parameter T16    = 18'b001000_000000_000000;
	parameter T17    = 18'b010000_000000_000000;
	parameter T18    = 18'b100000_000000_000000;

    initial begin
        state <= T01;
    end
    
    always @(posedge CLK) begin
	
        if(!nCLR) begin
		state <= T01;
	end

        else
            case(state)
			
                T01:      state <= T02;
                T02:      state <= T03;
                T03:      state <= T04;
                T04:      state <= T05;
                T05:      state <= T06;
		T06:      state <= T07;
                T07:      state <= T08;
                T08:      state <= T09;
                T09:      state <= T10;
                T10:      state <= T11;
		T11:      state <= T12;
                T12:      state <= T13;
                T13:      state <= T14;
                T14:      state <= T15;
                T15:      state <= T16;
		T16:      state <= T17;
                T17:      state <= T18;
				
                default: state <= T01;
				
            endcase
    end
endmodule

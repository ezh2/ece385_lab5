
// 6:40 
//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Given Code - Incomplete ISDU for SLC-3
// Module Name:    Control - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//    Revised 07-25-2023
//    Xilinx Vivado
//	  Revised 12-29-2023
// 	  Spring 2024 Distribution
// 	  Revised 6-22-2024
//	  Summer 2024 Distribution
//	  Revised 9-27-2024
//	  Fall 2024 Distribution
//------------------------------------------------------------------------------
// this is diff
//1001 Eric: Not Done Yet
module control (
	input logic			clk, 
	input logic			reset,

	input logic  [15:0]	ir,//@@ instructions register content 
	input logic			ben,// Branch enable not for week1

	input logic 		continue_i, 
	input logic 		run_i,

	//control signals
	output logic		ld_mar, //@@signal to load memory addres register
	output logic		ld_mdr, //@@signal to load memory data register
	output logic		ld_ir,  //@@signal to load instruction register
	output logic		ld_pc,  //@@ update the program counter
	output logic        ld_led, //@@ used in the pause states
						
	output logic		gate_pc, // when high the data bus takes the pc currect value
	output logic		gate_mdr, //when high puts the data register value on data bus
	output logic		gate_mar, //when high puts the address register value on data bus 
	output logic		gate_alu, //when high puts the alu output on data bus 
	output logic		addr1_mux, //@@ either pc or base register for alu input 1 
	output logic [1:0]	addr2_mux, //@@ either 0, sign extended off6, sign extended off9 for alu input 2 
	output logic		sr1mux, //@@ either base register or pc for alu input 
	output logic		sr2mux, //@@ either sign extended off5 or second source register for alu input 
	output logic		drmux, //@@ either destination register or r7 for alu output to be

	//pc 00 = pc+1, pc 01= the bus, pc 10 address from address adder 11 =0	 this 11 shouldnt be reached
	output logic [1:0]	pcmux, // @@either incremented pc(state num 00)? or data bus address???, 
	
	//You should add additional control signals according to the SLC-3 datapath design

	output logic		mem_mem_ena, // Mem Operation Enable
	output logic		mem_wr_ena,  // Mem Write Enable
	output logic [4:0]  state_out,

	output logic ld_cc,	//enable saving cc/nzp
	output logic [1:0] aluk, //chose the operation for ALU
	output logic ld_reg, // lets the register file load
	output logic ld_ben  // lets BEN save


);
// i think gates are choicess for what drives the data bus input  and load will chose which reg saves that drived input at that clock edge 
	enum logic [4:0] {
		halted, //halting state
		pause_ir1, //wait untill u press continue
		pause_ir2, //wait untill u realease continue
		s_18,      //@@MAR <- PC
		s_33_1,	   //@@MDR <- M(MAR) 
		s_33_2,	// @@this will take multiple clock cycles so that's why it's extended
		s_33_3, //@@same commment for s_33_2 
		s_35, // @@IR <-MDR  then  PC <- PC+1 then Go to halt (in the case of week 1) week 2 u decode

		//@@just added 
		s_32,
		s_22, 
		s_12, 
		s_4,
        s_21,
        s_7,
        s_23,
        s_16_1,
		s_16_2,
		s_16_3,
        s_6,
        s_25_1,
		s_25_2,
		s_25_3,
        s_27,
        s_9,
        s_5,
        s_1,
		s_0
		
	} state, state_nxt;   // Internal state logic

    assign state_out = state;
	always_ff @ (posedge clk)
	begin
		if (reset) 
			state <= halted;
		else 
			state <= state_nxt;
	end
   
	always_comb
	begin 
		
		// Default controls signal values so we don't have to set each signal
		// in each state case below (If we don't set all signals in each state,
		// we can create an inferred latch)
		ld_mar = 1'b0;
		ld_mdr = 1'b0;
		ld_ir = 1'b0;
		ld_pc = 1'b0;
		ld_led = 1'b0;
		
		gate_pc = 1'b0;
		gate_mdr = 1'b0;
		gate_mar = 1'b0;
		gate_alu = 1'b0;
		
		 
		pcmux = 2'b00;// deffault and means pc+1

		mem_mem_ena = 1'b0;
		mem_wr_ena  = 1'b0;	
		//@%$$$$$$$$$$$$$$ pls dont forget to give defult val for any new signal u put 
		ld_cc = 1'b0;
		
		aluk = 2'b00;
		addr1_mux = 1'b0;
		addr2_mux = 2'b00;
		sr1mux = 1'b0;
		sr2mux = 1'b0;
		drmux = 1'b0;

		ld_reg = 1'b0;
		ld_ben = 1'b0;
		
	
		// Assign relevant control signals based on current state
		case (state)
			halted: ;  // @@ takes the defult values
			s_18 : //s_18 = @@MAR <- PC
				begin 
					gate_pc = 1'b1; //@@ put current PC on BUS
					ld_mar = 1'b1; //@@ mar <- pc
					pcmux = 2'b00; // @@10 state is pc+1
					ld_pc = 1'b1;  // @@pc saves pc+1
					//so like if pc was 3 at that time(edge) mar stays 3 and pc gets 4
				end
			s_33_1, s_33_2, s_33_3 : //you may have to think about this as well to adapt to ram with wait-states
				begin  // @@ s_33 = MDR <- M(MAR) 
					mem_mem_ena = 1'b1; //@@Mem Operation Enable, what does thsi tell us?
					ld_mdr = 1'b1;
				end
			s_35 : 
				begin // @@ s_35 = IR <-MDR  then the pc already incremented in s_18 for some reason
					gate_mdr = 1'b1; // @@ put mdr value on the bus
					ld_ir = 1'b1;    //@obv ir saves that instruction
				end
			pause_ir1: ld_led = 1'b1; // wait untill u press continue
			pause_ir2: ld_led = 1'b1; //wait untill u realease continue , from discord  + i dont get this fully 
			// you need to finish the rest of state output logic..... 
			//@@@@@@@ TO DO 

			s_32 : //decode
				begin
					//benis  calculated and saved in cpu
					ld_ben = 1'b1; //@@ set the ben register to the value of the branch condition
				end
			s_22 : // PC <- PC +off9
				begin
					
					//pc 00 = pc+1, pc 01= the bus, pc 10 address from address adder 11 =0
					pcmux = 2'b10; //@@ select the address from address adderthe new PC value
					ld_pc = 1'b1; //@@ load the new PC value
					addr1_mux = 1'b1; //@@ select the PC as the first operand for the ALU
					addr2_mux = 2'b01; //@@ select the sign extended off9 as the second operand for the ALU
				end
			s_12 : // JMP   PC <- BaseR
				begin
					pcmux = 2'b10; //@@ select address from address adder as the new PC value
					ld_pc = 1'b1; //@@ load the new PC value
					sr1mux = 1'b1; //@@ select the base register as the first operand for the ALU
					addr2_mux = 2'b11; //@@ select 0 as the second operand
					addr1_mux = 1'b0; //@@ select the base register as the first operand for the ALU
				end
			s_4 : // JSR   R7 <- PC
				begin
					gate_pc = 1'b1; //@@ put current PC on BUS
					ld_reg = 1'b1; //@@ load the register with the alu output
					drmux = 1'b1; //@@ select R7 as the destination register
				end
			s_21 : // PC <- PC+ off11
				begin
					pcmux = 2'b10; //@@ select the address from address adder as the new PC value
					ld_pc = 1'b1; //@@ load the new PC value
					addr1_mux = 1'b1; //@@ select PC as the first operand for the ALU
					addr2_mux = 2'b00; //@@ select 11 as the second operand for the ALU
				end
			s_7 : // STR MAR<- B+off6
				begin
					addr1_mux = 1'b0;	// @@ select BaseR
					addr2_mux = 2'b10;	// @@ select SEXT[offset6]
					sr1mux = 1'b1;  	// @@ select ir[8:6]
					ld_mar = 1'b1;	// @@ load MAR with the ALU output	
					gate_mar = 1'b1;	// @@ put MAR on the bus
				end
			s_23 : // MDR <- SR 
				begin
					aluk = 2'b11;
					ld_mdr = 1'b1;		// @@load MDR with the data read from memory
					sr1mux = 1'b0;  	// @@ select ir[11:9] as the first operand for the ALU
					gate_alu = 1'b1;	// @@put ALU output on the bus
				end
			s_16_1, s_16_2, s_16_3 : //M[MAR] <- MDR
				begin
					mem_mem_ena = 1'b1;	// @@ enable memory write
					mem_wr_ena = 1'b1;	// @@ enable memory write
					
				end
			s_6 : //LDR
				begin
					addr1_mux = 1'b0;	// @@ select
					addr2_mux = 2'b10;	// @@ select sext off6
					sr1mux = 1'b1;  	// @@ select ir[8:6] as the first operand for the ALU
					ld_mar = 1'b1;	// @@ load the MAR with the ALU output
					gate_mar = 1'b1;	// @@ put MAR on the bus
				end
			s_25_1, s_25_2, s_25_3 : //MDR <- M[MAR]
				begin
					mem_mem_ena = 1'b1;	// @@ enable memory write
					mem_wr_ena = 1'b0;	// @@ disable memory write
					ld_mdr = 1'b1;		// @@load MDR with the data read from memory
				end
			s_27 : // DR <- MDR set CC
				begin
				gate_mdr = 1'b1; // put mdr  VAL on the bus
				ld_reg = 1'b1;   // save BUS into DR
				drmux = 1'b0;    // destination is ir[11:9]
				ld_cc = 1'b1;	
				end
			s_9 : // NOT   DR <- NOT(SR) set CC
				begin
					aluk = 2'b10;
					gate_alu = 1'b1;	// @@put ALU output on the bus
					ld_reg = 1'b1;		// @@load the register with the ALU output
					sr1mux = 1'b1;  	// @@select ir[8:6]
					drmux = 1'b0;   	// @@select ir[11:9]
					ld_cc = 1'b1;		// @@load cc
				end
			s_5 : // AND   DR <- SR1 & OP2* set CC
				begin
					aluk = 2'b01;
					gate_alu = 1'b1;	// @@put ALU output on the bus
					ld_reg = 1'b1;		// @@load the register with the ALU output
					sr1mux = 1'b1;  	// @@select ir[8:6] as the first operand for the ALU
					sr2mux = ir[5];  	// @@select the second operand for the ALU based on the ir[5] bit @@ there may be an issue here (DEBUG CHECK)
					drmux = 1'b0;   	// @@select ir[11:9]
					ld_cc = 1'b1;		// @@load cc

				end
			s_1 : // ADD   DR <- SR1+OP2* set CC
				begin
					aluk = 2'b00; //@@ select addition operation for the ALU
					gate_alu = 1'b1; //@@ put the alu output on the bus
					ld_reg = 1'b1; //@@ load the pc with the alu output
					sr1mux = 1'b1; //@@ select the pc as the first operand for the alu
					sr2mux = ir[5]; //@@ select the sign extended off9 as the second operand for the alu @@ there may be an issue here (DEBUG CHECK)
					drmux = 1'b0; //@@ slect ir [11:9]
					ld_cc = 1'b1; //@@ set CC
				end
			default : ;
		endcase
	end 

	always_comb
	begin
		// default next state is staying at current state
		state_nxt = state;

		unique case (state)
			halted : 
				if (run_i) //@@if run then start fetching
					state_nxt = s_18;
			s_18 : 
				state_nxt = s_33_1; //notice that we usually have 'r' here, but you will need to add extra states instead  //@@refers to the original memory ready signal
			s_33_1 :                 //e.g. s_33_2, etc. how many? as a hint, note that the bram is synchronous, in addition, 
				state_nxt = s_33_2;   //it has an additional output register. 
			s_33_2 :
				state_nxt = s_33_3;
			s_33_3 : 
				state_nxt = s_35;
			s_35 : 
				state_nxt = s_32;
			s_32 :
				if (ir[15:12]==4'b0000)
					state_nxt =s_0;
				else if (ir[15:12]==4'b1100)
					state_nxt = s_12; //JMP
				else if (ir[15:12]==4'b0100)
					state_nxt = s_4; // JSR
				else if (ir[15:12]==4'b0111)
					state_nxt = s_7; // STR
				else if (ir[15:12]==4'b0110)
					state_nxt = s_6; //LDR
				else if (ir[15:12]==4'b1001)
					state_nxt = s_9; //NOT
				else if (ir[15:12]==4'b0101)
					state_nxt = s_5; //AND
				else if (ir[15:12]==4'b0001)
					state_nxt = s_1; //ADD
				else if (ir[15:12]==4'b1101)
					state_nxt = pause_ir1; //pause
				else//shouldnt be reached but wtv
					state_nxt = s_18; //go back to fetch if something is weird
			s_1 :
				state_nxt = s_18; 
			s_12 :
				state_nxt = s_18;
			s_4 : 
				state_nxt = s_21;
			s_21 : 
				state_nxt = s_18;
			s_7 :
				state_nxt = s_23;
			s_23 :
				state_nxt = s_16_1;
			//state 16 has mult.
			s_16_1 :
				state_nxt = s_16_2; // there's a R loop
			s_16_2 :
				state_nxt = s_16_3; // there's a R loop
			s_16_3 :
				state_nxt = s_18; // there's a R loop
			//state 16 ends
			s_6 :
				state_nxt = s_25_1;
			//state 25 has multiple states because of the memory read delay, check the comments in the state output logic
			s_25_1 :
				state_nxt = s_25_2; // there's a R loop
			s_25_2 :
				state_nxt = s_25_3; // there's a R loop
			s_25_3 :
				state_nxt = s_27; // there's a R loop
			//state 25 ends
			s_27 :
				state_nxt = s_18;
			s_9 :
				state_nxt = s_18;
			s_5 :
				state_nxt = s_18;
			
			s_0 : // right upper  side of state diagram
				if (ben)
					state_nxt = s_22;
				else
					state_nxt = s_18;

			s_22 :
				state_nxt = s_18;
			pause_ir1 : 
				if (continue_i) 
					state_nxt = pause_ir2;
			pause_ir2 : 
				if (~continue_i)
					state_nxt = s_18;

			default :;
		endcase
	end
	
endmodule

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
						
	output logic [1:0]	pcmux, // @@either incremented pc(state num 00)? or data bus address???, 
	
	//You should add additional control signals according to the SLC-3 datapath design

	output logic		mem_mem_ena, // Mem Operation Enable
	output logic		mem_wr_ena  // Mem Write Enable
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
		s_35 // @@IR <-MDR  then  PC <- PC+1 then Go to halt (in the case of week 1) week 2 u decode
	} state, state_nxt;   // Internal state logic


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
		 
		pcmux = 2'b00;
		
	
		// Assign relevant control signals based on current state
		case (state)
			halted: ;  // @@ takes the defult values
			s_18 : //s_18 = @@MAR <- PC
				begin 
					gate_pc = 1'b1; //@@ put current PC on BUS
					ld_mar = 1'b1; //@@ mar <- pc
					pcmux = 2'b00; // @@00 state is pc+1
					ld_pc = 1'b1;  // @@pc saves pc+1
					//so like if pc was 3 at that time(edge) mar stays 3 and pc gets 4
				end
			s_33_1, s_33_2, s_33_3 : //you may have to think about this as well to adapt to ram with wait-states
				begin  // @@ s_33 = MDR <- M(MAR) 
					mem_mem_ena = 1'b1; //@@Mem Operation Enable, what does thsi tell us?
					ld_mdr = 1'b1; //@@ Eric: only s_33_3 should load?? 
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
				state_nxt = pause_ir1;
			// pause_ir1 and pause_ir2 are only for week 1 such that TAs can see 
			// the values in ir.
			pause_ir1 : 
				if (continue_i) 
					state_nxt = pause_ir2;
			pause_ir2 : 
				if (~continue_i)
					//state_nxt = s_18;
					state_nxt = halted;
			// you need to finish the rest of state transition logic.....
			//@@@ why haltedis not used here should we add it
			default :;
		endcase
	end
	
endmodule

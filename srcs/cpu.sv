//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Stephen Kempf
//
// Create Date:    
// Design Name:    ECE 385 Given Code - SLC-3 core
// Module Name:    SLC3
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 09-22-2015 
//    Revised 06-09-2020
//	  Revised 03-02-2021
//    Xilinx vivado
//    Revised 07-25-2023 
//    Revised 12-29-2023
//    Revised 09-25-2024
//------------------------------------------------------------------------------

// @@commenting
module cpu (
    input   logic        clk,
    input   logic        reset,

    input   logic        run_i,
    input   logic        continue_i,
    output  logic [15:0] hex_display_debug,
    output  logic [15:0] led_o,
   
    input   logic [15:0] mem_rdata,
    output  logic [15:0] mem_wdata,
    output  logic [15:0] mem_addr,
    output  logic        mem_mem_ena,
    output  logic        mem_wr_ena
);


// Internal connections, follow the datapath block diagram and add the additional needed signals
logic ld_mar; 
logic ld_mdr; 
logic ld_ir; 
logic ld_pc; 
logic ld_led;

logic gate_pc;
logic gate_mdr;

logic [1:0] pcmux;
logic [15:0] pc_mux_out;

logic [15:0] mar; 
logic [15:0] mdr;
logic [15:0] ir;
logic [15:0] pc;
logic [15:0] bus;
logic ben;

assign ben = 1'b0;///@@ i'm doing this so its has a val for week one

assign mem_addr = mar; 
assign mem_wdata = mdr;

// State machine, you need to fill in the code here as well
// .* auto-infers module input/output connections which have the same name
// This can help visually condense modules with large instantiations, 
// but can also lead to confusing code if used too commonly
control cpu_control (
    .*
);


assign led_o = ir; //@@whats this led for ?
assign hex_display_debug = ir;

// @@ IR register

load_reg #(.DATA_WIDTH(16)) ir_reg (
    .clk    (clk),
    .reset  (reset),

    .load   (ld_ir),
    .data_i (bus), //what value should ir save

    .data_q (ir)
);

// @@ PC register
load_reg #(.DATA_WIDTH(16)) pc_reg (
    .clk(clk),
    .reset(reset),

    .load(ld_pc),
    .data_i(pc_mux_out),  //what value should pc save 

    .data_q(pc)
);

//@@ MAR register
//@@under construction
load_reg #(.DATA_WIDTH(16)) mar_reg (
    .clk(clk),
    .reset(reset),

    .load(ld_mar),
    .data_i(bus),  //what value should mar save

    .data_q(mar)
);

// @@ MDR register
load_reg #(.DATA_WIDTH(16)) mdr_reg (
    .clk(clk),
    .reset(reset),

    .load(ld_mdr),
    .data_i(mem_rdata),  //what value should mdr save

    .data_q(mdr)
);


//@@ added
pcmux pc_mux (
    .pc_bus_in  (bus),
    .pc_addr_in (16'h0000), // temporary: address calculation is for week two
    .pc_next_in (pc + 16'd1),
    .pc_mux_in  (pcmux),
    .pc_mux_out (pc_mux_out)
);

busmux bus_mux_inst (
    .GateMARMUX (1'b0),//@@ these needs changing for the seconed week
    .GatePC     (gate_pc),
    .GateALU    (1'b0), //@@ these needs changing for the seconed week
    .GateMDR    (gate_mdr),

    .bus_PC_in  (pc),
    .bus_MAR_in (16'h0000),
    .bus_ALU_in (16'h0000),
    .bus_MDR_in (mdr),

    .bus_out    (bus)
);

endmodule
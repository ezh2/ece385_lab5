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

    //@@ new
    
   
    input   logic [15:0] mem_rdata,
    output  logic [15:0] mem_wdata,
    output  logic [15:0] mem_addr,
    output  logic        mem_mem_ena,
    output  logic        mem_wr_ena
);

// @@ new  nzp stuff

logic [2:0] nzp; // n,z,p val in this order
logic ld_cc;    // comes from control

always_ff @(posedge clk) 
begin
    if (ld_cc)// condition codes high
     begin 
        if (bus == 16'h0000) // if it's zero
            nzp <=3'b010; //set the zero to 1
        else if (bus[15]) //check the msb 
            nzp <=3'b100; //set the negative to 1
        else
            nzp <=3'b001; // set the positive to 1
    end
end

// Internal connections, follow the datapath block diagram and add the additional needed signals
logic ld_mar; 
logic ld_mdr; 
logic ld_ir; 
logic ld_pc; 
logic ld_led;

logic gate_pc;
logic gate_mdr;
logic gate_mar;
logic gate_alu;

logic [1:0] pcmux;
logic addr1_mux;
logic [1:0] addr2_mux;
logic sr1mux;
logic sr2mux;
logic drmux;
logic [1:0] aluk;
logic ld_reg;
logic [15:0] pc_mux_out;

logic [15:0] mar; 
logic [15:0] mdr;
logic [15:0] ir;
logic [15:0] pc;
logic [15:0] bus;
logic [2:0] dr_out;
logic [2:0] sr1_index;
logic [15:0] sr1_data; // from cpu_reg_file, selected by sr1_index
logic [15:0] sr2_data; // from cpu_reg_file, selected by ir[2:0]
logic [15:0] sr2_mux_out;
logic [15:0] sext11_out;
logic [15:0] sext9_out;
logic [15:0] sext6_out;
logic [15:0] sext5_out;
logic [15:0] addr1_out;
logic [15:0] addr2_out;
logic [15:0] address_out;
logic [15:0] alu_result;
logic [15:0] mdr_data;
logic mio_en_sel;
logic ben;
logic ld_ben;
logic [4:0]  state_out;

always_ff@(posedge clk)
begin
    if(reset)
    begin
        ben<=1'b0;
    end

    else if(ld_ben)
    begin
        ben<=(nzp[2]& ir[11])|(nzp[1]& ir[10])| (nzp[0]& ir[9]);
    end
end

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

//MAR register
load_reg #(.DATA_WIDTH(16)) mar_reg (
    .clk(clk),
    .reset(reset),

    .load(ld_mar),
    .data_i(bus),  // what value should mar save
    .data_q(mar)
);

// @@ MDR register
load_reg #(.DATA_WIDTH(16)) mdr_reg (
    .clk(clk),
    .reset(reset),

    .load(ld_mdr),
    .data_i(mdr_data),
    .data_q(mdr)
);

reg_file cpu_reg_file (
    .clk     (clk),
    .ld_reg  (ld_reg),
    .data_in (bus),
    .dr      (dr_out),
    .sr1     (sr1_index),
    .sr2     (ir[2:0]),
    .sr1_data (sr1_data), // from reg_file.registers[sr1_index]
    .sr2_data (sr2_data)  // from reg_file.registers[ir[2:0]]
);

sext cpu_sext11 ( //@@use the sext module to sign extend the 11 bit and save the output to sext11_out
    .data_in (ir[10:0]),
    .sel     (2'b11),
    .data_out(sext11_out)
);

sext cpu_sext9 ( //@@use the sext module to sign extend the 9 bit and save the output to sext9_out
    .data_in (ir[10:0]),
    .sel     (2'b10),
    .data_out(sext9_out)
);

sext cpu_sext6 ( //@@use the sext module to sign extend the 6 bit and save the output to sext6_out
    .data_in (ir[10:0]),
    .sel     (2'b01),
    .data_out(sext6_out)
);

sext cpu_sext5 (   //@@use the sext module to sign extend the 5 bit and save the output to sext5_out -> SR2MUX
    .data_in (ir[10:0]),
    .sel     (2'b00),
    .data_out(sext5_out)
);

address_adder cpu_address_adder (
    .addr1   (addr1_out),
    .addr2   (addr2_out),
    .address_out (address_out)
);

alu cpu_alu (
    .a      (sr1_data),
    .b      (sr2_mux_out), 
    .aluk   (aluk),
    .result (alu_result)
);

assign mio_en_sel = mem_mem_ena && !mem_wr_ena;  // @@@ this decided where mio.en selects

mux_top cpu_muxes (
    .addr1_next_in (pc),
    .addr1_sr1_in  (sr1_data),
    .addr1_mux_in  (addr1_mux),
    .addr1_out     (addr1_out),

    .addr2_sext10_in (sext11_out), //@@ from sext[10:0] to addr2mux
    .addr2_sext8_in  (sext9_out), //@@ from sext[8:0] to addr2mux
    .addr2_sext5_in  (sext6_out), //@@ from sext[5:0] to addr2mux
    .addr2_mux_in    (addr2_mux),
    .addr2_out       (addr2_out), //@@ goes to the addr adder

    .dr_ir_in  (ir), //@@ from ir[11:9] to drmux
    .dr_mux_in (drmux), //@@
    .dr_mux_out (dr_out), //@@ pass to reg_file.dr

    .mio_en_bus  (bus), //@@ takes input from the bus
    .rdata      (mem_rdata), // @@ takes input from rdata
    .mio_en_sel (mio_en_sel), // @@ takes the @@@ confused @@@@
    .mio_en_out (mdr_data), //@@ pass to mdr.data_i

    .pc_bus_in  (bus), //@@ takes input from the bus (left side)
    .pc_addr_in (address_out), //@@ takes output from the address adder (middle)
    .pc_next_in (pc + 16'd1), //@@ takes input from pc + 1 (right side)
    .pc_mux_in  (pcmux), //@@ takes input from pcmux
    .pc_mux_out (pc_mux_out), //@@ pass to pc.data_i

    .sr1_ir_in  (ir), //@@ from ir to sr1mux
    .sr1_mux_in (sr1mux), //@ sr1 select from control (fsm)
    .sr1_mux_out (sr1_index), //@@ pass to reg_file.sr1

    .sr2_sext_in (sext5_out), //@@ from sext5_out to sr2mux
    .sr2_in      (sr2_data), //@@ from reg_file.sr2_data to sr2mux
    .sr2_ctrl_in (sr2mux), //@@ sr2 select from control (fsm)
    .sr2_out     (sr2_mux_out), //@@ pass to alu.b

    .GateMARMUX (gate_mar), //@@ pass to mar.data_i
    .GatePC     (gate_pc),
    .GateALU    (gate_alu),
    .GateMDR    (gate_mdr),
    .bus_PC_in  (pc),
    .bus_MAR_in (address_out),
    .bus_ALU_in (alu_result), 
    .bus_MDR_in (mdr),
    .bus_out    (bus)
);

endmodule
module mux_top (
    input  logic [15:0] addr1_next_in,
    input  logic [15:0] addr1_sr1_in,
    input  logic        addr1_mux_in,
    output logic [15:0] addr1_out,

    input  logic [15:0] addr2_sext10_in,
    input  logic [15:0] addr2_sext8_in,
    input  logic [15:0] addr2_sext5_in,
    input  logic [1:0]  addr2_mux_in,
    output logic [15:0] addr2_out,

    input  logic [15:0] dr_ir_in,
    input  logic        dr_mux_in,
    output logic [2:0]  dr_mux_out,

    input  logic [15:0] mio_en_in,
    input  logic [15:0] rdata,
    input  logic        mio_en_bus,
    output logic [15:0] mio_en_out,

    input  logic [15:0] pc_bus_in,
    input  logic [15:0] pc_addr_in,
    input  logic [15:0] pc_next_in,
    input  logic [1:0]  pc_mux_in,
    output logic [15:0] pc_mux_out,

    input  logic [15:0] sr1_ir_in,
    input  logic        sr1_mux_in,
    output logic [2:0]  sr1_mux_out,

    input  logic [15:0] sr2_sext_in,
    input  logic [15:0] sr2_in,
    input  logic        sr2_ctrl_in,
    output logic [15:0] sr2_out,

    input  logic        GateMARMUX,
    input  logic        GatePC,
    input  logic        GateALU,
    input  logic        GateMDR,
    input  logic [15:0] bus_PC_in,
    input  logic [15:0] bus_MAR_in,
    input  logic [15:0] bus_ALU_in,
    input  logic [15:0] bus_MDR_in,
    output logic [15:0] bus_out
);

    addr1mux u_addr1mux (
        .addr1_next_in(addr1_next_in),
        .addr1_sr1_in(addr1_sr1_in),
        .addr1_mux_in(addr1_mux_in),
        .addr1_out(addr1_out)
    );

    addr2mux u_addr2mux (
        .addr2_sext10_in(addr2_sext10_in),
        .addr2_sext8_in(addr2_sext8_in),
        .addr2_sext5_in(addr2_sext5_in),
        .addr2_mux_in(addr2_mux_in),
        .addr2_out(addr2_out)
    );

    drmux u_drmux (
        .dr_ir_in(dr_ir_in),
        .dr_mux_in(dr_mux_in),
        .dr_mux_out(dr_mux_out)
    );

    mio_en_mux u_mio_en_mux (
        .mio_en_bus(mio_en_bus),
        .rdata(rdata),
        .mio_en_sel(mio_en_sel),
        .mio_en_out(mio_en_out)
    );

    pcmux u_pcmux (
        .pc_bus_in(pc_bus_in),
        .pc_addr_in(pc_addr_in),
        .pc_next_in(pc_next_in),
        .pc_mux_in(pc_mux_in),
        .pc_mux_out(pc_mux_out)
    );

    sr1mux u_sr1mux (
        .sr1_ir_in(sr1_ir_in),
        .sr1_mux_in(sr1_mux_in),
        .sr1_mux_out(sr1_mux_out)
    );

    sr2mux u_sr2mux (
        .sr2_sext_in(sr2_sext_in),
        .sr2_in(sr2_in),
        .sr2_ctrl_in(sr2_ctrl_in),
        .sr2_out(sr2_out)
    );

    busmux u_busmux (
        .GateMARMUX(GateMARMUX),
        .GatePC(GatePC),
        .GateALU(GateALU),
        .GateMDR(GateMDR),
        .bus_PC_in(bus_PC_in),
        .bus_MAR_in(bus_MAR_in),
        .bus_MDR_in(bus_MDR_in),
        .bus_ALU_in(bus_ALU_in),
        .bus_out(bus_out)
    );

endmodule

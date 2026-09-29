module mux_top;

    // addr1mux
    logic [15:0] addr1_next_in;
    logic [15:0] addr1_sr1_in;
    logic [1:0]  addr1_mux_in;
    logic [15:0] addr1_out;

    addr1mux u_addr1mux (
        .addr1_next_in(addr1_next_in),
        .addr1_sr1_in(addr1_sr1_in),
        .addr1_mux_in(addr1_mux_in),
        .addr1_out(addr1_out)
    );

    // addr2mux
    logic [15:0] addr2_sext10_in;
    logic [15:0] addr2_sext8_in;
    logic [15:0] addr2_sext5_in;
    logic [15:0] addr2_zero_in;
    logic [1:0]  addr2_mux_in;
    logic [15:0] addr2_out;

    addr2mux u_addr2mux (
        .addr2_sext10_in(addr2_sext10_in),
        .addr2_sext8_in(addr2_sext8_in),
        .addr2_sext5_in(addr2_sext5_in),
        .addr2_zero_in(addr2_zero_in),
        .addr2_mux_in(addr2_mux_in),
        .addr2_out(addr2_out)
    );

    // drmux
    logic [15:0] dr_ir_in;
    logic        dr_mux_in;
    logic [2:0]  dr_mux_out;

    drmux u_drmux (
        .dr_ir_in(dr_ir_in),
        .dr_mux_in(dr_mux_in),
        .dr_mux_out(dr_mux_out)
    );

    // mio_en_mux
    logic        mio_en_in;
    logic        rdata;
    logic        mio_en_bus;
    logic        mio_en_out;

    mio_en_mux u_mio_en_mux (
        .mio_en_in(mio_en_in),
        .rdata(rdata),
        .mio_en_bus(mio_en_bus),
        .mio_en_out(mio_en_out)
    );

    // pcmux
    logic [15:0] pc_bus_in;
    logic [15:0] pc_addr_in;
    logic [15:0] pc_next_in;
    logic [2:0]  pc_mux_in;
    logic [15:0] pc_mux_out;

    pcmux u_pcmux (
        .pc_bus_in(pc_bus_in),
        .pc_addr_in(pc_addr_in),
        .pc_next_in(pc_next_in),
        .pc_mux_in(pc_mux_in),
        .pc_mux_out(pc_mux_out)
    );

    // sr1mux
    logic [15:0] sr1_ir_in;
    logic        sr1_mux_in;
    logic [2:0]  sr1_mux_out;

    sr1mux u_sr1mux (
        .sr1_ir_in(sr1_ir_in),
        .sr1_mux_in(sr1_mux_in),
        .sr1_mux_out(sr1_mux_out)
    );

    // sr2mux
    logic [15:0] sr2_sext_in;
    logic [15:0] sr2_in;
    logic        sr2_ctrl_in;
    logic [15:0] sr2_out;

    sr2mux u_sr2mux (
        .sr2_sext_in(sr2_sext_in),
        .sr2_in(sr2_in),
        .sr2_ctrl_in(sr2_ctrl_in),
        .sr2_out(sr2_out)
    );

endmodule
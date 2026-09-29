module addr2mux(
    input [15:0] addr2_sext10_in,
    input [15:0] addr2_sext8_in,
    input [15:0] addr2_sext5_in,
    input [15:0] addr2_zero_in,
    input [1:0]  addr2_mux_in,

    output       addr2_out;
);
endmodule
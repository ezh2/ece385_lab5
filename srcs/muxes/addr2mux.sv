module addr2mux(
    input logic [15:0] addr2_sext10_in,
    input logic [15:0] addr2_sext8_in,
    input logic [15:0] addr2_sext5_in,
    input logic [15:0] addr2_zero_in,
    input logic [1:0]  addr2_mux_in,

    output logic       addr2_out
);
endmodule
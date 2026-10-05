module sr2mux(
    input logic [15:0] sr2_sext_in,
    input logic [15:0] sr2_in,
    input logic        sr2_ctrl_in,

    output logic [15:0] sr2_out
);

always_comb begin
    if (sr2_ctrl_in == 1'b0)
    begin
        sr2_out = sr2_in;
    end
    else if (sr2_ctrl_in == 1'b1)
    begin
        sr2_out = sr2_sext_in;
    end
    else
    begin
        sr2_out = 16'b0; // nothing happens; avoid latch
    end
end
endmodule
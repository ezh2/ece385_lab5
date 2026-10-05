module addr2mux(
    input logic [15:0] addr2_sext10_in,
    input logic [15:0] addr2_sext8_in,
    input logic [15:0] addr2_sext5_in,
    input logic [1:0]  addr2_mux_in,

    output logic [15:0] addr2_out
);
    always_comb begin
        if (addr2_mux_in == 2'b00)
        begin
            addr2_out = addr2_sext10_in; //@@ check, im not sure
        end
        else if (addr2_mux_in == 2'b01)
        begin
            addr2_out = addr2_sext8_in;
        end
        else if (addr2_mux_in == 2'b10)
        begin
            addr2_out = addr2_sext5_in;
        end
        else if (addr2_mux_in == 2'b11)
        begin
            addr2_out = 16'b0; //@@ check, im not sure
        end
        else
        begin
            addr2_out = 16'b0; // nothing happens; avoid latch
        end
    end
endmodule
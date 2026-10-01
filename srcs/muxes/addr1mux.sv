module addr1mux(
    input logic [15:0] addr1_next_in,
    input logic [15:0] addr1_sr1_in,
    input logic  addr1_mux_in,

    output logic       addr1_out
);

    always_comb begin
        if (addr1_mux_in == 1'b0)
        begin
            addr1_out = addr1_next_in; //@@ check, im not sure
        end
        else if (addr1_mux_in == 1'b1)
        begin
            addr1_out = addr1_sr1_in; //@@ check, im not sure
        end
        else
        begin
            addr1_out = 16'b0; // nothing happens; avoid latch
        end
    end
endmodule
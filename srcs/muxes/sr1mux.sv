module sr1mux (
    input logic [15:0] sr1_ir_in,
    input logic sr1_mux_in,

    output logic [2:0] sr1_mux_out
);

always_comb begin
    if (sr1_mux_in == 1'b1)
    begin
        sr1_mux_out = sr1_ir_in[8:6]; //@@ check, im not sure
    end
    else if (sr1_mux_in == 1'b0)
    begin
        sr1_mux_out = sr1_ir_in[11:9]; //@@ check, im not sure is it another way around?
    end
    else
    begin
        sr1_mux_out = 3'b000; // nothing happens; avoid latch
    end
end
endmodule
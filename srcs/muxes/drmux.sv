module drmux (
    input logic [15:0] dr_ir_in,
    input logic dr_mux_in,

    output logic [2:0] dr_mux_out
);
    always_comb begin
        if (dr_mux_in == 1'b0)
        begin
            dr_mux_out = dr_ir_in[11:9]; //@@ check, im not sure
        end
        else if (dr_mux_in == 1'b1)
        begin
            dr_mux_out = 3'b111; //@@ check, im not sure
        end
        else
        begin
            dr_mux_out = 3'b000; // nothing happens; avoid latch
        end
    end
endmodule
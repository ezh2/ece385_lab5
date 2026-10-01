module mio_en_mux (
    input logic mio_en_in,
    input logic rdata,
    input logic mio_en_bus,

    output logic mio_en_out
);

    always_comb 
    begin
        if (mio_en_bus == 1'b0)
        begin
            mio_en_out = mio_en_in; //@@ check, im not sure
        end
        else if (mio_en_bus == 1'b1)
        begin
            mio_en_out = rdata; //@@ check, im not sure
        end
        else
        begin
            mio_en_out = 1'b0; // nothing happens; avoid latch
        end
    end
endmodule
module mio_en_mux (
    
    input logic [15:0] mio_en_bus,
    input logic [15:0] rdata,
    input logic mio_en_sel,

    output logic [15:0] mio_en_out
);

    always_comb 
    begin
        if (mio_en_sel == 1'b0)
        begin
            mio_en_out = mio_en_bus; //@@ check, im not sure
        end
        else if (mio_en_sel == 1'b1)
        begin
            mio_en_out = rdata; //@@ check, im not sure
        end
        // else
        // begin
        //     mio_en_out = 16'b0; // nothing happens; avoid latch
        // end
    end
endmodule
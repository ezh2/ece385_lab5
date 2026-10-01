module drmux (
    input logic [15:0] dr_ir_in,
    input logic dr_mux_in,

    output logic [2:0] dr_mux_out
);
    always_comb begin
        if (dr_mux_in == 1'b0)
        begin
            dr_mux_out = dr_ir_in[11:9]; //@@ yea this is correct
        end
        else //when dr=1
        begin
            dr_mux_out = 3'b111; //@@ this is correct
        end
        // else
        // begin
        //     dr_mux_out = 3'b000; // nothing happens; avoid latch.  this is Wrong  one bit has 2 cases only 
        //and u covered them already, and this means dris R0
        // end
    end
endmodule
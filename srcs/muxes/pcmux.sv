module pcmux (
    input logic [15:0] pc_bus_in,
    input logic [15:0] pc_addr_in,
    input logic [15:0] pc_next_in,
    input logic [1:0]  pc_mux_in,
    
    output logic      pc_mux_out // @@am i tripping or shouldnt this be 16 bit
);

always_comb begin
if (pc_mux_in == 2'b00) 
    begin
        pc_mux_out = pc_next_in; // @@this state(00) is for the incrememnted pc 
        //assign pc_mux_out = pc_bus_in  
    end

    else if (pc_mux_in == 2'b01) begin
        pc_mux_out = pc_addr_in;
    end

    else if (pc_mux_in == 2'b10) begin
        //assign pc_mux_out = pc_next_in
        pc_mux_out = pc_bus_in ;
    end

    //@@what if 11? wont not giving it a val create a latch i did all 0 but im not sure if thats correct?
    else 
    begin
        pc_mux_out = 16'h0000;
    end
end //@@for the always always_comb
endmodule
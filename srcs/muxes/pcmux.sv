module pcmux (
    input [15:0] pc_bus_in,
    input [15:0] pc_addr_in,
    input [15:0] pc_next_in,
    input [2:0]  pc_mux_in
    
    output      pc_mux_out;
);
endmodule
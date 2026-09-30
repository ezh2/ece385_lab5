module busmux(
    input logic GateMARMUX,
    input logic GatePC,
    input logic GateALU,
    input logic GateMDR,

    input logic [15:0] bus_PC_in,
    input logic [15:0] bus_MAR_in,
    input logic [15:0] bus_ALU_in,
    input logic [15:0] bus_MDR_in,

    // output logic [15:0] busmux_LOGIC,
    // output logic [15:0] busmux_IR,
    // output logic busmux_MAR,
    // output logic busmux_MIO_EN,
    // output logic busmux_REG_FILE,
    // output logic busmux_PCMUX,

    output logic [15:0] bus_out;
);

if (GateMARMUX) begin
    assign bus_out = bus_MAR_in
end

else if (GatePC) begin
    assign bus_out = bus_PC_in
end

else if (GateALU) begin
    assign bus_out = bus_ALU_in
end

else if (GateMDR) begin
    assign bus_out = bus_MDR_in
end

endmodule